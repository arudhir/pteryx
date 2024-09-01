#!/usr/bin/env python3

import os
import sys
import subprocess
import multiprocessing
import logging
import pathlib
if os.environ.get('USES_LUSTRE'):
    inputs = os.environ['LUSTRE_INPUT_NAME']
    outputs = os.environ['LUSTRE_OUTPUT_NAME']
else:
    outputs = pathlib.Path('outputs')
    outputs.mkdir(exist_ok=True)

import logging
logging.basicConfig(
    level=logging.DEBUG,
    format= '[%(asctime)s] {%(pathname)s:%(lineno)d} %(levelname)s - %(message)s',
    datefmt='%H:%M:%S',
    filename=os.path.join(outputs, 'pteryx.log'),
    filemode='w+'
)

logging.info(f'Environment variables: {os.environ}')
outdir = os.environ['LUSTRE_OUTPUT_NAME']

cmd = (
    f"""
    ./workflow/cli.py \
        --name {os.environ["NAME"]} \
        --ilmn {os.environ["ILMN"].replace(':', ' ')} \
        --ont {os.environ["ONT"]} \
        --size {os.environ["SIZE"]} \
        --threads {multiprocessing.cpu_count()} \
        --canu_correct \
        -o {os.environ["LUSTRE_OUTPUT_NAME"]}
    """
)

logging.info(cmd)

logging.info(subprocess.check_output(cmd, shell=True))
