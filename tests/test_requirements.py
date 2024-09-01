import pathlib
import pytest
import conftest
from conftest import *
from ginkgo_common.utils import setup_batch_env, run_executable

FIXTURE_DIR = conftest.FIXTURE_DIR

def test_canu_exists():
    assert(
        run_executable('canu', ['-version'])['success'] == True
    )

def test_flye_exists():
    assert(
        run_executable('flye', ['--version'])['success'] == True
    )

def test_spades_exists():
    assert(
        run_executable('spades.py', ['--version'])['success'] == True
    )

def test_unicycler_exists():
    assert(
        run_executable('unicycler', ['--version'])['success'] == True
    )

def test_skesa_exists():
    assert(
        run_executable('skesa', ['--version'])['success'] == True
    )