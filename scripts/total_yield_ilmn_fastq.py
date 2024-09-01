#!/usr/bin/env python3
import subprocess

def run(cmd):
   proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
   output = proc.stdout.read()
   return output

# given gzipped R1 and R2 fastqs, returns total base yield
def get_total_bases(R1,R2):
	total_bases = 0
	cmd = "zcat " + R1 + " | awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' -"
	total_bases += int(run(cmd))
	cmd = "zcat " + R2 + " | awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' -"
	total_bases += int(run(cmd))
	return total_bases