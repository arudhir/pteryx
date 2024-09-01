rule canu_correct:
    output:
        canu_reads_fasta = f'{outdir}/reads/nanopore/{config["name"]}.correctedReads.fasta.gz',
    params:
        canu_dir = f'{outdir}/reads/nanopore',
        genomeSize = config['size']
    log: f'{outdir}/logs/canu-correct.log'
    run:
        explanation('Correcting long reads with canu -correct')
        shell(
            """
            canu -correct \
            -nanopore-raw {config[nanopore]} \
            genomeSize={params.genomeSize} \
            -p {config[name]} \
            -d {params.canu_dir} \
            &> {log}
            """
        )
        
rule compress_canu:
    input:
        rules.canu_correct.output.canu_reads_fasta
    output:
        f'{outdir}/reads/nanopore/{config["name"]}.correctedReads.fq.gz'
    run:
        # Convert the FASTA that Canu makes corrected reads as to a FASTQ with fake quality scores
        explanation('Convert .fasta --> .fq.gz')
        shell(
            """
            seqtk seq -F "#" {input} | pigz > {output}
            """
        )
