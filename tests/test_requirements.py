import pathlib
import pytest
import subprocess
import conftest
from conftest import *

FIXTURE_DIR = conftest.FIXTURE_DIR


def run_command(command, arguments):
    try:
        result = subprocess.run([command] + arguments, check=True, capture_output=True, text=True)
        return {'success': True, 'stdout': result.stdout, 'stderr': result.stderr}
    except subprocess.CalledProcessError as e:
        return {'success': False, 'stdout': e.stdout, 'stderr': e.stderr}

def test_canu_exists():
    assert run_command('canu', ['-version'])['success'] == True

def test_flye_exists():
    assert run_command('flye', ['--version'])['success'] == True

def test_spades_exists():
    assert run_command('spades.py', ['--version'])['success'] == True

def test_unicycler_exists():
    assert run_command('unicycler', ['--version'])['success'] == True

def test_skesa_exists():
    assert run_command('skesa', ['--version'])['success'] == True