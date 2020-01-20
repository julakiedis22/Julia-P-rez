INTRODUCTION

First of all, for using this script, you need to be sure of what a ChIP-seq analysis: ChIP sequencing is a method use to analyze protein 
interaction with DNA. ChIP-seq combines chromatine inmunoprecipitation with massively parallel DNA sequencing to identify the binding sites
of DNA-associated proteins.

It can be use to map global binding sites pecisely for any protein of interest. In this case, scripts were done to identify the binding 
site of transcriptions factors in a concrete genome.

This scripts are a really interesting tool that were done by Julia Perez-Perez and Fernando Rodriguez-Marin for that users that require
to perform a ChIP-seq analysis with any kind of organism and number of samples. It may help you to reach your conclusion in less time
due to it automatization.

The first thing you may do it is to make a comprehensive reading of this README. Here you will find all the necessary information to perform
the analysis successfully. Read carefully and enjoy!

NECESSARY TOOLS

Below there is a list of all the programs that is necessary to install for the correct execution of this program. Obviously, this program 
use R scripts, so you have to install R. 

 - Bowtie 2
 - Fastqc
 - Samtools
 - MACS2
 - HOMER and genome data (tair10)
 - ChIPseeker (R package)
 - TxDb.Athaliana.BioMart.plantsmart28 or annotation package of the organism of study (R package)
 - clusterProfiler (R package)
 - org.At.tair.db or .db data of the organism of study (R package)
 - pathview (R package)

SAMPLES THAT CAN BE PROCESSED WITH THIS PROGRAM

It is important to know what samples can be processed with this program and what you have to modify if this program can't process your 
samples.

 - This program only can be used for experiments that have the same number of chip samples than input samples. You have to modify some 
 parameters of call_peaks.sh if you want to use this program for different conditions.

 - This program can process paired data and unpaired data
 
 - This program only can process Arabidopsis thaliana samples. If you want use other organism, you will have to change the annotation 
 package and .db data of peak_processing_onerep.R and peak_processing_tworep.R. Also, you have to modify the genome data for Arabidopsis
 thaliana (tair10) in findMotifsGenome.pl function for HOMER. 

 - This program only can be used for experiments with 1 or 2 replicas. If your experiment have more than 2 replicas, modify 
 peak_processing_onerep.R and peak_processing_tworep.R following the next instructions: 

	1º Add both args and input file you have, adding new arguments. For example, if you have another .narrowPeak: add
	input.file.name3 <- args[[4]].
	2º In the section called "reading peaks", read as many files as input.file.name. For example, for input_file_name3, name another 
	peaks3.
	3º Add the new peaks in your fuction intersect.

 In this case, you will also need to change the script "execute_scriptR.sh" adding the new args that you have or deleting the args that you
 do not use. You will need to change PipeChSq.sh and you will need to add new parameters in params.txt. 

HOW IT WORKS

This program have 6 bash scripts and 2 R script. The only instruction that you have to execute is: "bash PipeChSq.sh params.txt". This 
instruction will execute PipeChSq.sh. This script have the orders to create the working directory and copy/download the genome file, the
annotation file and the samples files. Then, this script will launch the next scripts to a High Performance Computing (HPC) with "qsub" 
instruction. The script PipeChSq.sh will launch a script for each sample. 

Next step is the samples processing that is a parallel task. For this reason, PipeChSq.sh will launch one script for each sample. This job
will be executed by two of the 6 bash scripts: chip_processing.sh and input_processing.sh. Obviously, chip_processing.sh will process chip
samples and input_processing.sh will process input samples. This two scripts have the same instructions. This scripts will do a quality 
study using fastqc and it will map the short sequences with reference genome using bowtie2. Important:This program can process paired-data 
and unpair data. Next, the script will generate the .bam file using samtools and it will use a synchronization point through blackboards 
to launch one call_peaks.sh (next script) for each replica in the right moment. 

