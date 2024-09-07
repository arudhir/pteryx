import os
import os.path
import json
import boto3
import pandas as pd
import hashlib
from io import StringIO
from pprint import pformat
from pathlib import Path
import subprocess
import requests
from requests import HTTPError
from snakemake.api import SnakemakeApi
from snakemake.settings.types import (
        OutputSettings,
        WorkflowSettings, 
        ExecutionSettings,
        ResourceSettings,
        ConfigSettings,
        DAGSettings
    )

# from snakemake import snakemake
# from ginkgo_common.utils import Retry, call_executable, upload_s3_asset, upload_batch_results, download_s3_asset, datastore
# from ginkgo_common.logger import logger
# from ginkgo_common.constants import GRAPHQL_DEFAULT_USERNAME, GRAPHQL_URL

import shutil 
import pteryx 
from .cli import parse_arguments
from .utils import tsv2json, json2tsv
from .errors import CommandError, ExistingResultError

import logging
from logging.handlers import RotatingFileHandler
import sys

def setup_logger(log_file='app.log'):
    # Create a logger
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)

    # Create handlers
    c_handler = logging.StreamHandler(sys.stdout)
    f_handler = RotatingFileHandler(log_file, maxBytes=10*1024*1024, backupCount=5)
    c_handler.setLevel(logging.INFO)
    f_handler.setLevel(logging.INFO)

    # Create formatters and add it to handlers
    log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    c_format = logging.Formatter(log_format)
    f_format = logging.Formatter(log_format)
    c_handler.setFormatter(c_format)
    f_handler.setFormatter(f_format)

    # Add handlers to the logger
    logger.addHandler(c_handler)
    logger.addHandler(f_handler)

    return logger

logger = setup_logger()

ASSEMBLERS = [
    'skesa', 'canu', 'flye', 
    'hybrid_spades', 'miniasm', 
    'shasta', 'unicycler'
]

DEMO_BUCKET = 's3://ngs-training-2f0ac09a-demo-us-east-2/'

DATASTORE_QUERY_PAIRED_READS = '''
query datastorePairedReads($sample: Float!) {
    datastoreAttachments(dataset_SampleId: $sample, dataset_DatasetType_Id: 16, name_Endswith:"_paired.fastq.gz") {
        items {
            name
            url
            updatedOn
        }
    }
}
'''

DATASTORE_QUERY_NANOPORE_READS = '''
query datastoreNanoporeSampleAttachments($sample: Float) {
  datastoreAttachments(dataset_SampleId: $sample) {
    items {
      name
      url
      updatedOn
    }
  }
}
'''

def submit_job(memory=300, cpus=96, **kwargs):
    """Submit a job to BaaS by making the appropriate request

    Makes a POST request to the `ngs-training BaaS environment http://batch.ngs-training.ginkgo.zone/submit`_.

    :param sample: LIMS Sample ID
    :type sample: int
    :param memory: Amount of RAM to provision for the job, defaults to 100
    :type memory: int, optional
    :param cpu: Number of CPUs to provision for the job, defaults to 16
    :type cpu: int, optional
    :return: The AWS Batch jobId for future querying/retrieving
    :rtype: str
    """
    jobParams = []
    kwargs.pop('batch')  # remove "batch" if its in there so we can queue the right cmd
    for kw, arg in kwargs.items():
        if arg == []:
            continue
        elif (arg == ['all']) or (arg == 'all'):
            logger.info('selected all possible targets')
            continue        
        elif arg is True:
            if kw == 'batch':
                continue
            jobParams.append(f'--{kw}')
        elif type(arg) == list:
            jobParams.append((f'--{kw} {" ".join(map(str, arg))}'))

    response = requests.post(
        'http://batch.ngs-training.ginkgo.zone/submit',
        json={
            'jobDefinition': 'bbypteryx',
            'jobParams': 'pteryx " ".join(jobParams)',
            'jobEnvironment': {
                'GRAPHQL_URL': 'https://graphql.ginkgobioworks.com/graphql',
                'CURIOUS_URL': 'https://curious.ginkgobioworks.com',
                'GINKGO_ENVIRONMENT': 'development',
                'GINKGO_APP_STATE': 'serving'
            },
            'memory': 1024 * memory,
            'cpus': cpus,
            'timeout': 86400,
        }
    )
    logger.info(f'Running: pteryx {jobParams}')
    logger.info(response.json())
    return response.json()['jobId']

def query_job(jobId):
    resp = requests.post('http://batch.ngs-training.ginkgo.zone/query', json={'jobId': jobId}).json()
    return resp

