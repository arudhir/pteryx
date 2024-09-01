import pathlib
import shutil
import os
ASSEMBLY_DIR = pathlib.Path(config['outdir']) / 'assemblies'

rule shasta:
    input:
       nanopore = rules.process_nanopore.output.ont
    output:
        assembly = ASSEMBLY_DIR / 'shasta/shasta.fa'
    params:
        shasta_outdir = ASSEMBLY_DIR / 'shasta',
        original_fasta_name = ASSEMBLY_DIR / 'shasta/Assembly.fasta'
    run:
        # If Shasta fails, it'll still make the output directory
        # so we need to remove it
        if os.path.exists(params.shasta_outdir):
            shutil.rmtree(params.shasta_outdir)

        # Shasta wants an unzipped file
        shell(
            'gunzip --keep {input} --force'  # We want to keep the gz file and overwrite something that's already been compressed
        )

        uncompressed_long_reads = pathlib.Path(input.nanopore).with_suffix('')  # Remove the .gz extension from the input
        shell(
            'shasta-Linux-0.6.0 '
            f'--input {uncompressed_long_reads} '
            '--assemblyDirectory {params.shasta_outdir} '
            '--MarkerGraph.minCoverage 25 '
            '--Assembly.iterative '
            '--Assembly.iterative.iterationCount 5 ' 
            '&& mv {params.original_fasta_name} {output.assembly}'
        )
