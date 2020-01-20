## Author: Julia Perez Perez and Fernando Rodriguez Marin
## Date: 12-11-2019
## Contact: julia22898@gmail.com and fernando.rodriguez.marin8@gmail.com

#$ -S /bin/bash
#$ -N call_peaks
#$ -V
#$ -cwd
#$ -j yes
#$ -o call_peaks

#! /bin/bash

## Loading parameters

WD=$1
PROMOTER=$2
NUMREP=$3
SD=$4

## The parameter called NUMREP is the number of replicas of the experiment. This is the same value that the number of chip or input samples.

## Callpeak function

cd $WD/results

## Macs2 for creating the peakAnnotation file

I=1

while [ $I -le $NUMREP ]
do
   macs2 callpeak -t $WD/samples/chip/sample$I/chip_sorted${I}.bam -c $WD/samples/input/sample$I/input_sorted${I}.bam -n peak_results$I --outdir . -f BAM
   ((I++))
done

## HOMER for finding motifs

cd $WD/results

I=1

echo "Finding motifs with HOMER will be take a while. Be patient!"

while [ $I -le $NUMREP ]
do
   mkdir HOMER_$I
   findMotifsGenome.pl $WD/results/peak_results${I}_summits.bed tair10 $WD/results/HOMER_$I -size 50
   ((I++))
done

cd $WD/results

mkdir results_R

## Launching a script that is going to execute an R script with necessary instructions for the processing of peaks. 

cd $WD

if [ $NUMREP -eq 1 ]
then

qsub -N peak_processing -o $WD/logs/peak_processing $SD/execute_Rscript_onerep.sh $WD $WD/results/peak_results1_peaks.narrowPeak $PROMOTER $SD

elif [ $NUMREP -eq 2 ]
then

qsub -N peak_processing -o $WD/logs/peak_processing $SD/execute_Rscript_tworep.sh $WD $WD/results/peak_results1_peaks.narrowPeak $WD/results/peak_results2_peaks.narrowPeak $PROMOTER $SD

else
echo "This script was made for 1 or 2 replicas, if you have more than two, you will need to change the peak_processing.R"
echo "Add params for each extra FILE that you have. In the beginning of the script after $NUMREP and after $PROMOTER inside the function Rscript"
fi