def main():
    args = parse_arguments()
    args.outdir.mkdir(exist_ok=True)

    if args.batch:
        jobId = submit_job(**vars(args))
        with open('jobIds.log', 'a+') as f:
            f.write(jobId)
            f.write('\n')
        return jobId
    if args.query:
        status = query_job(args.query)
        logger.info(pformat(status))
        return
    try:
        prepare_reads(args)
    except:
        raise ValueError('Read preparation failed!')
    try:
        run_workflow(args)
    except:
        raise ValueError('Snakemake failed!')

    # valid_assemblies = # the not empty ones

    try:
        stats = get_assembly_stats(args)
        logger.info(pformat(stats))
    except:
        raise ValueError('Assembly stats failed!')

    if args.s3:
        upload_to_bucket(args)

def md5zip(zipfile):
    """Gets the md5 of a zipfile for unique naming purposes

    :param zipfile: Path to zip file
    :type zipfile: str
    """
    m = hashlib.md5()
    with open(zipfile, 'rb') as f:
        data = f.read()
        m.update(data)
        return m.hexdigest()

def upload_to_bucket(args):
    bucket_name = os.environ.get('AWS_BUCKET', 'baas-code-bucket-batchoutputbucket-apyskta34alv')

    logger.info(f'Trying to upload to BaaS bucket: {bucket_name}')
    logger.info('Creating zip archive')
    shutil.make_archive(
        base_name=f'outputs', 
        root_dir=os.path.join(os.getcwd(), 'outputs'),
        format='zip'
    )

    zipfile = md5zip('outputs.zip') + '.zip'
    logger.debug(f'zipfile hash: {zipfile}')

    logger.info('Checking to see if a result already exists for this...')
    
    # Check if file already exists
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    hits = list(bucket.objects.filter(Prefix=zipfile))
    if len(hits) > 0:
        if args.force:
            logger.warning('Overwriting previous result...')
        else:
            raise ExistingResultError('Result already exists. Run with --force to overwrite')
    

    remote_path = upload_s3_asset(
        asset='outputs.zip', 
        path=zipfile,
        bucket=bucket_name
    )
    logger.info(remote_path)

    try:
        ret = upload_batch_results(
            {
                "errors": [],
                "notification": "bbypteryx run complete!",
                "files": {
                    "bbypteryx": {"path": remote_path, "dataset_type": 22},
                },
            }
        )
    except:
        logger.error('Can\'t upload to Batch: not in BaaS environment!')

def gql_query(query, variables):
    """Query GraphQL-staging

    Parameters
    ----------
    query : string
        GraphQL query
    variables : dict
        Variables to give GraphQL
    """
    def make_request_with_retry(url, payload, **kwargs):

        def post_and_raise(*args, **kwargs):
            response = requests.post(*args, **kwargs)
            response.raise_for_status()
            return response

        with Retry(post_and_raise, [HTTPError], max_attempts=5) as post:
            response = post(url, json=payload, **kwargs)
        response = response.json()

        if response.get('errors'):
            logger.error(response)
            raise Exception(response['errors'])
        else:
            return response['data']

    resp = make_request_with_retry(
      GRAPHQL_URL, {
          'query': query,
          'variables': variables
      },
      headers={'HTTP_USERNAME': GRAPHQL_DEFAULT_USERNAME}
    )
    
    return resp

def make_directory(path):
    path = Path(path)
    path.mkdir(parents=True, exist_ok=True)
    return path

def paired_reads_url(sample):
    resp = gql_query(DATASTORE_QUERY_PAIRED_READS, {'sample': sample})
    reads = resp['datastoreAttachments']['items']

    # In case there are multiple forwards/reverse reads, sort by updated on and pick first
    # Should this be the default for anything we're grabbing off Datastore... pretty much always?
    get_first = lambda iterable, predicate: next(x for x in iterable if predicate(x))
    reads = sorted(reads, key=lambda read: read['updatedOn'], reverse=True)
    try:
        forward = get_first(reads, lambda read: 'R1' in read['name'])['url']
        reverse = get_first(reads, lambda read: 'R2' in read['name'])['url']
    except StopIteration:
        raise Exception(f'Unable to find both forward and reverse reads from {reads}')
    return forward, reverse

def nanopore_reads_url(sample):
    resp = gql_query(DATASTORE_QUERY_NANOPORE_READS, {'sample': sample})
    reads = resp['datastoreAttachments']['items']
    get_first = lambda iterable, predicate: next(x for x in iterable if predicate(x))
    reads = sorted(reads, key=lambda read: read['updatedOn'], reverse=True)    
    return reads[0]['url']
    
