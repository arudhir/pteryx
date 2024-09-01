# The important bits
```console
➜ ls outputs/*/processed_reads outputs/assemblies/*/*.fa
outputs/assemblies/shasta/shasta.fa  outputs/assemblies/spades/spades.fa

outputs/illumina/processed_reads:
1.ilmn.fq.gz  2.ilmn.fq.gz

outputs/nanopore/processed_reads:
ont.fq  ont.fq.gz
```

# Everything
```console
outputs
├── assemblies
│   ├── assembly_stats.json
│   ├── shasta
│   │   ├── Assembly-BothStrands.gfa
│   │   ├── Assembly.gfa
│   │   ├── AssemblyGraph-Final.dot
│   │   ├── AssemblyGraphChainLengthHistogram.csv
│   │   ├── AssemblySummary.csv
│   │   ├── AssemblySummary.html
│   │   ├── AssemblySummary.json
│   │   ├── Binned-ReadLengthHistogram.csv
│   │   ├── DisjointSetsHistogram.csv
│   │   ├── LowHashBucketHistogram.csv
│   │   ├── MarkerGraphEdgeCoverageHistogram.csv
│   │   ├── MarkerGraphVertexCoverageHistogram.csv
│   │   ├── PalindromicReads.csv
│   │   ├── ReadGraphComponents.csv
│   │   ├── ReadLengthHistogram.csv
│   │   ├── ReadLowHashStatistics.csv
│   │   ├── ReadSummary.csv
│   │   ├── index.html
│   │   ├── shasta.conf
│   │   └── shasta.fa
│   └── spades
│       ├── K21
│       ├── K33
│       ├── K55
│       ├── K77
│       ├── assembly_graph.fastg
│       ├── assembly_graph_with_scaffolds.gfa
│       ├── before_rr.fasta
│       ├── contigs.paths
│       ├── corrected
│       ├── dataset.info
│       ├── input_dataset.yaml
│       ├── misc
│       ├── params.txt
│       ├── scaffolds.fasta
│       ├── scaffolds.paths
│       ├── spades.fa
│       ├── spades.log
│       └── tmp
├── illumina
│   ├── concat_reads
│   │   ├── 1.fq.gz
│   │   └── 2.fq.gz
│   ├── deduped_reads
│   │   ├── 1.deduped.fq.gz
│   │   └── 2.deduped.fq.gz
│   ├── fastp
│   │   ├── 1.fastp.fq.gz
│   │   ├── 2.fastp.fq.gz
│   │   ├── fastp.html
│   │   └── fastp.json
│   ├── normalized_reads
│   │   ├── 1.normalized.fq.gz
│   │   └── 2.normalized.fq.gz
│   ├── processed_reads
│   │   ├── 1.ilmn.fq.gz
│   │   └── 2.ilmn.fq.gz
│   ├── raw
│   │   ├── mesoplasma_simulated.1.paired.fq.gz
│   │   └── mesoplasma_simulated.2.paired.fq.gz
│   └── repaired_reads
│       ├── 1.repaired.fq.gz
│       └── 2.repaired.fq.gz
└── nanopore
    ├── concat_nanopore.log
    ├── datastore
    │   └── ont.clean.fq.gz
    ├── filtlong.log
    ├── porechop.log
    ├── processed_reads
    │   ├── ont.fq
    │   └── ont.fq.gz
    ├── raw
    │   ├── mesoplasma_simulated.ont.fq.gz
    │   └── ont.datastore.fq.gz
    └── sanitize.log
```
