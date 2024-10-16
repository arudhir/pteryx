import json
from glob import glob
import pathlib
import os

ILMN_READ_DIR = Path(config['outdir']) / 'illumina'

def total_memory_gb():
    """Doing it this way because psutil is having some weird issue
    https://github.com/giampaolo/psutil/issues/1288
    """
    mem_bytes = os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES')
    mem_gib = mem_bytes/(1024.**3)  
    return mem_gib


def _is_file(val):
    return Path(val).exists()
    

rule download_illumina:
    output:
        r1 = temp(Path(config['outdir']) / 'illumina/raw/{sample}_1.fastq'),
        r2 = temp(Path(config['outdir']) / 'illumina/raw/{sample}_2.fastq')
    params:
        outdir = Path(config['outdir']) / 'illumina/raw'
    run:
        shell(
            """
            fastq-dump --split-files {wildcards.sample} -O {params.outdir}
            """
        )


rule concat_ilmn:
    input:
        r1 = expand(rules.download_illumina.output.r1, sample=config['ilmn']),
        r2 = expand(rules.download_illumina.output.r2, sample=config['ilmn'])
    output:
        r1 = ILMN_READ_DIR / 'concat_reads/1.fq.gz',
        r2 = ILMN_READ_DIR / 'concat_reads/2.fq.gz'
    params:
        ILMN_READ_DIR / 'raw'
    run:
        shell(
            """
            cat {input.r1} | pigz > {output.r1}
            cat {input.r2} | pigz > {output.r2}
            """
        )

rule repair:
    input:
        r1 = rules.concat_ilmn.output.r1,
        r2 = rules.concat_ilmn.output.r2
    output:
        r1 = ILMN_READ_DIR / 'repaired_reads/1.repaired.fq.gz',
        r2 = ILMN_READ_DIR / 'repaired_reads/2.repaired.fq.gz',
    run:
        # import ipdb; ipdb.set_trace()
        shell(
            """
            repair.sh \
            in1={input.r1} \
            in2={input.r2} \
            out1={output.r1} \
            out2={output.r2} \
            pigz=f \
            unpigz=f \
            -da
            """
        )

rule dedupe:
    input:
        r1 = rules.repair.output.r1,
        r2 = rules.repair.output.r2
    output:
        r1 = ILMN_READ_DIR / 'deduped_reads/1.deduped.fq.gz',
        r2 = ILMN_READ_DIR / 'deduped_reads/2.deduped.fq.gz',
    resources: 
        memory = int(total_memory_gb() * 0.7)  # 70% of total RAM in GB
    run:
        shell(
            """
            clumpify.sh \
            in1={input.r1} \
            in2={input.r2} \
            out1={output.r1} \
            out2={output.r2} \
            dedupe \
            Xmx{resources.memory}g
            """
        )

rule normalize:
    input:
        r1 = rules.dedupe.output.r1,
        r2 = rules.dedupe.output.r2
    output:
        r1 = ILMN_READ_DIR / 'normalized_reads/1.normalized.fq.gz',
        r2 = ILMN_READ_DIR / 'normalized_reads/2.normalized.fq.gz',
    threads: workflow.cores
    resources: 
        memory = int(total_memory_gb() * 0.7)  # 70% of total RAM in GB
    run:
        shell(
            """
            bbnorm.sh \
            in1={input.r1} \
            in2={input.r2} \
            out1={output.r1} \
            out2={output.r2} \
            threads={threads} \
            target=100 \
            min=5 \
            """
        )

rule fastp:
    input:
        r1 = rules.normalize.output.r1,
        r2 = rules.normalize.output.r2
    output:
        r1 = ILMN_READ_DIR / 'fastp/1.fastp.fq.gz',
        r2 = ILMN_READ_DIR / 'fastp/2.fastp.fq.gz',
        json = ILMN_READ_DIR / 'fastp/fastp.json',
        html = ILMN_READ_DIR / 'fastp/fastp.html'
    threads: workflow.cores
    run:
        shell(
            'fastp '
            '-i {input.r1} '
            '-I {input.r2} '
            '-o {output.r1} '
            '-O {output.r2} '
            '--json {output.json} '
            '--html {output.html}'
        )

rule process_illumina:
    input:
        r1 = rules.fastp.output.r1,
        r2 = rules.fastp.output.r2,
    output:
        r1 = ILMN_READ_DIR / 'processed_reads/1.ilmn.fq.gz',
        r2 = ILMN_READ_DIR / 'processed_reads/2.ilmn.fq.gz',
    params:
        processed_read_dir = ILMN_READ_DIR / 'processed_reads'
    run:
        shell('cp {input.r1} {output.r1}')
        shell('cp {input.r2} {output.r2}')
