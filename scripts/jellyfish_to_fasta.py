#!/usr/bin/env python
import sys
import uuid

output = sys.argv[1] + '.fasta'
output_file = open(output, "w")

with open(sys.argv[1]) as fasta:
	for line in fasta:
		split_line = line.split('\t', 1)
		kmer = split_line[0]
		header = '>' + str(uuid.uuid4())
		output_file.write('%s\n%s\n' % (header,kmer))
		
output_file.close()
