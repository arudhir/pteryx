import pathlib
CANU_ASSEMBLY_DIR = pathlib.Path(config['outdir']) / 'assemblies/canu'

rule canu:
    input:
        nanopore = rules.process_nanopore.output.ont
    output:
        assembly = CANU_ASSEMBLY_DIR / 'canu.fa'
    params:
        canu_outdir = CANU_ASSEMBLY_DIR,
        original_fasta_name = CANU_ASSEMBLY_DIR / 'canu.contigs.fasta',
        size = config.get('size', '5M')
    threads: workflow.cores
    log: CANU_ASSEMBLY_DIR / 'canu.log'
    run:
        shell(
            """
            canu -assemble -nanopore-corrected {input.nanopore} \
                -genomeSize={params.size} \
                -p canu \
                -d {params.canu_outdir} \
            &> {log}
            """
        )

        shell(
            """
            mv {params.original_fasta_name} {output.assembly}
            """
        )
