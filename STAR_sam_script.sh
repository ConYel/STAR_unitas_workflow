#!/bin/bash

FASTQ=$1 # input FASTQ file
         # <file>_trimmed.fastq.gz
genome=$2 #genome folder
threads=$3 #${THREADS}
starOutDir=$4 #outdir


str="${FASTQ##*/}"
regex="${str%%.fastq.gz}"
regex="${regex%%.fq.gz}"
regex="${regex%%.fasta.gz}"
regex="${regex%%.fasta}"

mkdir ${starOutDir}/${regex}_align
echo "---- working on ${regex} file ----"
STAR --genomeDir $genome --genomeLoad LoadAndKeep --readFilesIn ${FASTQ} --readFilesCommand zcat --runThreadN $threads --alignIntronMax 1 --outSAMattributes NH HI NM MD --outFilterMultimapNmax 100 --outReadsUnmapped Fastx --outFilterMismatchNmax 1 --outFilterMatchNmin 14 --outFileNamePrefix "${starOutDir}/${regex}_align/${regex}_"
echo "---- now sorting ----"
samtools sort -O bam -o ${starOutDir}/${regex}_align/${regex}_sorted.bam -@ ${threads} ${starOutDir}/${regex}_align/${regex}_Aligned.out.sam
echo "---- now making the fastq ----"
samtools fastq -F 4 -@ ${threads} ${starOutDir}/${regex}_align/${regex}_sorted.bam > ${starOutDir}/${regex}_align/${regex}_sorted.fastq
echo "---- removing not sorted sam ----"
rm ${starOutDir}/${regex}_align/${regex}_Aligned.out.sam
echo "---- making sorted sam for protrac ----"
samtools view -h -@ ${threads} -o ${starOutDir}/${regex}_align/${regex}_sorted.sam ${starOutDir}/${regex}_align/${regex}_sorted.bam
