from pathlib import Path

rule fastp:
    input:
        r1 = rules.process_illumina.output.r1,
        r2 = rules.process_illumina.output.r2
    output:
        r1_fastp = f'{outdir}/polish/1.fq.gz',
        r2_fastp = f'{outdir}/polish/2.fq.gz',
        ru_fastp = f'{outdir}/polish/u.fq.gz'
    run:
        section_header('Running Fastp')
        shell(
            """
            fastp \
                --in1 {input.r1} \
                --in2 {input.r2} \
                --out1 {output.r1_fastp} \
                --out2 {output.r2_fastp} \
                --unpaired1 {output.ru_fastp} \
                --unpaired2 {output.ru_fastp}
            """
        )

rule estimate_insert_size:
    input:
        assembly = lambda wildcards: aggregate_checkpoint(wildcards)[wildcards.assembler],  # Not sure why it was bugging out here, moving it to params seems...wrong?
        r1 = rules.fastp.output.r1_fastp,
        r2 = rules.fastp.output.r2_fastp,
        ru = rules.fastp.output.ru_fastp,
    output: 
        insert_size = f'{outdir}/polish/{{assembler}}/insert_size.sam',
    params:
        idx = f'{outdir}/polish/{{assembler}}/bt2_idx',
#        assembly = lambda wildcards: aggregate_checkpoint(wildcards)[wildcards.assembler],
    threads: workflow.cores * 0.1
    log: f'{outdir}/logs/{{assembler}}_insert_size.log'
    run:
        section_header('Estimate insert size')
        #import ipdb; ipdb.set_trace()
        shell(
            """
            bowtie2-build {input.assembly} {params.idx} &> /dev/null &&
            bowtie2 \
                -1 {input.r1} \
                -2 {input.r2} \
                -x {params.idx} \
                --fast \
                --threads {threads} \
                -I 0 \
                -X 1000 \
                -S {output.insert_size} \
                > {log}
            """
        )

rule pilon:
    input:
        assembly = lambda wildcards: aggregate_checkpoint(wildcards)[wildcards.assembler],
        r1 = rules.fastp.output.r1_fastp,
        r2 = rules.fastp.output.r2_fastp,
        ru = rules.fastp.output.ru_fastp,
        insert_size = rules.estimate_insert_size.output.insert_size
    output:
        polished_assembly = f'{outdir}/polish/{{assembler}}/{{assembler}}.pilon.fa',
        pilon_bam = f'{outdir}/polish/{{assembler}}/aln.bam',
        pilon_ubam = f'{outdir}/polish/{{assembler}}/aln.u.bam'
    params:
        before = f'{outdir}/polish/{{assembler}}/before.fa',
        after = f'{outdir}/polish/{{assembler}}/after',
        idx = f'{outdir}/polish/{{assembler}}/bt2_idx'
    threads: workflow.cores * 0.2
    log:
        bt2 = f'{outdir}/logs/bt2_{{assembler}}.log',
        pilon = f'{outdir}/logs/bt2_{{assembler}}.log',
    run:
        section_header(f'Starting polish for {wildcards.assembler}')
        insert_min, insert_max = get_insert_size(input.insert_size)
        
        # Start polishing rounds
        shell('cp {input.assembly} {params.before}')
        for i in range(config['polish_iterations']):
            section_header(f'Pilon Round {i} for {wildcards.assembler}')
            section_header(f'Sensitive Bowtie2 alignment round {i} for {wildcards.assembler}')
            shell(
                f"""
                bowtie2-build {{params.before}} {{params.before}} &> /dev/null && \
                bowtie2 \
                    -1 {{input.r1}} \
                    -2 {{input.r2}} \
                    -x {{params.before}} \
                    --threads {threads} \
                    -I {insert_min} \
                    -X {insert_max} \
                    --local \
                    --very-sensitive-local 2> {log.bt2} \
                    | samtools sort > {{output.pilon_bam}} \
                    && bowtie2 -U {{input.ru}} \
                    -x {{params.before}} \
                    --threads {threads} \
                    --local \
                    --very-sensitive-local 2>> {log.bt2} \
                    | samtools sort > {{output.pilon_ubam}} \
                    && samtools index {{output.pilon_bam}} \
                    && samtools index {{output.pilon_ubam}}
                """
            )

            section_header('Running Pilon')
            shell(
                f"""
                java -jar /tools/pilon-1.22.jar \
                    --genome {{params.before}} \
                    --frags {{output.pilon_bam}} \
                    --unpaired {{output.pilon_ubam}} \
                    --output {{params.after}} \
                    --changes &> {log.pilon}
                """
            )

            # Pilon makes the extension .fasta automatically
            shell('cp {params.after}.fasta {params.before}')

        # After polishing, rename the result to become the output
        shell('mv {params.after}.fasta {output.polished_assembly}')

#def aggregate_pilon(wildcards):
#    checkpoint_output = checkpoints.pilon.get(**wildcards).output
#    print(checkpoint_output)
#    polished_fastas = expand(
#        f'{outdir}/polish/{{assembler}}/{{assembler}}.pilon.fa',
#        assembler=glob_wildcards(f'{checkpoint_output}/polish/{{assembler}}.pilon.fa').assembler
#    )
#    return polished_fastas
