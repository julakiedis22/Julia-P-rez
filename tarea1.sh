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
NUMSAM=$(grep number_of_samples: $PARAMS | awk '{ print $2 }')
GENOME=$(grep genome_accesion: $PARAMS | awk '{ print $2 }')
ANNOTATION=$(grep annotation_accesion: $PARAMS | awk '{ print $2 }')

SRACHIP=( )

I=0
while [ $I -lt $NUMSAM ]
do
   SRACHIP[$I]=$(grep srachip$(($I + 1)): $PARAMS | awk '{ print $2 }')
   ((I++))
done


##Debugging printing variable values

echo WD=$WD
echo NUMSAM=$NUMSAM
echo GENOME=$GENOME
echo ANNOTATION=$ANNOTATION

I=0
while [ $I -lt $NUMSAM ]
do
   echo srachip$(($I+1))=${SRACHIP[$I]}
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

while [ $i -le $NUMSAM ]
do
mkdir sample$i
((i++))
done

cd ../input

i=1

while [ $i -le $NUMSAM ]
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

while [ $I -lt $NUMSAM ]
do
   cd $WD/samples/chip/sample$(($I + 1))
   fastq-dump --split-files ${SRACHIP[$I]}
   ((I++))
done



