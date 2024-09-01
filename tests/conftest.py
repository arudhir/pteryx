import os
import pathlib
import pytest
from ginkgo_common.utils import setup_batch_env, run_executable

BASE_DIR = pathlib.Path(__file__).parent
FIXTURE_DIR = BASE_DIR / 'fixtures'

@pytest.fixture(scope='session')
def fixture_dir():
    return FIXTURE_DIR

@pytest.fixture
def SNAKEFILE():
    return 'pteryx/Snakefile'

@pytest.fixture
def CONFIGFILE():
    return FIXTURE_DIR / 'mesoplasma/config.yml'

# @pytest.fixture
# def CONFIGFILE():
    # return FIXTURE_DIR / 'huue/config.yml'

@pytest.fixture(scope='session')
def MESOPLASMA_FORWARD_READS():
    return FIXTURE_DIR / 'mesoplasma/mesoplasma_simulated.1.paired.fq.gz'

@pytest.fixture(scope='session')
def MESOPLASMA_NANOPORE_READS():
    return FIXTURE_DIR / 'mesoplasma/mesoplasma.ont.fq.gz'
# https://docs.pytest.org/en/latest/example/simple.html#control-skipping-of-tests-according-to-command-line-option--
def pytest_addoption(parser):
    parser.addoption(
        "--runslow", action="store_true", default=False, help="run slow tests"
    )


def pytest_configure(config):
    config.addinivalue_line("markers", "slow: mark test as slow to run")


def pytest_collection_modifyitems(config, items):
    if config.getoption("--runslow"):
        # --runslow given in cli: do not skip slow tests
        return
    skip_slow = pytest.mark.skip(reason="need --runslow option to run")
    for item in items:
        if "slow" in item.keywords:
            item.add_marker(skip_slow)
