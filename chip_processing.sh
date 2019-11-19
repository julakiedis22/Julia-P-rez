#!bin/bash
## Reading input parameters

SAMPLE_ID=$1
WD=$2
NUMCHIP=$3
SRACHIP=$4

## Quality study and mappingggggg

if [ -e ${SRACHIP}_2.fastq ]
then
   fastqc ${SRACHIP}_1.fastq
   fastqc ${SRACHIP}_2.fastq

   bowtie2 -x ../../genome/index -1 ${SRACHIP}_1.fastq -2 ${SRACHIP}_2.fastq -S chip.sam
else
   fastqc ${SRACHIP}_1.fastq

   bowtie2 -x ../../genome/index -U ${SRACHIP}_1.fastq -S chip.sam
fi


##Generating the bam file 

samtools view -@ 2 -S -b chip.sam > chip.bam
rm chip.sam
samtools sort chip.bam -o chip_sorted.bam
rm chip.bam
samtools index chip_sorted.bam


## Synchronization point through blackboards

echo "sample${SAMPLE_ID} DONE" >> $WD/logs/blackboard

DONE_SAMPLES=$(wc -l $WD/logs/blackboard | awk '{ print $1 }')

if [ ${DONE_SAMPLES} -eq $NUMCHIP ]

echo "ALL FINISHED :)"

fi

