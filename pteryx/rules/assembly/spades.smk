import pathlib
# from ginkgo_common.utils import run_executable

ASSEMBLY_OUTDIR = pathlib.Path(config['outdir']) / 'assemblies'

rule spades:
    input:
       r1 = rules.process_illumina.output.r1,
       r2 = rules.process_illumina.output.r2,
    output:
        assembly = ASSEMBLY_OUTDIR / 'spades/spades.fa'
    params:
        outdir = ASSEMBLY_OUTDIR / 'spades',
        original_fasta_filename = ASSEMBLY_OUTDIR / 'spades/contigs.fasta'
    threads: 16  # https://www.biostars.org/p/267228/
    run:
        shell(
            'spades.py '
            '-1 {input.r1} '
            '-2 {input.r2} '
            '-t {threads} '
            '-o {params.outdir} '
        )

        shell(
            'mv {params.original_fasta_filename} {output.assembly}'
        )

rule biosyntheticspades:
    input:
       r1 = rules.process_illumina.output.r1,
       r2 = rules.process_illumina.output.r2,
    output:
        assembly = ASSEMBLY_OUTDIR / 'biosyntheticspades/biosyntheticspades.fa'
    params:
        outdir = ASSEMBLY_OUTDIR / 'biosyntheticspades',
        original_fasta_filename = ASSEMBLY_OUTDIR / 'biosyntheticspades/raw_contigs.fasta'
    threads: 16  # https://www.biostars.org/p/267228/
    run:
        shell(
            'spades.py '
            '-1 {input.r1} '
            '-2 {input.r2} '
            '-t {threads} '
            '-o {params.outdir} '
            '--bio'
        )
        shell(
            'mv {params.original_fasta_filename} {output.assembly}'
        )

rule metaspades:
    input:
       r1 = rules.process_illumina.output.r1,
       r2 = rules.process_illumina.output.r2,
    output:
        assembly = ASSEMBLY_OUTDIR / 'metaspades/metaspades.fa'
    params:
        outdir = ASSEMBLY_OUTDIR / 'metaspades',
        original_fasta_filename = ASSEMBLY_OUTDIR / 'metaspades/contigs.fasta'
    threads: 16  # https://www.biostars.org/p/267228/
    run:
        run_executable(
            executable='spades.py',
            arguments=[
                '-1', input.r1,
                '-2', input.r2,
                '-t', threads,
                '-o', params.outdir,
                '--meta'
            ]
        )

        run_executable(
            executable='mv',
            arguments=[
                params.original_fasta_filename,
                output.assembly
            ]
        )
