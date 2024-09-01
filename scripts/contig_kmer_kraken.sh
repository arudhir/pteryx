#!/bin/bash

# purpose: given assembly fasta and kmer size k, produces per-contig kraken reports for 
# assembly kmers

# usage: bash contig_kmer_kraken.sh <assembly.fasta> <k>
# requires: kraken, jellyfish, jellyfish_to_fasta.py

# need to clean up the naming and tmp files

PRE=$1.jellyfish.tmp.fasta

# cut anything after any spaces in sequence header to avoid spaces in filename
cut -f1 -d' ' $1 > $PRE

# split fasta into 1 file per contig
sed 's/'">"'/'">$1_"'/g' $PRE | awk '/^>/ {OUT=substr($0,2) ".jellyfish.tmp.fasta";print " ">OUT}; OUT{print >OUT}'

# count kmers for each contig
for fasta in $1_*.jellyfish.tmp.fasta;
	# get rid of blankspace at top of file
	do sed -i '/^[[:space:]]*$/d' ${fasta}
	jellyfish count -m $2 -s 100000 -o ${fasta}_counts.jf ${fasta}
	jellyfish dump -t -c ${fasta}_counts.jf > ${fasta}_counts.txt
done

# convert kmer count file to kmer fasta, with unique ID for each kmer
for kmers in $1_*.jellyfish.tmp.fasta_counts.txt;
	do python jellyfish_to_fasta.py ${kmers}
done

# run kraken on kmer fasta
export PATH=$PATH:/mnt/efs/ahicks/kraken2-2.0.8-beta/
for fasta in $1_*.jellyfish.tmp.fasta_counts.txt.fasta;
	do kraken2 -db /mnt/efs/ahicks/kraken2-2.0.8-beta/standard/ --use-mpa-style --use-names --report ${fasta}_kraken_report.txt ${fasta} > ${fasta}.kraken
done
