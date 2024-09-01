import pytest
import conftest
from conftest import *
import multiprocessing
from ginkgo_common.utils import setup_batch_env, run_executable

def test_snakemake_dryrun(SNAKEFILE, CONFIGFILE):
    resp = run_executable(
        executable='snakemake',
        arguments=[
            '-n',
            '-q',
            '--summary'
        ],
        parameters={
            'snakefile': SNAKEFILE,
            'cores': multiprocessing.cpu_count(),
            'configfile': CONFIGFILE,
        }
    )
    assert(resp['success'])

@pytest.mark.slow
def test_snakemake_run(SNAKEFILE, CONFIGFILE):
    resp = run_executable(
        executable='snakemake',
        parameters={
            'snakefile': SNAKEFILE,
            'cores': multiprocessing.cpu_count(),
            'configfile': CONFIGFILE
        }
    )
    print(resp)
    assert(resp['success'])
