## Script para determinar los genes dianas de un factor de transcripción
## a partir del fichero narrowPeak generado por MaCS2.

## Autor: Fernando Rodríguez Marín y Julia Pérez Pérez
## Fecha: Noviembre 2019

## Arguments loadings 

args <- commandArgs(trailingOnly = TRUE)

working_directory <- args[[1]]
input.file.name1 <- args[[2]]
input.file.name2 <- args[[3]]
promoter.length <- as.numeric(args[[4]])

## Set working directory

wd <- paste(working_directory, "/results/results_R", sep = "")

setwd(dir = wd)

## Downloading all packages

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

## GO terms enrichment

gene.set <- read.table(file = "target_genes.txt", header = F, as.is = T)[[1]]
length(gene.set)

library(clusterProfiler)
library(org.At.tair.db)

ego <- enrichGO(gene = gene.set, OrgDb = org.At.tair.db, ont = "BP", pvalueCutoff = 0.05, qvalueCutoff = 0.01, universe = genes_names, keyType = "TAIR")
ego.res <- as.data.frame(ego)
head(ego.res)

barplot(ego, showCategory=10)
emapplot(ego, showCategory = 10)

## KEGG enrichment


kk <- enrichKEGG(gene = gene.set, organism = "ath", universe = genes_names)
kk.res <- as.data.frame(kk)
head(kk.res)

library("pathview")

my.universe <- rep(0,length(genes_names))
names(my.universe) <- genes_names
my.universe[gene.set] <- 1

pathways <- kk.res$ID[1:3]

my.first.pathway <- pathview(gene.data = my.universe, pathway.id = pathways[1], species = "ath", gene.idtype = "TAIR")

my.second.pathway <- pathview(gene.data = my.universe, pathway.id = pathways[2], species = "ath", gene.idtype = "TAIR")

my.third.pathwat <- pathview(gene.data = my.universe, pathway.id = pathways[3], species = "ath", gene.idtype = "TAIR")
