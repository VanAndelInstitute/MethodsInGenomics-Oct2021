#!/bin/bash

set -e
set -u
set -o pipefail

module load bbc/sratoolkit/sratoolkit-2.11.0
module load bbc/samtools/samtools-1.9
module load bbc/bedtools/bedtools-2.29.2
module load bbc/pigz/pigz-2.4
module load bbc/fastx_toolkit/fastx_toolkit-0.0.13

mkdir -p raw_data/

region='3000000-3010000'

# FVB and C3H
for accession in SRR12209082 SRR12209088
do
    sam-dump --aligned-region 3:${region} ${accession} | samtools sort -n -o ${accession}_qsort.bam -
    bedtools bamtofastq -i ${accession}_qsort.bam -fq raw_data/${accession}_R1.fq.tmp -fq2 raw_data/${accession}_R2.fq.tmp
    fastx_artifacts_filter -Q33 -i raw_data/${accession}_R1.fq.tmp -o raw_data/${accession}_R1.fq
    fastx_artifacts_filter -Q33 -i raw_data/${accession}_R2.fq.tmp -o raw_data/${accession}_R2.fq
    rm ${accession}_qsort.bam raw_data/*fq.tmp
done

pigz -p 4 raw_data/*fq
