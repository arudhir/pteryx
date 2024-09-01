def tsv2json(self):
    pass

def json2tsv(self):
    pass

import os
import math
from io import StringIO
import sys
import json
import shutil
from pathlib import Path
from collections import defaultdict
import pandas as pd
from Bio import SeqIO

import yaml
def load_config(configfile):
    return yaml.load(open(configfile, 'r'), Loader=yaml.FullLoader)

def value_to_float(x):
    if type(x) == float or type(x) == int:
        return x
    if 'K' in x:
        if len(x) > 1:
            return float(x.replace('K', '')) * 1000
        return 1000.0
    if 'M' in x:
        if len(x) > 1:
            return float(x.replace('M', '')) * 1000000
        return 1000000.0
    if 'B' in x:
        return float(x.replace('B', '')) * 1000000000
    return 0.0

def get_percentile(sorted_list, percentile):
    rank = int(math.ceil(percentile / 100.0 * len(sorted_list)))
    if rank == 0:
        return sorted_list[0]
    return sorted_list[rank - 1]

def get_insert_size(samfile):
    insert_sizes = []
    with open(samfile, 'rt') as sam:
        for sam_line in sam:
            try:
                sam_parts = sam_line.split('\t')
                sam_flags = int(sam_parts[1])
                if sam_flags & 2:  # read mapped in proper pair
                    insert_size = int(sam_parts[8])
                    if insert_size > 0:
                        insert_sizes.append(insert_size)
            except (ValueError, IndexError):
                pass
    insert_sizes = sorted(insert_sizes)
    insert_size_1st = get_percentile(insert_sizes, 1.0)
    insert_size_99th = get_percentile(insert_sizes, 99.0)
    #print(f'Insert sizes determined to be {insert_size_1st} and {insert_size_99th}')
    return insert_size_1st, insert_size_99th

def contig_lengths(fasta_file):
    contigs = list(SeqIO.parse(fasta_file, format='fasta'))
    return pd.Series({c.id: len(c.seq) for c in contigs}).sort_values(ascending=False)

def get_shepard_env_variables():
    shepard_env_variables = {
        'UUID': os.environ.get('UUID'),
        'START_TIME': os.environ.get('START_TIME'),
        'END_TIME': os.environ.get('END_TIME'),
        'JOB_STATUS': os.environ.get('JOB_STATUS'),
        'EFS_INPUT_NAME': os.environ.get('EFS_INPUT_NAME'),
        'EFS_OUTPUT_NAME': os.environ.get('EFS_OUTPUT_NAME'),
        'LUSTRE_INPUT_NAME': os.environ.get('LUSTRE_INPUT_NAME'),
        'LUSTRE_OUTPUT_NAME': os.environ.get('LUSTRE_OUTPUT_NAME'),
        'ROOT_INPUT_NAME': os.environ.get('ROOT_INPUT_NAME'),
        'ROOT_OUTPUT_NAME': os.environ.get('ROOT_OUTPUT_NAME'),
        'INPUTS_BUCKET': os.environ.get('INPUTS_BUCKET'),
        'OUTPUTS_BUCKET': os.environ.get('OUTPUTS_BUCKET'),
        'ERROR_BUCKET': os.environ.get('ERROR_BUCKET'),
        'INPUT_ZIP_NAME': os.environ.get('INPUT_ZIP_NAME'),
        'PATH': os.environ.get('PATH'),
        'HOSTNAME': os.environ.get('HOSTNAME'),
        'USES_EFS': os.environ.get('USES_EFS'),
        'USES_LUSTRE': os.environ.get('USES_LUSTRE'),
        'LUSTRE_READ_ONLY_PATH': os.environ.get('LUSTRE_READ_ONLY_PATH'),
        'EFS_READ_ONLY_PATH': os.environ.get('EFS_READ_ONLY_PATH'),
        'ULIMIT_FILENO': os.environ.get('ULIMIT_FILENO'),
        'IS_INVOKED': os.environ.get('IS_INVOKED'),
    }
    return shepard_env_variables

def determine_run_environment():
    """Figure out if we're running locally or on AWS Batch"""
    location = ('shepard' if (os.environ.get('USES_EFS', False) \
                              or os.environ.get('USES_LUSTRE', False)) \
                else 'local')
    return location

def prepare_snakemake_config():
    """Prepares the config dict that will be passed into Snakemake"""
    run_env = determine_run_environment()