def prepare_reads(args):
    """Take local reads and put them in the starting directory or download Datastore samples

    input: args
        argparse.Namespace
        just a dict in disguise
    returns:
        None
    """
    #TODO: This should be refactored, too much repetition -- it'll make PacBio easier
    if args.ilmn:
        ilmn_outdir = args.outdir / 'illumina/raw'
        ilmn_outdir.mkdir(parents=True, exist_ok=True)    
        for entry in args.ilmn:
            entry = Path(entry)
            if entry.exists():
                logger.debug(f'{entry} exists, copying it over to expected location')
                input_dir, sample = entry.parent, entry.stem.split('.')[0]  # sample ID
                resp = subprocess.check_call(
                    f"""
                    cp {input_dir}/{sample}.1*.fq.gz {ilmn_outdir}/{sample}.1.paired.fq.gz
                    cp {input_dir}/{sample}.2*.fq.gz {ilmn_outdir}/{sample}.2.paired.fq.gz
                    """, shell=True
                )
            else:
                sample = int(entry.name)
                logger.info(f'Downloading ilmn reads for s{sample} from Datastore')
                forward_url, reverse_url = paired_reads_url(sample)
                download_s3_asset(s3_url=forward_url, save_to=ilmn_outdir / f'{sample}.1.fq.gz')
                download_s3_asset(s3_url=reverse_url, save_to=ilmn_outdir / f'{sample}.2.fq.gz')
    if args.ont:
        ont_outdir = args.outdir / 'nanopore/raw'
        ont_outdir.mkdir(parents=True, exist_ok=True)
        for entry in args.ont:
            entry = Path(entry)
            if entry.exists():
                input_dir, sample = Path(entry).parent, Path(entry).stem.split('.')[0]
                resp = subprocess.check_call(
                    f"""
                    cp {input_dir}/{sample}.ont.fq.gz {ont_outdir}/{sample}.ont.fq.gz
                    """, shell=True
                )
            else:
                sample = int(entry.name)
                logger.debug(f'Downloading nanopore for s{sample} from Datastore')
                nanopore_url= nanopore_reads_url(sample)
                download_s3_asset(s3_url=nanopore_url, save_to=ont_outdir / f'{sample}.ont.fq.gz')


def get_assembly_stats(args):
    """
    stats.sh but as a JSON

    TODO: Generic function that wraps a command line exec + params and returns the raw CSV as a pd.DataFrame
    """
    assembly_dir = args.outdir / 'assemblies'
    stats = []
    for asm in assembly_dir.rglob('*.fa'):
        
        resp = subprocess.run(
            ['bash', 'stats.sh', f'in={asm}', 'format=3'], 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE,
            text=True
        )

        if resp.returncode == 0:  # check if the command ran successfully
            stats.append(
                pd.read_csv(StringIO(resp.stdout), delimiter='\t')
                .assign(assembler=asm.stem)
                .set_index('assembler')
                .T
                .to_dict()
            )
        else:
            print(f"Error running stats.sh: {resp.stderr}")
        
    with open(assembly_dir / 'assembly_stats.json', 'w+') as f:
        json.dump(stats, f)
    return stats

def validate_args(args):
    pass

def run_workflow(args):
    with SnakemakeApi(
        OutputSettings(
            verbose=False,
            printshellcmds=True
        )
    ) as api:
        try:
            workflow = api.workflow(
                snakefile=Path(pteryx.__path__[0]) / 'Snakefile',
                workflow_settings=WorkflowSettings(),
                resource_settings=ResourceSettings(
                    cores=args.threads
                ),
                config_settings=ConfigSettings(
                    config={
                        'ilmn': args.ilmn,
                        'ont': args.ont,
                        'outdir': str(args.outdir),
                        'canu_correct': args.canu_correct,
                        'size': args.size,
                    }
                )
            )
            dag = workflow.dag(
                dag_settings=DAGSettings(
                    targets=args.targets,
                )
            )
            dag.execute_workflow(
                execution_settings=ExecutionSettings(
                    keep_going=True
                )
            )
            return True
        except Exception as e:
            api.print_exception(e)
            return False


    # snakemake(
        # snakefile=Path(pteryx.__path__[0]) / 'Snakefile',
        # targets=args.targets,
        # config={
            # 'ilmn': args.ilmn,
            # 'ont': args.ont,
            # 'outdir': args.outdir,
            # 'canu_correct': args.canu_correct,
            # 'size': args.size,
        # },
        # cores=args.threads,
        # dryrun=args.dry_run,
        # printshellcmds=True,
        # keepgoing=True
    # )
