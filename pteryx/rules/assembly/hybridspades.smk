import pathlib
from ginkgo_common.utils import run_executable

ASSEMBLY_OUTDIR = pathlib.Path(config['outdir']) / 'assemblies'

rule hybridspades:
    input:
       r1 = rules.process_illumina.output.r1,
       r2 = rules.process_illumina.output.r2,
    output:
        assembly = ASSEMBLY_OUTDIR / 'hybridspades/hybridspades.fa'
    params:
        outdir = ASSEMBLY_OUTDIR / 'hybridspades',
        original_fasta_filename = ASSEMBLY_OUTDIR / 'hybridspades/contigs.fasta'
    threads: 16  # https://www.biostars.org/p/267228/
    run:
        run_executable(
            executable='spades.py',
            arguments=[
                '-1', input.r1,
                '-2', input.r2,
                '-t', threads,
                '-o', params.outdir,
            ]
        )

        run_executable(
            executable='mv',
            arguments=[
                params.original_fasta_filename,
                output.assembly
            ]
        )