from pathlib import Path
rule prokka:
    input:
        rules.pilon.output.polished_assembly,
    output:
        gff = f'{outdir}/annotations/{{assembler}}_prokka/{{assembler}}.gff'
    params:
        outdir = f'{outdir}/annotations/{{assembler}}_prokka'
    log: f'{outdir}/logs/prokka_{{assembler}}.log'
    run:
        section_header(f'Annotating {input} with Prokka')
        prefix = Path(wildcards.assembler).stem
        shell(
            f'prokka {{input}} '
            f'--outdir {{params.outdir}} '
            f'--prefix {prefix} '
            f'--centre X --compliant '  # To deal with headers >37 chars
            f'--force '
            f'&> {log}'
        )
