import pathlib
from ginkgo_common.utils import run_executable

SKESA_OUTDIR = pathlib.Path(config['outdir']) / 'assemblies/skesa'
rule skesa:
    input:
        r1 = rules.process_illumina.output.r1,
        r2 = rules.process_illumina.output.r2,
    output:
        assembly = SKESA_OUTDIR / 'skesa.fa'
    params:
        memory = 100
    threads: workflow.cores
    run:
        shell(
            """
            skesa \
                --reads {input.r1},{input.r2} \
                --cores {threads} \
                --memory {params.memory} \
            > {output.assembly} \
            """
        )
