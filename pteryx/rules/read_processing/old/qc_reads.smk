rule fastqc:
    input:
        r1_normalized = rules.normalize_reads.output.r1_normalized,
        r2_normalized = rules.normalize_reads.output.r2_normalized
    params:
        fastqc_pat = f'{outdir}/reads/illumina/normalized_reads/*_normalized.*.fq.gz',
        fastqc_dir = f'{outdir}/reads/processed_reads/illumina/fastqc'
    output:
        r1_fastqc = f'{outdir}/reads/processed_reads/illumina/fastqc/{config["name"]}_normalized.1_fastqc.html',
        r2_fastqc = f'{outdir}/reads/processed_reads/illumina/fastqc/{config["name"]}_normalized.2_fastqc.html'
    threads: workflow.cores
    run:
        section_header('FastQC')
        os.makedirs(params.fastqc_dir, exist_ok=True)
        shell(
            'fastqc {params.fastqc_pat} '
            '--outdir={params.fastqc_dir} '
            '--threads {threads} '
            '&> /dev/null'
        )

rule multiqc:
    input:
        r1_fastqc = rules.fastqc.output.r1_fastqc,
        r2_fastqc = rules.fastqc.output.r2_fastqc
    params:
        fastqc_dir = directory(f'{outdir}/reads/processed_reads/illumina/fastqc/'),
        multiqc_dir = directory(f'{outdir}/reads/processed_reads/illumina/multiqc/'),
        processed_illumina_dir = directory(f'{outdir}/reads/processed_reads/illumina')
    output:
        multiqc_txt = f'{outdir}/reads/processed_reads/illumina/multiqc/multiqc_data/multiqc_fastqc.txt'
    run:
        section_header('MultiQC')
        for f in glob(params.fastqc_dir + '*'):  # Until MultiQC fixes this issue...
            if os.stat(f).st_size < 60000:
                print(f'It seems the FastQC file {f} is empty! Deleting it...')
                os.remove(f)
        shell(
            'export LC_ALL=C.UTF-8;'
            'export LANG=C.UTF-8;'
            'multiqc {params.fastqc_dir} '
            '-o {params.multiqc_dir} --ignore *done -f '
            '&> /dev/null'
        )

#        explanation('Uploading Illumina reads to S3')
#        upload_s3_asset(
#            asset=params.processed_illumina_dir,
#            path=config['s3_dir'],
#            bucket=config['bucket'],
#            is_dir=True
#        )

rule nanoplot:
    input:
        rules.process_nanopore.output.processed_long_reads
    output:
        f'{outdir}/reads/processed_reads/nanopore/NanoStats.txt'
    params:
        out = f'{outdir}/reads/processed_reads/nanopore',
        processed_nanopore_dir = directory(f'{outdir}/reads/processed_reads/nanopore')
    log:
        f'{outdir}/logs/{config["name"]}_nanoplot.log'
    threads: workflow.cores
    run:
        shell(
            """
            NanoPlot \
                --fastq {input} \
                --loglength \
                --outdir {params.out} \
                -t {threads} \
                2> {log}
            """
        )
#        explanation('Uploading Nanopore reads to S3')
#        upload_s3_asset(
#            asset=params.processed_nanopore_dir,
#            path=config['s3_dir'],
#            bucket=config['bucket'],
#            is_dir=True
#        )
