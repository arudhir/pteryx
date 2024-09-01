rule busco:
    input:
        lambda wildcards: aggregate_checkpoint(wildcards)
    output:
        outdir = directory(f'{outdir}/busco/{{assembler}}')
    params:
        config = '/tools/busco/config/config.ini',
        busco_dir = f'{outdir}/busco'
    log: f'{outdir}/busco_{{assembler}}.log'
    threads: workflow.cores * 0.1
    run:
        section_header(f'BUSCO for {input}')
        # I don't think the way BUSCO downloads files is thread-safe so keeping it
        # offline for now
        shell(
            'busco '
            '--in {input} '
            '--out {wildcards.assembler} '
            '--out_path {params.busco_dir} '
            '--mode genome '
            '--lineage {config[lineage]} '
            '--config {params.config} '
            '--cpu {threads} '
            '--force '
            '--quiet '
            '--offline '
            '&> {log}'
        )