Next script is call_peaks.sh. One call_peaks will be launched for each replicas (for each chip and input samples). This script use MACS2
to create a peakAnnotation file though sorted .bam files, that are generated with chip_processing.sh and input_processing.sh. Also, this 
script will find motifs in the genome using HOMER tool. This process can take a while, be patient. Then, if the number of replicas of your
experiment is 1, call_peaks.sh will launch execute_Rscript_onerep.sh. If the number of replicas of your experiment is 2, call_peaks.sh
will launch execute_Rscript_tworep.sh. If the number of replicas is higher than 2, you must edit the scripts like we tell at the end of 
this file.

The last two bash scripts are execute_Rscript_onerep.sh and execute_Rscript_tworep.sh. These are the same script, but first of them is used
to experiments with 1 replicas and second of them is used to experiment with 2 replicas. Only use Rscript function to execute the R scripts.

Finally, the two R scripts (peak_processing_onerep.R and peak_processing_tworep.R) are the same script too, but with some differences. The 
first script is used to experiments with 1 replicas and second of them is used to experiment with 2 replicas. Function intersect is used by
second script. These scripts will extract the peaks and the relative position in the genome of these peaks. This position will show us some
information about the transcription factor, for this reason some plots are generated. Also, these scripts will generate a target_genes.txt
with all the genes which there is a peak in his promoter. With this file, the scripts will execute an enrichment of gene ontology and a 
enrichment of KEGG pathways. This can be useful to understand the role of the transcription factor that we are studying. Some plots will be 
generated, including the 3 more significant KEGG pathways affected by the transcription factor.  

PARAMETERS

You can find instructions in each scripts to understand how the processing has been done, but the only file you need to modify is the one 
called "params.txt", that is in "test" folder, that is specific for each analysis. You can find an example in this folder (test) Do not 
modify the name of the param only the information that is writing after the ":". Next, you can know the meaning of the params for you to 
understand how to change them:

- working_directory: it is the path where you will save your results. You need to put the name of your specific folders. It is important 
  to mention that the last folder in the path is the one that will be generated after starting the processing. 

- scripts_directory: it is the path where is all the scripts.

Now you will find a bifurcation of the parameters. You have two options depending how you will adquire your genome file, annotation file
and samples. The first option is to copy them from another folder (if you have them downloaded). Otherwise, you can add the link of the 
files from your favourite database. You can decide if you want to copy or download the next files: genome file, annotation file and samples.

- copy_genome: it is the parameter that allows you to copy or download the genome.fa file. If you want to copy write: YES. If you want 
  to download write: NO. 

- copy_annotation: it is the parameter that allows you to copy or download the annotation.gtf file. If you want to copy write: YES. If 
  you want to download write: NO.
 
- genome_accesion: it defines where your genome.fa is. If you will copy from another folder you must paste the path. Otherwise, paste 
  the link of the database. 

- annotation_accesion: it defines where your annotation.gtf is. If you will copy from another folder you must paste the path. Otherwise, 
  paste the link of the database.

- copy_samples: it is the parameter that allows you to copy or download the samples files. If you want to copy write: YES. If you want to 
  download write: NO.

- number_of_samples: it defines the number of samples that you have. It includes chip and input samples. 

- number_of_chip: it defines the number of chip samples that you have. It does not include input samples.

- number_of_input: it defines the number of input samples that you have. It does not include chip samples.

It is important to know that if you have more than 2 chip or 2 input you will need to add others parameters, one for each extra sample. 
For example, if you have another chip sample, you have to add a new parameter below of samplechip2 called samplechip3:. It is important 
the name of the parameter and ":". You will come across an error if you forget one of this things. 

- samplechip1: it defines where your first chip sample is. If you will copy from another folder you must paste the path. Otherwise,
  paste the SRR number of NCBI.

- samplechip2: it defines where your second chip sample is. If you will copy from another folder you must paste the path. Otherwise,
  paste the SRR number of NCBI.

- sampleinput1: it defines where your first input sample is. If you will copy from another folder you must paste the path. Otherwise,
  paste the SRR number of NCBI.

- sampleinput2: it defines where your second input sample is. If you will copy from another folder you must paste the path. Otherwise,
  paste the SRR number of NCBI.

- promoter_lenght: it defines the length in pair of bases that you consider the promoter for your analysis. 

You will find different messages to make sure that the processing is going fine. You can find how is everything going in the folder "logs"
inside your working directory after doing the first "qsub", before this all the messages will appear in your terminal. 
