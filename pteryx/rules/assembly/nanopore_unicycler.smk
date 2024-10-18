import pathlib

ASSEMBLY_OUTDIR = pathlib.Path(config['outdir']) / 'assemblies'
rule nanopore_unicycler:
    input:
        nanopore = rules.process_nanopore.output.ont
    output:
        assembly = ASSEMBLY_OUTDIR / 'nanopore_unicycler/nanopore_unicycler.fa'
    params:
        outdir = ASSEMBLY_OUTDIR / 'nanopore_unicycler',
        original_fasta_name = ASSEMBLY_OUTDIR / 'nanopore_unicycler/assembly.fasta'
    threads: workflow.cores
    run:
        shell(
            """
            unicycler \
            --long {input.nanopore} \
            --out {params.outdir} \
            --threads {threads} \
            --mode normal \
            --verbosity 2 \
            --keep 2
            """
        )

        shell(
            'mv {params.original_fasta_name} {output.assembly}'
        )
