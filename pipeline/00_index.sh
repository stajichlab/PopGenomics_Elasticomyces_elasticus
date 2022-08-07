#!/usr/bin/bash -l
module load samtools
module load bwa
if [ -f config.txt ]; then
	source config.txt
fi
mkdir -p $GENOMEFOLDER
# THIS IS EXAMPLE CODE FOR HOW TO DOWNLOAD DIRECT FROM FUNGIDB
FASTAFILE=$REFGENOME
if [[ ! -f $FASTAFILE.fai || $FASTAFILE -nt $FASTAFILE.fai ]]; then
	samtools faidx $FASTAFILE
fi
if [[ ! -f $FASTAFILE.bwt || $FASTAFILE -nt $FASTAFILE.bwt ]]; then
	bwa index $FASTAFILE
fi

DICT=$GENOMEFOLDER/$(basename $FASTAFILE .fasta)".dict"

if [[ ! -f $DICT || $FASTAFILE -nt $DICT ]]; then
	rm -f $DICT
	samtools dict $FASTAFILE > $DICT
	ln -s $(basename $DICT) $GENOMEFOLDER/$FASTAFILE.dict 
fi
grep ">" $FASTAFILE | perl -p -e 's/>((Chr)?(\d+|mito)_\S+)\s+.+/$1,$3/' > $GENOMEFOLDER/chrom_nums.csv
