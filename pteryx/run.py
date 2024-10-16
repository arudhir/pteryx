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
from Bio import SeqIO
import shutil 
import pteryx 
from .cli import parse_arguments
from .utils import tsv2json, json2tsv
from .errors import CommandError, ExistingResultError

import logging
from logging.handlers import RotatingFileHandler
import sys

def setup_logger(log_file='outputs/pteryx.log'):
    # Create the log directory if it doesn't exist—needed if our 
    # output directory is outside the development directory
    if not Path(log_file).parent.exists():
        Path(log_file).parent.mkdir(parents=True, exist_ok=True)
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

def main():
    args = parse_arguments()
    args.outdir.mkdir(exist_ok=True)
    try:
        run_workflow(args)
    except:
        raise ValueError('Snakemake failed!')

    valid_assemblies = get_valid_assemblies(args)
    print(valid_assemblies)
    try:
        stats = get_assembly_stats(args)
        logger.info(pformat(stats))
    except:
        raise ValueError('Assembly stats failed!')

    if args.s3:
        upload_to_bucket(args)

def get_valid_assemblies(args):
    assembly_dir = args.outdir / 'assemblies'
    valid_assemblies = []
    for asm in assembly_dir.rglob('*.fa'):
        try:
            assembly = list(SeqIO.parse(asm, format='fasta'))
        except:
            print(f'{asm} is not a valid FASTA file!')
            continue
        if len(assembly) > 0:
            valid_assemblies.append(asm)
    return valid_assemblies

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


def make_directory(path):
    path = Path(path)
    path.mkdir(parents=True, exist_ok=True)
    return path    


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
