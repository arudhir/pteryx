import os
from snakemake.shell import shell
from ginkgo_common.utils import run_executable

ret = run_executable(
    executable='dedupe.sh',
    arguments=[f'in={snakemake.input}', f'out={snakemake.output}']
)
print(ret)
