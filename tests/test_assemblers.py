import pytest
import conftest
from conftest import *
import multiprocessing
import subprocess
import multiprocessing
import shlex

def run_executable(executable, parameters):
    # prepare the command string from executable and parameters
    cmd = [executable]
    
    # flattening parameters into a list of strings
    for key, value in parameters.items():
        cmd.append(f'--{key}')
        cmd.append(str(value))

    # execute the command and capture output
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return {
            'success': True,
            'output': result.stdout
        }
    except subprocess.CalledProcessError as e:
        return {
            'success': False,
            'output': e.stderr
        }

# @pytest.mark.slow
def test_shasta():
    resp = run_executable(
        executable='pteryx',
        parameters={
            'targets': 'shasta',
            'threads': multiprocessing.cpu_count(),
            'ilmn': 'tests/fixtures/mesoplasma/mesoplasma_simulated.1.paired.fq.gz',
            'ont': 'tests/fixtures/mesoplasma/mesoplasma_simulated.ont.fq.gz'
        }
    )
    print(resp)
    assert(resp['success'])

# @pytest.mark.slow
def test_spades():
    resp = run_executable(
        executable='pteryx',
        parameters={
            'targets': 'spades',
            'threads': multiprocessing.cpu_count(),
            'ilmn': 'tests/fixtures/mesoplasma/mesoplasma_simulated.1.paired.fq.gz',
            'ont': 'tests/fixtures/mesoplasma/mesoplasma_simulated.ont.fq.gz'
        }
    )
    print(resp)
    assert(resp['success'])

    # resp = run_executable(
    #     executable='snakemake',
    #     arguments=['spades'],
    #     parameters={
    #         'snakefile': SNAKEFILE,
    #         'cores': multiprocessing.cpu_count(),
    #         'configfile': CONFIGFILE
    #     }
    # )
    # print(resp)
    # assert(resp['success'])
    
@pytest.mark.slow
def test_skesa(SNAKEFILE, CONFIGFILE):
    resp = run_executable(
        executable='snakemake',
        arguments=['skesa'],
        parameters={
            'snakefile': SNAKEFILE,
            'cores': multiprocessing.cpu_count(),
            'configfile': CONFIGFILE
        }
    )
    assert(resp['success'])

@pytest.mark.slow
def test_hybridspades(SNAKEFILE, CONFIGFILE):
    resp = run_executable(
        executable='snakemake',
        arguments=[
            'hybridspades',
            'biosyntheticspades',
            'metaspades'
        ],
        parameters={
            'snakefile': SNAKEFILE,
            'cores': multiprocessing.cpu_count(),
            'configfile': CONFIGFILE
        }
    )
    assert(resp['success'])

# def test_hybridspades(SNAKEFILE, CONFIGFILE):
    # resp = run_executable(
        # executable='snakemake',
        # arguments=['hybridspades'],
        # parameters={
            # 'snakefile': SNAKEFILE,
            # 'cores': multiprocessing.cpu_count(),
            # 'configfile': CONFIGFILE
        # }
    # )
    # assert(resp['success'])

# def test_metaspades(SNAKEFILE, CONFIGFILE):
    # resp = run_executable(
        # executable='snakemake',
        # arguments=['metaspades'],
        # parameters={
            # 'snakefile': SNAKEFILE,
            # 'cores': multiprocessing.cpu_count(),
            # 'configfile': CONFIGFILE
        # }
    # )
    # assert(resp['success'])

# def test_biosyntheticspades(SNAKEFILE, CONFIGFILE):
    # resp = run_executable(
        # executable='snakemake',
        # arguments=['biosyntheticspades'],
        # parameters={
            # 'snakefile': SNAKEFILE,
            # 'cores': multiprocessing.cpu_count(),
            # 'configfile': CONFIGFILE
        # }
    # )
   # assert(resp['success'])

def test_flye():
    resp = run_executable(
        executable='pteryx',
        parameters={
            'targets': 'flye',
            'threads': multiprocessing.cpu_count(),
            'ilmn': 'tests/fixtures/mesoplasma/mesoplasma_simulated.1.paired.fq.gz',
            'ont': 'tests/fixtures/mesoplasma/mesoplasma_simulated.ont.fq.gz'
        }
    )
    print(resp)
    assert(resp['success'])

@pytest.mark.slow
def test_canu(SNAKEFILE, CONFIGFILE):
    resp = run_executable(
        executable='snakemake',
        arguments=['canu'],
        parameters={
            'snakefile': SNAKEFILE,
            'cores': multiprocessing.cpu_count(),
            'configfile': CONFIGFILE
        }
    )
    assert(resp['success'])

@pytest.mark.slow
def test_unicycler(SNAKEFILE, CONFIGFILE):
    resp = run_executable(
        executable='snakemake',
        arguments=['canu'],
        parameters={
            'snakefile': SNAKEFILE,
            'cores': multiprocessing.cpu_count(),
            'configfile': CONFIGFILE
        }
    )
    assert(resp['success'])
