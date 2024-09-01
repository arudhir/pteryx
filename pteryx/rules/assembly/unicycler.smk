import pathlib
from ginkgo_common.utils import run_executable

ASSEMBLY_OUTDIR = pathlib.Path(config['outdir']) / 'assemblies'

rule unicycler:
    input:
       r1 = rules.process_illumina.output.r1,
       r2 = rules.process_illumina.output.r2,
       nanopore = rules.process_nanopore.output.ont
    output:
        assembly = ASSEMBLY_OUTDIR / 'unicycler/unicycler.fa'
    params:
        outdir = ASSEMBLY_OUTDIR / 'unicycler',
        spades_path = '/tools/SPAdes-3.13.0-Linux/bin/spades.py',
        original_fasta_name = ASSEMBLY_OUTDIR / 'assembly.fasta'
    threads: workflow.cores
    run:
        run_executable(
            executable='unicycler',
            arguments=[
                '--no_pilon'
            ],
            parameters={
                'short1': input.r1,
                'short2': input.r2,
                'long': input.nanopore,
                'out': params.outdir,
                'spades_path': params.spades_path,
                'verbosity': 2,
                'keep': 2,
                'threads': threads,
                'mode': 'normal'
            }
        )

        run_executable(
            'mv', [params.original_fasta_name, output.assembly]
        )
#        for mode in ['bold', 'normal', 'conservative']:
#            section_header(f'Unicycler-{mode}')
#            run_executable(
#                executable='unicycler',
#                parameters={
#                    'short1': input.r1,
#                    'short2': input.r2,
#                    'long': input.nanopore,
#                    'out': params.outdir,
#                    'spades_path': params.spades_path,
#                    'verbosity': 2,
#                    'keep': 2,
#                    'threads': threads,
#                    'mode': mode
#                }
#            )

#            """
#            unicycler \
#            -1 {input.r1} \
#            -2 {input.r2} \
#            -l {input.nanopore} \
#            -o {params.outdir} \
#            --spades_path {params.spades_path} \
#            --verbosity 2 \
#            --keep 2 \
#            --threads {threads} \
#            --mode {params.mode} \
#            &> {log} \
#            && touch {output}
#            """
#        )
#
#        shell(
#            """
#            mv {params.original_fasta_name} {output}
#            """
#        )
