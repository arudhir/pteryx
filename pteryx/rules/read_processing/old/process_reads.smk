#from pathlib import Path

#include: 'porefilt_correct.smk'
#include: 'canu_correct.smk'
#include: 'illumina.smk'

#def pick_preprocessing_strategy(config):
#    """
#    Pick which Nanopore processing module you want to run based on what was
#    passed on the command line
#
#    This is neat b/c I didn't know you could return rule outputs like this
#    and selectively run portions of the pipeline and modularize like this.
#    """
#    if config['porefilt_correct']:
#        return rules.compress_filtlong.output
#    if config['canu_correct']:
#        return rules.compress_canu.output
#
#rule process_nanopore:
#    input:
#        pick_preprocessing_strategy(config)
#    output:
#        processed_long_reads = f'{outdir}/reads/processed_reads/nanopore/{config["name"]}_ont.fq.gz'
#    run:
#        section_header('Moving processed Nanopore reads to processed_reads directory')
#        shell(
#            """
#            cp {input} {output}
#            """
#        )

#rule process_illumina:
#    input:
#        r1_normalized = rules.normalize_reads.output.r1_normalized,
#        r2_normalized = rules.normalize_reads.output.r2_normalized,
#    output:
#        r1_processed = f'{outdir}/reads/processed_reads/illumina/{config["name"]}_ilmn.1.fq.gz',
#        r2_processed = f'{outdir}/reads/processed_reads/illumina/{config["name"]}_ilmn.2.fq.gz'
#    params:
#        processed_read_dir = f'{outdir}/reads/processed_reads/illumina'
#    run:
#        section_header('Moving normalized Illumina reads to processed_reads directory')
#        #os.makedirs(params.processed_read_dir, exist_ok=True)
#        shell('cp {input.r1_normalized} {output.r1_processed}')
#        shell('cp {input.r2_normalized} {output.r2_processed}')
