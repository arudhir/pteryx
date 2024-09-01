#!/bin/bash

# wrapper script for merqury
# requires meryl v1.3 and merqury v1.3
# usage: bash merqury_wrapper.sh <path to meryl> <path to merqury> <path to assembly> <path to R1 fastq> <path to R2 fastq>
# example usage: bash merqury_wrapper.sh /mnt/efs/ahicks/meryl-1.3 /mnt/efs/ahicks/merqury-1.3 contigs.fa 37593995.1.paired.fq 37593995.2.paired.fq


export PATH=$PATH:${1}/bin/
export MERQURY=${2}

# check that assembly fasta and fastqs exist and aren't empty, and if not, make local copies; this is probably the most important step since merqury can behave strangely with missing/empty input and with absolute paths
if [ -s "$3" ]; then
    cp ${3} assembly.fasta
else 
    echo "$3 does not exist or is empty."
    exit
fi

if [ -s "$4" ]; then
	:
else 
    echo "$4 does not exist or is empty."
    exit
fi

if [ -s "$5" ]; then
	:
else 
    echo "$5 does not exist or is empty."
    exit
fi

if [[ "$4" == *".gz" ]]; then
	cp $4 R1.fq.gz
	cp $5 R2.fq.gz
	gunzip R*.fq.gz
	cat R*.fq > reads.fq
else
	cat $4 $5 > reads.fq
fi

# run meryl to count 31-mers in reads
meryl count k=31 reads.fq output read_31mers.meryl
# run merqury to calculate assembly qv/error rate
$MERQURY/merqury.sh read_31mers.meryl assembly.fasta assembly_merqury


# key outputs are captured in .qv and .bed files:
# assembly_merqury.qv gives the qv and error rate for the entire assembly, and assembly_merqury.assembly.qv gives per-contig qv and error rates; fields in .qv output files are defined as (from left to right): 1) assembly of interest, 2) k-mers uniquely found only in the assembly, 3) k-mers found in both assembly and the read set, 4) QV, 5) Error rate (https://github.com/marbl/merqury/wiki/2.-Overall-k-mer-evaluation)
# assembly_only.bed gives the coordinates for all 31-mers in the assembly that were not found in the reads