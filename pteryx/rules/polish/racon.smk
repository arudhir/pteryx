rule racon_polish:
    input:
        reads = rules.process_nanopore.output.ont,
        assembly = f"{outdir}/assemblies/{{assembler}}/{{assembler}}.fa"
    output:
        polished_assembly = f"{outdir}/assemblies/{{assembler}}/{{assembler}}.polished.fa"
    params:
        threads = workflow.cores * 0.2,
        num_iterations = config.get('num_racon_iterations', 3),
        minimap2_paf = f"{outdir}/assemblies/{{assembler}}/{{assembler}}.paf",
        before = f"{outdir}/assemblies/{{assembler}}/before.fa",
        after = f"{outdir}/assemblies/{{assembler}}/after.fa"
    run:
        shell('cp {input.assembly} {params.before}')
        for i in range(params.num_iterations):
            shell(
                """
                minimap2 -t {threads} -x map-ont {input.reads} {params.before} > {params.minimap2_paf}
                """
            )
            shell(
                """
                racon  -t {threads} {input.reads} {params.minimap2_paf} {params.before} > {params.after}
                """
            )

            shell('cp {params.after} {params.before}')
        
        # After polishing, rename the result to become the output
        shell('mv {params.after} {output.polished_assembly}')
            
