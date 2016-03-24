#!/bin/bash
#
# Shell script to run eesen offline transcriber on TEDLIUM test data
# and produce scoring data. Takes as input a pair of corpus files, e.g.
# GaryFlake_2010.stm and GaryFlake_2010.sph
# 

if [ $# -ne 1 ]; then
  echo "Usage: run-scored.sh <basename>"
  echo "where <basename> is the basename of files somewhere with"
  echo "extensions .stm and .sph"
  echo
  echo "./run-scored.sh /vagrant/GaryFlake_2010.stm"
  exit 1;
fi

filename=$(basename "$1")
dirname=$(dirname "$1")
extension="${filename##*.}"
basename="${filename%.*}"

mkdir -p build/audio/base
sox $dirname/$basename.sph -c 1 build/audio/base/$basename.wav rate -v 16k

mkdir -p build/diarization/$basename

# make segments from $1.stm
grep -v "inter_segment_gap" $dirname/$basename.stm | awk '{OFMT = "%.0f"; print $1,$2,$4*100,($5-$4)*100,"M S U S1"}' > build/diarization/$basename/show.seg

make SEGMENTS=show.seg build/trans/$basename/wav.scp

cp $dirname/$basename.stm build/trans/$basename/stm
cp glm build/trans/$basename

make build/output/$basename.{txt,trs,ctm,sbv,srt,labels}
