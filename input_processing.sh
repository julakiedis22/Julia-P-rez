## Author: Julia Perez Perez and Fernando Rodriguez Marin
## Date: 12-11-2019
## Contact: julia22898@gmail.com and fernando.rodriguez.marin8@gmail.com

#$ -S /bin/bash
#$ -N input_processing
#$ -V
#$ -cwd
#$ -j yes
#$ -o input_processing

#!bin/bash

## Reading input parameters

I=$1
WD=$2
NUMINPUT=$3
NUMSAM=$4
PROMOTER=$5
SD=$6

## Quality study using fastqc tool and mapping with bowtie2

cd $WD/samples/input/sample$I

if [ -e input${I}_2.fastq ]
then

## This is the processing with paired-end data

   mkdir quality_analysis

   fastqc $WD/samples/input/sample$I/input${I}_1.fastq -o $WD/samples/input/sample$I/quality_analysis
   fastqc $WD/samples/input/sample$I/input${I}_2.fastq -o $WD/samples/input/sample$I/quality_analysis

   bowtie2 -x $WD/genome/index -1 $WD/samples/input/sample$I/input${I}_1.fastq -2 $WD/samples/input/sample$I/input${I}_2.fastq -S input${I}.sam

else

## This is the processing with single-end (unpair) data

   mkdir quality_analysis

   fastqc $WD/samples/input/sample$I/input${I}.fastq -o $WD/samples/input/sample$I/quality_analysis

   bowtie2 -x $WD/genome/index -U $WD/samples/input/sample$I/input${I}.fastq -S $WD/samples/input/sample$I/input${I}.sam

fi

echo "Quality study has been completed. You can find it in $WD/samples."
echo "Mapping has been completed. Now, the .sam file will be processed in a .bam file."

## Generating the bam file using samtools

cd $WD/samples/input/sample$I

samtools view -@ 2 -S -b $WD/samples/input/sample$I/input${I}.sam > $WD/samples/input/sample$I/input${I}.bam
rm $WD/samples/input/sample$I/input${I}.sam
samtools sort $WD/samples/input/sample$I/input${I}.bam -o $WD/samples/input/sample$I/input_sorted${I}.bam
rm $WD/samples/input/sample$I/input${I}.bam
samtools index $WD/samples/input/sample$I/input_sorted${I}.bam

echo "Generation of sorted.bam file has been completed. This file is ready for peak calling"

## Synchronization point through blackboards

echo "sample${SAMPLE_ID} of input samples DONE" >> $WD/logs/blackboard

DONE_SAMPLES=$(wc -l $WD/logs/blackboard | awk '{ print $1 }')

if [ ${DONE_SAMPLES} -eq $NUMINPUT ]
then

   echo "ALL INPUT SAMPLES FINISHED :)"

fi

## When all samples have been processed, next instructions will launch one script for each replicas of the experiment.

if [ ${DONE_SAMPLES} -eq $NUMSAM ]
then

   echo "ALL SAMPLES FINISHED :)"

   I=1
   while [ $I -le $NUMINPUT ]
   do
      qsub -N call_peaks$I -o $WD/logs/call_peaks$I $SD/call_peaks.sh $WD $PROMOTER $NUMINPUT $SD
      rm $WD/logs/blackboard
      ((I++))
   done

fi

