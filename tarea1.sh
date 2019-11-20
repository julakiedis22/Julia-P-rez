## Author: Julia Perez Perez and Fernando Rodriguez Marin
## Date: 12-11-2019 
## Contact: julia

#! /bin/bash

if [ $# -eq 0 ]
  then
    echo "This pipeline analysis Chip-seq data."
    echo "Usage: piperna.sh <param_file>"
    echo ""
    echo "param_file: File with the parameters specifications. Please, check test/params.txt for an example"
    echo ""
    echo "No te ralle un pelo, a la siguiente te sale fijo!"

   exit 0
fi

## Parameters loading

PARAMS=$1

WD=$(grep working_directory: $PARAMS | awk '{ print $2 }')
CF=$(grep copy_files: $PARAMS | awk '{ print $2 }')
NUMSAM=$(grep number_of_samples: $PARAMS | awk '{ print $2 }')
NUMCHIP=$(grep number_of_chip: $PARAMS | awk '{ print $2 }')
NUMINPUT=$(grep number_of_input: $PARAMS | awk '{ print $2 }')
GENOME=$(grep genome_accesion: $PARAMS | awk '{ print $2 }')
ANNOTATION=$(grep annotation_accesion: $PARAMS | awk '{ print $2 }')

SRACHIP=( )

I=0
while [ $I -lt $NUMCHIP ]
do
   SRACHIP[$I]=$(grep srachip$(($I + 1)): $PARAMS | awk '{ print $2 }')
   ((I++))
done


SRAINPUT=( )

I=0
while [ $I -lt $NUMINPUT ]
do
   SRAINPUT[$I]=$(grep srainput$(($I + 1)): $PARAMS | awk '{ print $2 }')
   ((I++))
done

FILESCHIP=( )

I=0
while [ $I -lt $NUMCHIP ]
do
   FILESCHIP[$I]=$(grep directorychip$(($I + 1)): $PARAMS | awk '{ print $2 }')
   ((I++))
done


FILESINPUT=( )

I=0
while [ $I -lt $NUMINPUT ]
do
   FILESINPUT[$I]=$(grep directoryinput$(($I + 1)): $PARAMS | awk '{ print $2 }')
   ((I++))
done



##Debugging printing variable values

echo WD=$WD
echo NUMSAM=$NUMSAM
echo GENOME=$GENOME
echo ANNOTATION=$ANNOTATION

I=0
while [ $I -lt $NUMCHIP ]
do
   echo srachip$(($I+1))=${SRACHIP[$I]}
   ((I++))
done

I=0
while [ $I -lt $NUMINPUT ]
do
   echo srainput$(($I+1))=${SRAINPUT[$I]}
   ((I++))
done



##Generate working directory

mkdir $WD
cd $WD
mkdir genome annotation samples results logs
cd samples
mkdir chip input

cd chip

i=1

while [ $i -le $NUMCHIP ]
do
mkdir sample$i
((i++))
done

cd ../input

i=1

while [ $i -le $NUMINPUT ]
do
mkdir sample$i
((i++))
done


##Dowloading reference genome and annotation

cd $WD/genome
wget -O genome.fa.gz $GENOME
gunzip genome.fa.gz

cd ../annotation
wget -O annotation.gtf.gz $ANNOTATION
gunzip annotation.gtf.gz

## Building reference genome index
cd ../genome
bowtie2-build genome.fa index 

## Downloading samples chip

cd $WD/samples/chip

I=0
J=0

if [ $CF -eq 1 ]
then
   while [ $I -lt $NUMCHIP ]
   do
      cp ${FILESCHIP[$I]} $WD/samples/chip/sample$(($I + 1))/sample$(($I + 1)).fastq
      ((I++))
   done

elif [ $CF -eq 0 ]
then
   while [ $J -lt $NUMCHIP ]
   do
      cd $WD/samples/chip/sample$(($J + 1))
      fastq-dump --split-files ${SRACHIP[$J]}
      ((J++))
   done
else
   echo "What"
fi


##Downaloadins samples input

cd $WD/samples/input


I=0
J=0

if [ $CF -eq 1 ]
then
   while [ $I -lt $NUMINPUT ]
   do
      cp ${FILESINPUT[$I]} $WD/samples/input/sample$(($I + 1))/sample$(($I + 1)).fastq
      ((I++))
   done

elif [ $CF -eq 0 ]
then 
   while [ $J -lt $NUMINPUT ]
   do
      cd $WD/samples/input/sample$(($J + 1))
      fastq-dump --split-files ${SRAINPUT[$J]}
      ((J++))
   done
else
   echo "What"
fi



## Chip processing

I=1
J=1

if [ $CF -eq 1 ]
then
   while [ $I -le $NUMCHIP ]
   do
      qsub -N chip$I -o $WD/logs/chip$I /home/julfer/tareas/tarea1/Julia-P-rez/chip_processingprueba.sh $I $WD $NUMCHIP 0 $WD/samples/chip/sample$I/sample$I.fastq
      ((I++))
   done

elif [ $CF -eq 0 ]
then
   while [ $J -lt $NUMCHIP ]
   do
      qsub -N chip$J -o $WD/logs/chip$J /home/julfer/tareas/tarea1/Julia-P-rez/chip_processing.sh $J $WD $NUMCHIP ${SRACHIP[$J]} 0
      ((J++))
   done
else
   echo "What"
fi


## Input processing

I=1
J=1

if [ $CF -eq 1 ]
then
   while [ $I -le $NUMINPUT ]
   do
      qsub -N input$I -o $WD/logs/input$I /home/julfer/tareas/tarea1/Julia-P-rez/input_processingprueba.sh $I $WD $NUMINPUT 0 $WD/samples/input/sample$I/sample$I.fastq
      ((I++))
   done

elif [ $CF -eq 0 ]
then
   while [ $J -lt $NUMINPUT ]
   do
      qsub -N input$J -o $WD/logs/input$J /home/julfer/tareas/tarea1/Julia-P-rez/input_processing.sh $J $WD $NUMINPUT ${SRAINPUT[$J]} 0
      ((J++))
   done
else
   echo "What"
fi


