First of all, for using this script, you need to be sure of what a ChIP-seq analysis: ChIP sequencing is a method use to analyze protein 
interaction with DNA. ChIP-seq combines chromatine inmunoprecipitation with massively parallel DNA sequencing to identify the binding sites
of DNA-assiciated proteins.
It can be use to map global binding sites pecisely for any protein of interest. In this case, scripts were done to identify the binding 
site of transcriptions factors in a concrete genome.

This scripts are a really interesting tool that were done by Julia Perez-Perez and Fernando Rodriguez-Marin for that users that require
to perform a ChIP-seq analysis with any kind of organism and number of samples. It may help you to reach your conclusion in less time
due to it automatization.

The first thing you may do it is to make a comprehensive reading of this README. Here you will find all the necessary information to perform
the analysis successfully. Read carefully and enjoy!

[[

This program have 5 bash scripts and 1 R script. The only instruction that you have to execute is: "bash pipechip.sh params.txt". This 
instruction will execute pipechip.sh. This script have the orders to create the working directory and copy/download the genome file, the
annotation file and the samples file. Then this script will launch the next scripts to a High Performance Computing (HPC) with "qsub" 
instruction. The script pipechip.sh will launch a script for each sample. 

Next step is the samples processing that is a parallel task. For this reason, pipechip.sh will launch

]]

You can find instructions in each scripts .sh to understand how the processing has been done, but the only file you need to modify is the 
one called "params.txt" that is specific for each analysis. Do not modify the name of the param only the information that is writing after
the ":". Next, you can know the meaning of the params for you to understand how to change them:

- working_directory: it is the path where you will save your results. You need to put the name of your specific folders. It is important 
  to mention that the last folder in the path is the one that will be generated after starting the processing. 

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

After doing           . Before starting the processing, you have to change the file "peak_processing.R" if you have more or less than 
two files of .narrowPeak (more than 4 samples). 

 1)Case 1: more than 4 samples

 1º Add both args and input file you have, adding new arguments. For example, if you have another .narrowPeak: add 
 input.file.name3 <- args[[5]].
 2º In the section called "reading peaks", read as many files as input.file.name. For example, for input_file_name3, name another 
 peaks3.
 3º Add the new peaks in your fuction intersect.
 
 2) Case 2: only 2 samples (one narrow.Peak) 
 1º Delete the input.file.name2. 
 2º In the section called "reading peaks", delete the peaks2.
 3º Delete the fuction intersect. Do not do thes fuction. This is really important.

In this two cases, you will also need to change the script "execute_scriptR.sh" adding the new args that you have or deleting the args
that you do not use. 
