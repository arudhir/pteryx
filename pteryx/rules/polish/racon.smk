rule racon_polish:
    input:
        reads = rules.process_nanopore.output.ont
        assembly = f"{outdir}/assemblies/{{assembler}}/{{assembler}}.fa"
    output:
        polished_assembly = f"{outdir}/assemblies/{{assembler}}/{{assembler}}.polished.fa"
    params:
        threads = 8,
        num_iterations = 5
    run:
        for i in range(params.num_iterations):
            shell(
                """
            racon {input.reads} {input.assembly} {output.polished_assembly} -t {threads}
                """
            )
            input.assembly = output.polished_assembly
            
