## Script para determinar los genes dianas de un factor de transcripción
## a partir del fichero narrowPeak generado por MaCS2.

## Autor: Fernando Rodríguez Marín y Julia Pérez Pérez
## Fecha: Noviembre 2019

## Arguments loadings 

args <- commandArgs(trailingOnly = TRUE)

input.file.name1 <- args[[1]]
input.file.name2 <- args[[2]]
promoter.length <- as.numeric(args[[3]])

library(ChIPseeker)
library(TxDb.Athaliana.BioMart.plantsmart28)
anno <- TxDb.Athaliana.BioMart.plantsmart28

## Reading peak file

peaks1 <- readPeakFile(peakfile = input.file.name1,header=FALSE)
peaks2 <- readPeakFile(peakfile = input.file.name2,header=FALSE)
peaks <- intersect(peaks1, peaks2)

## Defining the region that is considered as a promoter 

promoter <- getPromoters(TxDb=anno, 
                         upstream=promoter.length, 
                         downstream=promoter.length)

genes <- as.data.frame(genes(anno))
genes_names <- genes$gene_id
length(genes_names)


## Annotating peaks

peakanno <- annotatePeak(peak = peaks, 
                              tssRegion=c(-promoter.length, promoter.length),
                              TxDb=anno)

## Peaks in each chromosome

covplot(peaks, weightCol="V5", title = "Peaks in each chromosome")

## Binding sites in specific regions of the genome

plotAnnoPie(peakanno)
vennpie(peakanno)

## Distribution of genomic loci relative to TSS

plotDistToTSS(peakanno,
              title="Distribution of genomic loci relative to TSS",
              ylab = "Genomic Loci (%) (5' -> 3')")


## Converting annotation to data frame and writing a table with target genes

annotation_dataframe <- as.data.frame(peakanno)

target_genes <- annotation_dataframe$geneId[annotation_dataframe$annotation == "Promoter"]

write(x = target_genes, file="target_genes.txt")

