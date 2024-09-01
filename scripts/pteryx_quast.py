#!/usr/bin/env python3
import subprocess
import pandas as pd
import os

# conda install -c bioconda quast

def run(cmd):
   proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
   proc.communicate()
   
def run_quast(assembly_fasta,reference_fasta=None):
	cmd = 'quast -o quast ' + assembly_fasta
	if reference_fasta is not None:
		if len(reference_fasta) > 0:
			ref = reference_fasta
			cmd = 'quast -r ' + ref + ' -o quast ' + assembly_fasta
	run(cmd)
	
def parse_quast(quast_dir,reference_fasta=None):
	quast_stats = {}
	quast_report = os.path.join(quast_dir, 'transposed_report.tsv')
	df = pd.read_csv(quast_report, sep="\t")
	quast_stats['n_contigs'] = df['# contigs'][0]
	quast_stats['total_contig_length'] = df['Total length'][0]
	quast_stats['assembly_percent_GC'] = df['GC (%)'][0]
	quast_stats['assembly_N50'] = df['N50'][0]
	if reference_fasta is not None:
		if len(reference_fasta) > 0:
			quast_stats['percent_of_reference_genome_covered'] = df['Genome fraction (%)'][0]
			ratio = float(df['GC (%)'][0]) / float(df['Reference GC (%)'][0])
			quast_stats['ratio_assembly_percent_GC_to_reference_percent_GC'] = ratio
	return quast_stats
