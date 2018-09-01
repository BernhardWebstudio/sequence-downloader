#!/bin/bash

# load the dispatch library
. "./workshop/lib/workshop/dispatch.sh"

# options to be set
CONCAT=1
DELETE_PARTIALS=0

# empty call placeholder
function tsd_ () {
  mkdir partials
  cd partials || echo "Error: Could not create temp directory." && exit 1

  # number of urls as we can handle more than one
  CNT=0

  # handle all passed urls
  for URL in "$@"
  do
    # create folder for streaming media
    CNT=$((CNT + 1))
    mkdir $CNT
    cd $CNT || exit

    (
      # download all videos
      # TODO: change to while to check which exist at all
      for VIDEO_CNT in {1..100}
        do
          # use 12 "threads" for download
          for SUB_CNT in {1..12}
          do
            (
              ACTUAL_CNT=$(($VIDEO_CNT*$SUB_CNT))
              P_URL=$(echo $URL | sed 's/#/'$ACTUAL_CNT'/')
              # TODO: handle errors
              wget -q -O video$ACTUAL_CNT.ts $P_URL || true
            ) &
          done
          wait
      done
      wait

      # link videos
      if [ $CONCAT = 1 ]
        then
          echo "video"{1..1200}".ts " | tr " " "\\n" > tslist.txt
          while read line; do cat $line >> $CNT.mp4; done < tslist.txt
          # concat finished, delete old
          rm -rf video* tslist.txt
          # move file out of url dir, partials dir
          mv $CNT.mp4 ../..
      fi
    ) &
    # cd out of $CNT dir
    cd ..
  done

  # cd out of partials dir
  cd ..
  if [ $DELETE_PARTIALS = 1 ]
    then
      rm -rf partials
  fi

  exit 0
}

function tsd_option_v () {
  echo "Version 0.0"
}

function tsd_option_help () {
  echo "Usage: ts-downloader [options] [urls]"
  echo "Options:"
  echo "  -n  No concatenation; use this if you do not want to create one file from the smaller files"
  echo "  -d  Delete the temporary partials directory. Pay attention to use this option too in case you use option -n"
}

function tsd_option_h () {
  tsd_option_help
}

function tsd_option_d () {
  DELETE_PARTIALS=1; dispatch tsd "$@"
}

function tsd_option_n () {
  CONCAT=0; dispatch tsd "$@"
}

# run download
dispatch tsd "$@"


