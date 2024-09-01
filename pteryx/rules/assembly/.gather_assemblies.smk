import os

include: 'flye.smk'
include: 'unicycler.smk'
include: 'hybrid_spades.smk'
include: 'shasta.smk'
include: 'skesa.smk'
include: 'miniasm.smk'
include: 'canu.smk'

checkpoint gather_assemblies:
    input:
        canu_assembly = rules.canu.output,
        flye_assembly = rules.flye.output,
        hybrid_spades_assembly = rules.hybrid_spades.output,
        shasta_assembly = rules.shasta.output,
        skesa_assembly = rules.skesa.output,
        unicycler_assembly = rules.unicycler.output,
        miniasm_assembly = rules.miniasm.output.miniasm_fasta
    output:
        gathered_assemblies_dir = directory(f'{outdir}/assemblies/gathered_assemblies'),
    run:
        for f in input:
            if os.stat(f).st_size > 0:
                shell(
                    f"""
                    mkdir {output.gathered_assemblies_dir} -p
                    cp -t {output.gathered_assemblies_dir} {{f}}
                    """
                )

def aggregate_checkpoint(wildcards):
    """Get the assembler name of the non-empty FASTAs"""
    checkpoint_output = checkpoints.gather_assemblies.get(**wildcards).output
    good_fastas = expand(
        f'{outdir}/assemblies/gathered_assemblies/{config["name"]}_{{assembler}}.fa',
        assembler=glob_wildcards(f'{checkpoint_output}/{config["name"]}_{{assembler}}.fa').assembler
    )
    named_good_fastas = {f.split(config['name'] + '_')[1].split('.')[0]: f for f in good_fastas}
    return named_good_fastas

#include: 'skesa.smk'
#include: 'canu.smk'
#include: 'flye.smk'
#include: 'hybrid_spades.smk'
#include: 'miniasm.smk'
#include: 'shasta.smk'
#include: 'unicycler.smk'
#
#assemblies = glob_wildcards(f'{outdir}/assemblies/*/{{assembler}}/*.fa').assembler
#import os
#from glob import glob
#from pathlib import Path
#logger.info(glob(f'{outdir}/assemblies/*/*.fa'))
#logger.info(assemblies)
#
#def glob_assemblies(wildcards):
#    return list(
#        map(
#            lambda x: Path(x).stem, 
#            glob(f'{outdir}/assemblies/*/*.fa')
#        )
#    )
#
#rule gather_assemblies:
#    input:
#        glob_assemblies
##        expand(f'{outdir}/assemblies/{{assembler}}/{{assembler}}.fa', assembler=assemblies)
#    output:
#        'test'
#    run:
#        print('reached')
#        print(input)
##        'echo {input} '
##        'touch {output}'
