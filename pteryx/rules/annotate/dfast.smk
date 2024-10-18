import os
from Bio import SeqIO
# from snakemake.utils import optional

rule annotate_assembly:
    input:
        assembly = f"{outdir}/assemblies/{{assembler}}/{{assembler}}.fa"
    output:
        gff = f"{outdir}/annotations/{{assembler}}/{{assembler}}.gff",
        gbk = f"{outdir}/annotations/{{assembler}}/{{assembler}}.gbk",
        cds = f"{outdir}/annotations/{{assembler}}/{{assembler}}.cds.fna",
        rna = f"{outdir}/annotations/{{assembler}}/{{assembler}}.rna.fna",
        embl = f"{outdir}/annotations/{{assembler}}/{{assembler}}.embl",
        fna = f"{outdir}/annotations/{{assembler}}/{{assembler}}.genome.fna",
    params:
        output_dir = f"{outdir}/annotations/{{assembler}}"
    threads: 8  # Adjust as needed
    run:
        assembly_file = input.assembly
        output_file = output.gff
        assembler = wildcards.assembler
        if not assembly_file or not os.path.exists(assembly_file):
            print(f"Assembly file {assembly_file} does not exist. Skipping annotation for assembler {assembler}.")
            # Optionally, create an empty output file to satisfy Snakemake
        else:
            try:
                sequences = list(SeqIO.parse(assembly_file, "fasta"))
                if len(sequences) == 0:
                    print(f"Assembly file {assembly_file} has no contigs. Skipping annotation for assembler {assembler}.")
                    shell(f"touch {output_file}")
                else:
                    shell(
                        'uv run dfast '
                        '--genome {assembly_file} '
                        '--out {params.output_dir} '
                        '--dbroot db '
                        '--force '
                        '--no_cdd '
                        '--amr '
                        '--cpu {threads}'
                    )
                    shell(f'mv {params.output_dir}/genome.gff {output.gff}')
                    shell(f'mv {params.output_dir}/genome.gbk {output.gbk}')
                    shell(f'mv {params.output_dir}/genome.cds.fna {output.cds}')
                    shell(f'mv {params.output_dir}/genome.rna.fna {output.rna}')
                    shell(f'mv {params.output_dir}/genome.fna {output.fna}')
                    shell(f'mv {params.output_dir}/genome.embl {output.embl}')
            except Exception as e:
                print(f"Error parsing {assembly_file}: {e}")