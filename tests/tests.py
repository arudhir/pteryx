import os
import pteryx
import subprocess

def test_commandline():
    subprocess.check_call(
        '''
        pteryx --help
        ''', shell=True
    )