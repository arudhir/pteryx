import os
from snakemake.shell import shell
print('hi')
shell("echo hello world >> {snakemake.output}")

