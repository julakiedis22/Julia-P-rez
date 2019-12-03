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
CG=$(grep copy_genome: $PARAMS | awk '{ print $2 }')
CA=$(grep copy_annotation: $PARAMS | awk '{ print $2 }')
CS=$(grep copy_samples: $PARAMS | awk '{ print $2 }')
NUMSAM=$(grep number_of_samples: $PARAMS | awk '{ print $2 }')
NUMCHIP=$(grep number_of_chip: $PARAMS | awk '{ print $2 }')
NUMINPUT=$(grep number_of_input: $PARAMS | awk '{ print $2 }')
GENOME=$(grep genome_accesion: $PARAMS | awk '{ print $2 }')
ANNOTATION=$(grep annotation_accesion: $PARAMS | awk '{ print $2 }')
PROMOTER=$(grep promoter_length: $PARAMS | awk '{ print $2 }')
FILESCHIP=( )

I=0
while [ $I -lt $NUMCHIP ]
do
   FILESCHIP[$I]=$(grep samplechip$(($I + 1)): $PARAMS | awk '{ print $2 }')
   ((I++))
done


FILESINPUT=( )

I=0
while [ $I -lt $NUMINPUT ]
do
   FILESINPUT[$I]=$(grep sampleinput$(($I + 1)): $PARAMS | awk '{ print $2 }')
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
   echo samplechip$(($I+1))=${FILESCHIP[$I]}
   ((I++))
done

I=0
while [ $I -lt $NUMINPUT ]
do
   echo sampleinput$(($I+1))=${FILESINPUT[$I]}
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

if [ $CG == "YES" ]
then

   cp $GENOME $WD/genome/genome.fa

elif [ $CG == "NO" ]
then
cd $WD/genome
wget -O genome.fa.gz $GENOME
gunzip genome.fa.gz

else
echo "Please, check params.txt file and write YES/NO in copy_genome:"
exit
fi

if [ $CA == "YES" ]
then

   cp $ANNOTATION $WD/annotation/annotation.gtf

elif [ $CA == "NO" ]
then
cd $WD/annotation
wget -O annotation.gtf.gz $ANNOTATION
gunzip annotation.gtf.gz
else
echo "Please, check params.txt file and write YES/NO in copy_annotation:"
exit
fi


## Building reference genome index

cd $WD/genome

bowtie2-build $WD/genome/genome.fa index

## Downloading samples chip

cd $WD/samples/chip

I=0

if [ $CS == "YES" ]
then
while [ $I -lt $NUMCHIP ]
do
   cp ${FILESCHIP[$I]} $WD/samples/chip/sample$(($I+1))/chip$(($I+1)).fastq
   ((I++))
done
elif [ $CS == "NO" ]
then
while [ $I -lt $NUMCHIP ]
do
   cd $WD/samples/chip/sample$(($I + 1))
   fastq-dump --split-files ${FILESCHIP[$I]}
   if [ -e ${FILESCHIP[$I]}_2.fastq ]
   then 
   mv ${FILESCHIP[$I]}_1.fastq chip$(($I+1))_1.fastq
   mv ${FILESCHIP[$I]}_2.fastq chip$(($I+1))_2.fastq
   ((I++))
   else
   mv ${FILESCHIP[$I]}_1.fastq chip$(($I+1)).fastq
   ((I++))
   fi 
done
else
echo "Please, check params.txt file and write YES/NO in copy_samples:"
exit
fi

#Downaloadins samples input

cd $WD/samples/input

I=0

if [ $CS == "YES" ]
then
   while [ $I -lt $NUMINPUT ]
   do
      cp ${FILESINPUT[$I]} $WD/samples/input/sample$(($I + 1))/input$(($I + 1)).fastq
      ((I++))
   done

elif [ $CS == "NO" ]
then   
while [ $I -lt $NUMINPUT ]
   do
      cd $WD/samples/input/sample$(($I + 1))
      fastq-dump --split-files ${FILESINPUT[$I]}
   if [ -e ${FILESINPUT[$I]}_2.fastq ]
   then
   mv ${FILESINPUT[$I]}_1.fastq input$(($I+1))_1.fastq
   mv ${FILESINPUT[$I]}_2.fastq input$(($I+1))_2.fastq
   ((I++))
   else
   mv ${FILESINPUT[$I]}_1.fastq input$(($I+1)).fastq
   ((I++))
   fi
done
else
echo "Please, check params.txt file and write YES/NO"
exit
fi

## Chip processing

I=1

while [ $I -le $NUMCHIP ]
do
   qsub -N chip$I -o $WD/logs/chip$I /home/julfer/tareas/tarea1/Julia-P-rez/chip_processing.sh $I $WD $NUMCHIP $NUMSAM $PROMOTER
   ((I++))
done

## Input processing

I=1

while [ $I -le $NUMINPUT ]
do
   qsub -N input$I -o $WD/logs/input$I /home/julfer/tareas/tarea1/Julia-P-rez/input_processing.sh $I $WD $NUMINPUT $NUMSAM $PROMOTER
   ((I++))
done
