#!/bin/bash

if [ "$FTYPE" == "patchgabor" ]; then
  if [ "$PSIZE" == "5" ]; then
    BW=1.47;
  elif [ ${PSIZE} = 9 ]; then
    BW=1.16;
  elif [ ${PSIZE} = 17 ]; then
    BW=1.18;
  else
    echo "Patch size not recognized! Assigning bw = 1.0"
    BW=1.0
  fi
elif [ "$FTYPE" == "patchstats" ]; then
  if [ ${PSIZE} = 5 ]; then
    BW=1.99;
  elif [ ${PSIZE} = 9 ]; then
    BW=1.91;
  elif [ ${PSIZE} = 17 ]; then
    BW=1.59;
  else
    echo "Patch size not recognized! Assigning bw = 1.0"
    BW=1.0
  fi
elif [ "$FTYPE" == "patchgstats" ]; then
  if [ ${PSIZE} = 5 ]; then
    BW=0.63;
  elif [ ${PSIZE} = 9 ]; then
    BW=1.31;
  elif [ ${PSIZE} = 17 ]; then
    BW=1.81;
  else
    echo "Patch size not recognized! Assigning bw = 1.0"
    BW=1.0
  fi
else
  echo "Feature type not recognized! Assigning bw = 1.0"
  BW=1.0
fi

echo "Bandwidth set to ${BW}"
