## Author: Julia Perez Perez and Fernando Rodriguez Marin
## Date: 12-11-2019
## Contact: julia22898@gmail.com and fernando.rodriguez.marin8@gmail.com

#$ -S /bin/bash
#$ -N chip_processing
#$ -V
#$ -cwd
#$ -j yes
#$ -o chip_processing

#!bin/bash

## Reading input parameters

I=$1
WD=$2
NUMCHIP=$3
NUMSAM=$4
PROMOTER=$5
SD=$6

## Quality study using fastqc tool and mapping with bowtie2

cd $WD/samples/chip/sample$I

if [ -e chip${I}_2.fastq ]
then

## This is the processing with paired-end data

   mkdir quality_analysis

   fastqc $WD/samples/chip/sample$I/chip${I}_1.fastq -o $WD/samples/chip/sample$I/quality_analysis
   fastqc $WD/samples/chip/sample$I/chip${I}_2.fastq -o $WD/samples/chip/sample$I/quality_analysis

   bowtie2 -x $WD/genome/index -1 $WD/samples/chip/sample$I/chip${I}_1.fastq -2 $WD/samples/chip/sample$I/chip${I}_2.fastq -S chip${I}.sam

else

## This is the processing with single-end (unpair) data

   mkdir quality_analysis 

   fastqc $WD/samples/chip/sample$I/chip${I}.fastq -o $WD/samples/chip/sample$I/quality_analysis

   bowtie2 -x $WD/genome/index -U $WD/samples/chip/sample$I/chip${I}.fastq -S $WD/samples/chip/sample$I/chip${I}.sam

fi

echo "Quality study has been completed. You can find it in $WD/samples."
echo "Mapping has been completed. Now, the .sam file will be processed in a .bam file."

## Generating the bam file using samtools

cd $WD/samples/chip/sample$I

samtools view -@ 2 -S -b $WD/samples/chip/sample$I/chip${I}.sam > $WD/samples/chip/sample$I/chip${I}.bam

rm $WD/samples/chip/sample$I/chip${I}.sam
samtools sort $WD/samples/chip/sample$I/chip${I}.bam -o $WD/samples/chip/sample$I/chip_sorted${I}.bam
rm $WD/samples/chip/sample$I/chip${I}.bam
samtools index $WD/samples/chip/sample$I/chip_sorted${I}.bam

echo "Generation of sorted.bam file has been completed. This file is ready for peak calling"

## Synchronization point through blackboards

echo "sample$I of chip samples DONE" >> $WD/logs/blackboard

DONE_SAMPLES=$(wc -l $WD/logs/blackboard | awk '{ print $1 }')

if [ ${DONE_SAMPLES} -eq $NUMCHIP ]
then

   echo "ALL CHIP SAMPLES FINISHED :)"

fi

## When all samples have been processed, next instructions will launch one script for each replicas of the experiment. 

if [ ${DONE_SAMPLES} -eq $NUMSAM ]
then

   echo "ALL SAMPLES FINISHED :)"

   I=1
   while [ $I -le $NUMCHIP ]
   do
      qsub -N call_peaks$I -o $WD/logs/call_peaks$I $SD/call_peaks.sh $WD $PROMOTER $NUMCHIP $SD
      rm $WD/logs/blackboard
      ((I++))
   done

fi
