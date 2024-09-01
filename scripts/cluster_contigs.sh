#!/bin/bash

# Usage: bash cluster_contigs.sh <bbypteryx_directory>

# Purpose: use Trycycler (https://github.com/rrwick/Trycycler) to cluster contigs from different assembly methods for the purpose of generating consensus assemblies (i.e., this script takes output from bbypteryx, carries out steps 0-1 described in https://ginkgobioworks.atlassian.net/wiki/spaces/SB/pages/203260413/Getting+a+Consensus+Assembly, and prints to csv the contig clusters that are supported by >2 assembly methods, along with their mean contig lengths)

# Requires: trycycler

# Assumptions: bbypteryx output directory of interest contains 'assemblies' subdirectory, with contigs from each assembly method located in 'assemblies/<method>/*.fa'. Note that output from current version of bbypteryx requires renaming of canu assembly to follow this naming scheme (lines 16-20). Similarly assumes that bbypteryx output directory of interest contains processed ONT reads with the following subdirectory structure: 'nanopore/processed_reads/*ont.fq.gz'


INDIR=$1
[[ "${INDIR}" != */ ]] && INDIR="${INDIR}/"
canu=${INDIR}assemblies/canu/canu.unitigs.fasta

# rename canu assembly to .fa
if test -f '$canu'; then
    mv ${canu} ${INDIR}assemblies/canu/canu.unitigs.fa
fi

# cluster
trycycler cluster --assemblies ${INDIR}assemblies/*/*.fa --reads ${INDIR}nanopore/processed_reads/*ont.fq.gz -o ${INDIR}cluster 2> ${INDIR}cluster.log

# parse cluster log for high-confidence clusters
python trycycler_cluster.py ${INDIR}cluster.log
awk -F ',' '{print $1}' ${INDIR}cluster.log.hcclusters.csv > ${INDIR}hcclusterstmp.txt
sed -i '1d' ${INDIR}hcclusterstmp.txt

# attempt reconciliation for all high-confidence clusters
while read c; do
  trycycler reconcile --reads ${INDIR}nanopore/processed_reads/*ont.fq.gz --cluster_dir ${INDIR}cluster/$c 2> ${INDIR}reconcile_$c.log
  grep -H 'Error' ${INDIR}reconcile_$c.log
done <${INDIR}hcclusterstmp.txt 

rm ${INDIR}hcclusterstmp.txt
