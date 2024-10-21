import pytest
import conftest
from conftest import *
import multiprocessing
import subprocess
def test_snakemake_dryrun(SNAKEFILE, CONFIGFILE):
    command = [
        'snakemake',
        '-n',
        '-q',
        '--summary',
        '--snakefile', SNAKEFILE,
        '--cores', str(multiprocessing.cpu_count()),
        '--configfile', CONFIGFILE
    ]

    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        success = True
        stdout = result.stdout
        stderr = result.stderr
    except subprocess.CalledProcessError as e:
        success = False
        stdout = e.stdout
        stderr = e.stderr

    assert success, f"Snakemake dry run failed. Error: {stderr}"

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
