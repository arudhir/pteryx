import pytest
import conftest
from conftest import *
import multiprocessing

def test_cli_interface():
    resp = call_executable(
        'pteryx',
        '-h'
    )
    assert(resp['success'])

def test_cli_select_target(MESOPLASMA_FORWARD_READS):
    resp = run_executable(
        executable='pteryx',
        arguments=['-n'],
        parameters={
            'ilmn': MESOPLASMA_FORWARD_READS,
            'targets': 'repair',
            'threads': multiprocessing.cpu_count()
        }
    )
