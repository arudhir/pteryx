import pathlib

ASSEMBLY_OUTDIR = pathlib.Path(config['outdir']) / 'assemblies'

rule hybrid_unicycler:
    input:
       r1 = rules.process_illumina.output.r1,
       r2 = rules.process_illumina.output.r2,
       nanopore = rules.process_nanopore.output.ont
    output:
        assembly = ASSEMBLY_OUTDIR / 'hybrid_unicycler/hybrid_unicycler.fa'
    params:
        outdir = ASSEMBLY_OUTDIR / 'hybrid_unicycler',
        spades_path = '/tools/SPAdes-3.13.0-Linux/bin/spades.py',
        original_fasta_name = ASSEMBLY_OUTDIR / 'hybrid_unicycler/assembly.fasta'
    threads: workflow.cores
    run:
        shell(
            """
            unicycler \
            --short1 {input.r1} \
            --short2 {input.r2} \
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