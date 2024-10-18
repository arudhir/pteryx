import os
from Bio import SeqIO
# from snakemake.utils import optional

rule annotate_assembly:
    input:
        assembly=f"{outdir}/assemblies/{{assembler}}/{{assembler}}.fa"
    output:
        annotation=f"{outdir}/annotations/{{assembler}}/{{assembler}}.gff"
    threads: 16  # Adjust as needed
    run:
        assembly_file = input.assembly
        output_file = output.annotation
        assembler = wildcards.assembler
        if not assembly_file or not os.path.exists(assembly_file):
            print(f"Assembly file {assembly_file} does not exist. Skipping annotation for assembler {assembler}.")
            # Optionally, create an empty output file to satisfy Snakemake
            shell(f"touch {output_file}")
        else:
            try:
                sequences = list(SeqIO.parse(assembly_file, "fasta"))
                if len(sequences) == 0:
                    print(f"Assembly file {assembly_file} has no contigs. Skipping annotation for assembler {assembler}.")
                    shell(f"touch {output_file}")
                else:
                    os.makedirs(os.path.dirname(output_file), exist_ok=True)
                    shell(f"""
                        dfast --genome {assembly_file} --out {os.path.dirname(output_file)} --dbroot db --force --no_cdd --cpus {threads}
                    """)
            except Exception as e:
                print(f"Error parsing {assembly_file}: {e}")
                shell(f"touch {output_file}")
