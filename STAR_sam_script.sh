#!/bin/bash
FASTQ=$1 # input FASTQ file
         # <file>_trimmed.fastq.gz
threads=$2 #${THREADS}
starOutDir=$3 #outdir


str="${FASTQ##*/}"
regex="${str%%.fastq.gz}"
regex="${str%%.fq.gz}"
mkdir ${starOutDir}/${regex}_align
echo "---- working on ${regex} file ----"
STAR --genomeDir "/home/my_data/genome/hg38/star" --genomeLoad LoadAndKeep  --readFilesIn ${FASTQ} --readFilesCommand zcat --runThreadN $threads --alignIntronMax 1 --outSAMattributes NH HI NM MD --outFilterMult$
echo "---- now sorting ----"
samtools sort -O bam -o ${starOutDir}/${regex}_align/${regex}_sorted.bam -@ ${threads} ${starOutDir}/${regex}_align/${regex}_Aligned.out.sam
echo "---- now making the fastq ----"
samtools fastq -F 4 -@ ${threads} ${starOutDir}/${regex}_align/${regex}_sorted.bam > ${starOutDir}/${regex}_align/${regex}_sorted.fastq
echo "---- removing not sorted sam ----"
rm ${starOutDir}/${regex}_align/${regex}_Aligned.out.sam
echo "---- making sorted sam for protrac ----"
samtools view -h -@ ${threads} -o ${starOutDir}/${regex}_align/${regex}_sorted.sam in.bam ${starOutDir}/${regex}_align/${regex}_sorted.bam