rule quast:
    input:
        assemblies = pass
        r1 = pass,
        r2 = pass,
        ont = pass,
    output:
        report = f'{outdir}/quast/report.tsv'
    params:
        outdir = f'{outdir}/quast'
    threads: workflow.cores * 0.1
    log: f'{outdir}/quast.log'
    run:
        shell(
            'quast.py {input} '
            '-o {params.outdir} '
            '-t {threads} '
            '&> {log}'
        )
