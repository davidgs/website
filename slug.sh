#!/bin/bash

FILES=`find content/posts -name "*.md"`

for fl in $FILES
do
  echo $fl
  pt=`echo $fl | awk -F'.' '{print $1}'`
  dt=`grep "Date" $fl | awk -F': ' '{print $2}' | awk -F'-' '{print $1}'`
  sl=`grep "Slug" $fl | awk -F': ' '{print $2}'`
  echo $sl
  if [ ! -z $dt ] && [ ! -z $sl ]
  then
    echo "Redirect 301 /"$dt"/"$sl $pt
  fi
done
