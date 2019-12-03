#$ -S /bin/bash
#$ -N chip_processingprueba
#$ -V
#$ -cwd
#$ -j yes
#$ -o chip_processingprueba

#!bin/bash
## Reading input parameters

I=$1
WD=$2
NUMCHIP=$3
NUMSAM=$4
PROMOTER=$5

## Quality study and mappinG

cd $WD/samples/chip/sample$I


if [ -e chip${I}_2.fastq ]
   then
      fastqc $WD/samples/chip/sample$I/chip${I}_1.fastq
      fastqc $WD/samples/chip/sample$I/chip${I}_2.fastq

      bowtie2 -x $WD/genome/index -1 $WD/samples/chip/sample$I/chip${I}_1.fastq -2 $WD/samples/chip/sample$I/chip${I}_2.fastq -S chip.sam

else

      fastqc $WD/samples/chip/sample$I/chip${I}.fastq

      bowtie2 -x $WD/genome/index -U $WD/samples/chip/sample$I/chip${I}.fastq -S $WD/samples/chip/sample$I/chip.sam
fi

##Generating the bam file 

cd $WD/samples/chip/sample$I

samtools view -@ 2 -S -b $WD/samples/chip/sample$I/chip.sam > $WD/samples/chip/sample$I/chip.bam
rm $WD/samples/chip/sample$I/chip.sam
samtools sort $WD/samples/chip/sample$I/chip.bam -o $WD/samples/chip/sample$I/chip_sorted.bam
rm $WD/samples/chip/sample$I/chip.bam
samtools index $WD/samples/chip/sample$I/chip_sorted.bam


## Synchronization point through blackboards

echo "sample${SAMPLE_ID} of chip samples DONE" >> $WD/logs/blackboard

DONE_SAMPLES=$(wc -l $WD/logs/blackboard | awk '{ print $1 }')

if [ ${DONE_SAMPLES} -eq $NUMCHIP ]
then

echo "ALL CHIP SAMPLES FINISHED :)"

fi

if [ ${DONE_SAMPLES} -eq $NUMSAM ]
then

echo "ALL SAMPLES FINISHED :)"

fi
I=1
while [ $I -le $NUMCHIP ]
do
   qsub -N call_peaks$I -o $WD/logs/call_peaks$I /home/julfer/tareas/tarea1/Julia-P-rez/call_peaks.sh $WD $PROMOTER $NUMCHIP
   rm $WD/logs/blackboard
done

