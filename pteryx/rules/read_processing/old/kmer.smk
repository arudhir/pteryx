include: 'illumina.smk'

rule kat:
    input:
        r1 = rules.process_illumina.output.r1,
        r2 = rules.process_illumina.output.r2,
        ont = rules.process_nanopore.output.ont
    output:
        ONT_READ_DIR / 'kmer/kat-gcp.mx.png'
    params:
        output_prefix = ONT_READ_DIR / 'kmer/kat-gcp',
        mer_len = 79
    run:
        section_header('Analyzing kmer frequencies')
        explanation('Plotting k-mer coverage vs GC count')
        run_executable(
            executable='kat',
            arguments=[
                'gcp',
                input.r1,
                input.r2,
                input.ont
            ],
            parameters={
                'output_prefix': params.output_prefix,
                'threads': workflow.cores,
                'mer_len': params.mer_len
            }
        )
