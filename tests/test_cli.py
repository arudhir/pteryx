import pytest
import subprocess
import multiprocessing
from conftest import *

def run_command(command, arguments=None, parameters=None):
    full_command = [command]
    if arguments:
        full_command.extend(arguments)
    if parameters:
        for key, value in parameters.items():
            full_command.extend([f'--{key}', str(value)])
    
    try:
        result = subprocess.run(full_command, check=True, capture_output=True, text=True)
        return {'success': True, 'stdout': result.stdout, 'stderr': result.stderr}
    except subprocess.CalledProcessError as e:
        return {'success': False, 'stdout': e.stdout, 'stderr': e.stderr}

def test_cli_interface():
    resp = run_command('pteryx', ['-h'])
    assert resp['success'], f"CLI interface test failed. Error: {resp.get('stderr', '')}"

def test_cli_select_target(MESOPLASMA_FORWARD_READS):
    resp = run_command(
        'pteryx',
        arguments=['-n'],
        parameters={
            'ilmn': MESOPLASMA_FORWARD_READS,
            'targets': 'repair',
            'threads': multiprocessing.cpu_count()
        }
    )
    assert resp['success'], f"CLI select target test failed. Error: {resp.get('stderr', '')}"