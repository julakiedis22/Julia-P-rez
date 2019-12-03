#! /bin/bash

WD=$1
PROMOTER=$2
NUMSAM=$3

##Macs2 for creating the jar file

I=1

while [ $I -le $NC ]
do

   macs2 callpeak -t $WD/samples/chip/sample$I/chip_sorted.bam -c $WD/samples/input/sample$I/input_sorted.bam -f BAM --outdir $WD/results -n peak_results$I

   ((I++))
done


qsub -N peak_processing$I.R -o $WD/logs/call_peaks Rscript /home/julfer/tareas/tarea1/Julia-P-rez/peak_processing.R peak_results$[$I]_peaks.narrowPeak $PROMOTER




