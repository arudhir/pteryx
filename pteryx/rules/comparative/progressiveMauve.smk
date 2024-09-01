rule progressiveMauve:
    input:
        polished_assemblies = (
            expand(
                rules.pilon.output.polished_assembly,
                assembler=glob_wildcards(f'{outdir}/assemblies/gathered_assemblies/{config["name"]}_{{assembler}}.fa').assembler
            )
        ),
    output:
        xmfa = f'{outdir}/comparative/{config["name"]}.xmfa',
        backbone = f'{outdir}/comparative/{config["name"]}.xmfa.backbone',
        sslist = f'{outdir}/comparative/{config["name"]}.xmfa.bbcols'
    params:
        weight = 5000,
        min_recursive_gap_length = 5000
    threads: workflow.cores
    run:
        section_header('progressiveMauve')
        shell(
            'progressiveMauve {input.polished_assemblies} '
            '--weight={params.weight} '
            'min-recursive-gap-length={params.min_recursive_gap_length} '
            '--output {output.xmfa}'
        )

