import pathlib

FLYE_ASSEMBLY_OUTDIR = pathlib.Path(config['outdir']) / 'assemblies/flye'

rule flye:
    input:
       nanopore = rules.process_nanopore.output.ont
    params:
        flye_outdir = FLYE_ASSEMBLY_OUTDIR,
        num_polish = 1,
        original_fasta_filename = FLYE_ASSEMBLY_OUTDIR / 'assembly.fasta'
    output:
        assembly = FLYE_ASSEMBLY_OUTDIR / 'flye.fa'
    threads: workflow.cores
    run:
        shell(
            """
            flye \
            --nano-raw {input.nanopore} \
            --threads {threads} \
            --iterations {params.num_polish} \
            --plasmids \
            --out-dir {params.flye_outdir} 
            """
        )
        shell(
            """
            mv {params.original_fasta_filename} {output.assembly}
            """
        )
