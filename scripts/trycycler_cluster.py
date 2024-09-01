#!/usr/bin/env python

# parses cluster log from trycycler to identify high-confidence clusters (supported by >2 assemblers) and calculate their mean lengths

import re
import statistics
import sys

cluster_log = sys.argv[1]

def high_confidence_clusters(N):
	hc_clusters={}
	for i in range(1,N):
		cluster_id = 'cluster_' + '{:03d}'.format(i)
		cluster_size = 0
		lengths = []
		with open(cluster_log) as f:
			for line in f:
				if (cluster_id + '/1_contigs/') in line:
					cluster_size+=1
					length = line.rstrip().split(':')[1].lstrip().split(' ')[0]
					length = re.sub(',', '', length)
					lengths.append(int(length))
		mean_length = statistics.mean(lengths)
		if cluster_size > 2:
			hc_clusters[cluster_id] = mean_length
	return hc_clusters

N = 0
phred = []
with open(cluster_log) as f:
	for line in f:
		if '1_contigs:' in line:
			N+=1
		elif 'Error' in line:
			print('error in clustering; see %s for details' % sys.argv[1])
			exit(1)
hc_clusters = high_confidence_clusters(N)
outfile = sys.argv[1] + '.hcclusters.csv'
f = open(outfile, 'w')
f.write('cluster,mean_length\n')
for cluster in hc_clusters:
	f.write('%s,%s\n' % (cluster, hc_clusters[cluster]))
	