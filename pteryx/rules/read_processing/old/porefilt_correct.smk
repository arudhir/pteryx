rule preprocess_checks:
    output:
        formed_minion = f'{outdir}/reads/{config["name"]}_formed.fastq',
        dedupe = f'{outdir}/reads/preprocess_out/{config["name"]}_dedupe.fastq',
        processed_fastq = f'{outdir}/reads/preprocess_out/{config["name"]}_fixed.fastq.gz'
    threads: workflow.cores
    params:
        unzipped_processed = f'{outdir}/reads/preprocess_out/{config["name"]}_fixed.fastq'
    log:
        f'{outdir}/logs/preprocess.log'
    run:
        shell(
            f"""
            python3 scripts/discard_malformed_fastq_py3.py {{config[nanopore]}} {log} > {{output.formed_minion}}
            seqkit rmdup \
                -j {threads} {{output.formed_minion}} \
                > {{output.dedupe}} 2> {log}
            wc -l {{output.dedupe}} >> {{log}}
            python scripts/clean_fastq_records.py {{output.dedupe}} > {{params.unzipped_processed}}
            wc -l {{params.unzipped_processed}} >> {{log}}
            pigz {{params.unzipped_processed}}
            """
        )

rule porefilt:
    input:
        rules.preprocess_checks.output.processed_fastq
    output:
        porechop = f'{outdir}/reads/porechop_out/{config["name"]}_trimmed.fastq.gz',
        filtlong = f'{outdir}/reads/filtlong_out/{config["name"]}_filtered.fastq',
    params:
        size = int(value_to_float(config['size']) * 50)
    log:
        f'{outdir}/logs/porechop.log'
    threads: workflow.cores
    shell:
        """
        porechop \
            -i {input} \
            -o {output.porechop} \
            --threads {threads} \
            2> {log}
        echo 'porechop done'
        filtlong \
            --min_length 1500 \
            --keep_percent 90 \
            --target_bases {params.size} {output.porechop} \
            > {output.filtlong} 2> {log}
        echo 'filtlong done'
        """

rule compress_filtlong:
    input:
        filtlong = rules.porefilt.output.filtlong
    output:
        f'{outdir}/reads/porefilt/nanopore/ont.fq.gz'
    run:
        shell(
            """
            cat {output.filtlong} | pigz > {output}
            """
        )
