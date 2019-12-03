#$ -S /bin/bash
#$ -N input_processingprueba
#$ -V
#$ -cwd
#$ -j yes
#$ -o input_processingprueba

#!bin/bash
## Reading input parameters

I=$1
WD=$2
NUMINPUT=$3
NUMSAM=$4
PROMOTER=$5

## Quality study and mappinG

cd $WD/samples/input/sample$I


if [ -e input${I}_2.fastq ]
   then
      fastqc $WD/samples/input/sample$I/input${I}_1.fastq
      fastqc $WD/samples/input/sample$I/input${I}_2.fastq

      bowtie2 -x $WD/genome/index -1 $WD/samples/input/sample$I/input${I}_1.fastq -2 $WD/samples/input/sample$I/input${I}_2.fastq -S input.sam

else

      fastqc $WD/samples/input/sample$I/input${I}.fastq

      bowtie2 -x $WD/genome/index -U $WD/samples/input/sample$I/input${I}.fastq -S $WD/samples/input/sample$I/input.sam
fi

##Generating the bam file

cd $WD/samples/input/sample$I

samtools view -@ 2 -S -b $WD/samples/input/sample$I/input.sam > $WD/samples/input/sample$I/input.bam
rm $WD/samples/input/sample$I/input.sam
samtools sort $WD/samples/input/sample$I/input.bam -o $WD/samples/input/sample$I/input_sorted.bam
rm $WD/samples/input/sample$I/input.bam
samtools index $WD/samples/input/sample$I/input_sorted.bam


## Synchronization point through blackboards

echo "sample${SAMPLE_ID} of input samples DONE" >> $WD/logs/blackboard

DONE_SAMPLES=$(wc -l $WD/logs/blackboard | awk '{ print $1 }')

if [ ${DONE_SAMPLES} -eq $NUMINPUT ]
then

echo "ALL INPUT SAMPLES FINISHED :)"

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



