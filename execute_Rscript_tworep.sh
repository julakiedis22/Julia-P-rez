# Author: Julia Perez Perez and Fernando Rodriguez Marin
## Date: 12-11-2019
## Contact: julia22898@gmail.com and fernando.rodriguez.marin8@gmail.com

#! /bin/bash

WD=$1
FILE1=$2
FILE2=$3
PROMOTER=$4
SD=$5

Rscript $SD/peak_processing_tworep.R $WD $FILE1 $FILE2 $PROMOTER

