#!/bin/bash

FILES=`find . -name "*.md"`
for fl in $FILES
do
  pt=`echo $fl | awk -F'.' '{print $2}'`
  dt=`grep "Date" $fl | awk -F': ' '{print $2}' | awk -F'-' '{print $1}'`
  sl=`grep "Slug" $fl | awk -F': ' '{print $2}'`
  if [ ! -z $dt ] && [ ! -z $sl ]
  then
    echo "Redirect 301 /"$dt"/"$sl $pt
  fi
done
