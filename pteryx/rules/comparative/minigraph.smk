rule minigraph:
    input:
        polished_assemblies = (
            expand(
                rules.pilon.output.polished_assembly,
                assembler=glob_wildcards(f'{outdir}/assemblies/gathered_assemblies/{config["name"]}_{{assembler}}.fa').assembler
            )
        ),
    output:
        f'{outdir}/comparative/{config["name"]}.gfa'
    params:
        temp(f'{outdir}/comparative/{config["name"]}.gfa.tmp')
    threads: workflow.cores
    run:
        section_header('minigraph')
        shell(
            'minigraph {input.polished_assemblies} -xggs -t {threads} > {params} '
            '&& echo -e "H\tVN:Z:1.0" | cat - {params} > {output}'
        )

