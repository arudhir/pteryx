import subprocess
import pathlib
from ginkgo_common.utils import run_executable

ONT_READ_DIR = pathlib.Path(config['outdir']) / 'nanopore'

def pick_preprocessing_strategy(config):
    """
    Pick which Nanopore processing module you want to run based on what was
    passed on the command line

    This is neat b/c I didn't know you could return rule outputs like this
    and selectively run portions of the pipeline and modularize like this.
    """
    if config.get('canu_correct'):
        return rules.compress_canu.output
    else:
        return rules.filtlong.output


# rule download_nanopore:
#     output:
#         ont = ONT_READ_DIR / 'datastore/{sample}.ont.fq.gz'
#     params:
#         ONT_READ_DIR
#     run:
#         if Path(config['ont']).exists():
#             shell(
#                 """
#                 cp {config[ont]} {output.ont}
#                 """
#             )
#         else:
#             shell(
#                 f"""
#                 download-ngs-files sample {wildcards.sample} -o {params}
#                 mv {params}/*.fastq.gz {output.ont}
#                 """
#             )

rule concat_nanopore:
    output:
        ONT_READ_DIR / 'raw/ont.datastore.fq.gz'
    params:
        ONT_READ_DIR / 'raw'
    log:    
        ONT_READ_DIR / 'concat_nanopore.log'
    run:
        shell(
            """
            zcat {params}/*ont* | pigz > {output} 2> {log}
            """
        )

rule sanitize_nanopore:
    input:
        rules.concat_nanopore.output
    output:
        ONT_READ_DIR / 'datastore/ont.clean.fq.gz'
    threads: workflow.cores
    log: ONT_READ_DIR / 'sanitize.log'
    run:
        shell(
            'seqkit sana {input} | pigz > {output} 2> {log}'
        )

rule filtlong:
    input:
        raw_ont = rules.sanitize_nanopore.output
    output:
        temp(ONT_READ_DIR / 'filtlong/ont.filtlong.fq.gz')
    params:
        size = int(value_to_float(config.get('size', '5M')) * 50),
        min_length = 1500,
        keep_percent = 90
    log:
        ONT_READ_DIR / 'filtlong.log'
    run:
        shell(
            """
            filtlong \
            {input} \
            --min_length {params.min_length} \
            --keep_percent {params.keep_percent} \
            --target_bases {params.size} \
            | pigz \
            > {output}
            """
        )

rule porechop:
    input:
        rules.filtlong.output
    output:
        temp(ONT_READ_DIR / 'porechop_out/ont.trimmed.fq')
    threads: workflow.cores
    log:
        ONT_READ_DIR / 'porechop.log'
    run:
        shell(
            """
            porechop \
            -i {input.raw_ont} \
            -o {output} \
            --require_two_barcodes \
            -t {threads} \
            > {log}
            """
        )

rule canu_correct:
    input:
        rules.porechop.output
    output:
        canu_reads_fasta = temp(ONT_READ_DIR / 'canu_corr/ont.correctedReads.fasta.gz'),  # TODO: Fix this name
    params:
        canu_dir = ONT_READ_DIR / 'canu_corr',
        genomeSize = config.get('size', '5M')
    run:
        shell(
            """
            canu -correct -nanopore-raw {input} \
            -p {config[name]} -d {params.canu_dir} \
            genomeSize={params.genomeSize}
            """
        )
        # Using run_executable errors out but shell() works

rule compress_canu:
    input:
        rules.canu_correct.output.canu_reads_fasta
    output:
        temp('{outdir}/reads/nanopore/ont.correctedReads.fq.gz')
    run:
        # Convert the FASTA that Canu makes corrected reads as to a FASTQ with fake quality scores
        shell(
            """
            seqtk seq -F "#" {input} | pigz > {output}
            """
        )

rule process_nanopore:
    input:
        pick_preprocessing_strategy(config)
    output:
        ont = ONT_READ_DIR / 'processed_reads/ont.fq.gz'
    run:
        shell(
            """
            cp {input} {output.ont}
            """
        )