import subprocess
import pathlib

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
        return rules.porechop.output

rule download_nanopore:
    output:
        r1 = temp(Path(config['outdir']) / 'nanopore/raw/{sample}.fastq'),
    params:
        outdir = lambda wildcards: Path(config['outdir']) / f'nanopore/raw'
    run:
        shell(
            """
            fasterq-dump {wildcards.sample} -O {params.outdir}
            """
        )

rule concat_nanopore:
    input:
        r1 = expand(rules.download_nanopore.output, sample=config['ont'])
    output:
        ONT_READ_DIR / 'raw/ont.fq.gz'
    params:
        ONT_READ_DIR / 'raw'
    log:    
        ONT_READ_DIR / 'concat_nanopore.log'
    run:
        shell(
            """
            cat {params}/*.fastq | pigz > {output} 2> {log}
            """
        )

# rule sanitize_nanopore:
#     input:
#         rules.concat_nanopore.output
#     output:
#         ONT_READ_DIR / 'raw/ont.clean.fq.gz'
#     threads: workflow.cores
#     log: ONT_READ_DIR / 'sanitize.log'
#     run:
#         shell(
#             'seqkit sana {input} -o {output} 2> {log}'
#         )

rule filtlong:
    input:
        raw_ont = rules.concat_nanopore.output
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
        ont = rules.filtlong.output
    output:
        temp(ONT_READ_DIR / 'porechop_out/ont.trimmed.fq.gz')
    threads: workflow.cores
    log:
        ONT_READ_DIR / 'porechop.log'
    params:
        porechop_output = ONT_READ_DIR / 'porechop_out/ont.trimmed.fq'
    run:
        shell(
            """
            porechop \
            -i {input.ont} \
            -o {params.porechop_output} \
            --require_two_barcodes \
            -t {threads} \
            > {log}
            """
        )

        shell(
            """
            pigz {params.porechop_output}
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
