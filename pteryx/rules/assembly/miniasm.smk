import pathlib

ASSEMBLY_OUTDIR = pathlib.Path(config['outdir']) / 'assemblies/miniasm'

rule miniasm:
    input:
        nanopore = rules.process_nanopore.output.ont
    output:
        overlaps = ASSEMBLY_OUTDIR / 'overlaps.paf.gz',
        gfa = ASSEMBLY_OUTDIR / 'miniasm.gfa',
        assembly = ASSEMBLY_OUTDIR / 'miniasm.fa'
    threads: workflow.cores
    run:
        # Calculate overlaps with Minimap2
        shell(
            """
            minimap2 -x ava-ont {input.nanopore} {input.nanopore} \
                -t 40 \
                | pigz > {output.overlaps} 2> /dev/null
            """
        )

        # Create unitig GFA with miniasm
        shell(
            """
            miniasm -f {input.nanopore} {output.overlaps} > {output.gfa} 
            """
        )

        # Convert GFA to FASTA
        shell(
            """
            /usr/src/pteryx/pteryx/workflow/gfa2fasta.awk {output.gfa} > {output.assembly}
            """
        )
