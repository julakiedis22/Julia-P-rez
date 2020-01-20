# Author: Julia Perez Perez and Fernando Rodriguez Marin
## Date: 12-11-2019
## Contact: julia22898@gmail.com and fernando.rodriguez.marin8@gmail.com

#! /bin/bash

WD=$1
FILE=$2
PROMOTER=$3
SD=$4

Rscript $SD/peak_processing_onerep.R $WD $FILE $PROMOTER

