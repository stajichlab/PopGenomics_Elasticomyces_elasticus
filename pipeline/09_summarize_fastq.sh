#!/usr/bin/bash -l 
#SBATCH -p short -N 1 -n 4 --mem 8gb --out logs/bbmap_sum_fastq.%a.log -a 1-16
module load workspace/scratch
module load BBMap

OUTDIR=input_stats
if [ -f config.txt ]; then
  source config.txt
fi
mkdir -p $OUTDIR
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi

MAX=$(wc -l $SAMPFILE | awk '{print $1}')
if [ $N -gt $MAX ]; then
  echo "$N is too big, only $MAX lines in $SAMPFILE"
  exit
fi

IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read STRAIN FILEBASE
do
  PREFIX=$STRAIN
  FINALFILE=$OUTDIR/$STRAIN
  echo "To process $PREFIX and $FINALFILE"
  if [ ! -s $FINALFILE ]; then

    for BASEPATTERN in $(echo $FILEBASE | perl -p -e 's/\;/,/g');
    do
      BASE=$(basename $BASEPATTERN | perl -p -e 's/(\S+)\[12\].+/$1/g; s/_R?$//g;')
      READS=()
      for file in $(ls -1 $FASTQFOLDER/$BASEPATTERN | perl -p -e 's/\n/,/g')
      do
	  READS+=($file)
      done
      
      LEFT=${READS[0]}
      RIGHT=${READS[1]}
      reformat.sh in=$LEFT in2=$RIGHT bhist=$FINALFILE.bhist.txt >& $FINALFILE.summary.txt
    done
  fi
done
