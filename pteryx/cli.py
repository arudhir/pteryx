#!/usr/bin/env python3
import pathlib
import argparse
import multiprocessing
from functools import partial
import snakemake
# from snakemake import snakemake
import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
# from log import bold_red, bold_yellow, bold_green

def parse_arguments():

    parser = argparse.ArgumentParser(
        description='Run pteryx',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    ## General Options
    parser.add_argument(
        '--outdir',
        '-o', 
        help='Output directory',
        default='outputs',
        type=pathlib.Path
    )

    parser.add_argument(
        '--targets',
        help='target rules',
        default=['all'],
        nargs='+'
    )

    parser.add_argument(
        '-t',
        '--threads',
        help='Number of cores to use',
        type=int,
        default=multiprocessing.cpu_count()
    )

    reads = parser.add_argument_group(
        'NGS sampleIDs shorts and long'
    )

    reads.add_argument(
        '--ilmn',
        nargs='+',
        help='Illumina samples',
        default=[]
    )
    
    reads.add_argument(
        '--ont',
        nargs='+',
        help='Nanopore samples',
        default=[]
    )

    # Should we do canu-correction?
    corr = parser.add_argument_group(
        'canu-correct',
    )

    corr.add_argument(
        '--canu_correct',
        help='Whether we should run canu-correct or not',
        action='store_true',
        default=False
    )
    
    parser.add_argument(
        '--size',
        help='genome size in Mbp.',
        default='5M'
    )

    debug = parser.add_argument_group('debugging')
    debug.add_argument(
        '-n',
        '--dry-run',
        default=False,
        action='store_true'
    )

    parser.add_argument(
        '--batch', 
        help='Submit to BaaS', 
        default=False, 
        action='store_true'
    )

    parser.add_argument(
        '--query',
        help='Job ID to query',
        default=False
    )

    parser.add_argument(
        '--s3',
        help='Upload to BaaS bucket',
        default=False,
        action='store_true'
    )

    parser.add_argument(
        '--force',
        help='Force overwrite on S3',
        default=False,
        action='store_true'
    )

    args = parser.parse_args()

    if not (args.ilmn or args.ont or args.query):
        parser.error('Must provide at least ILMN or ONT reads!')
    logger.info(args)
    return args 
