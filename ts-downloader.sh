#!/bin/bash

# load the dispatch library
. "./workshop/lib/workshop/dispatch.sh"

# options to be set
CONCAT=1
DELETE_PARTIALS=1

# ---
# global helper functions
# check if an URL exists - https://stackoverflow.com/questions/2924422/how-do-i-determine-if-a-web-page-exists-with-shell-scripting
function url_exists () {
  STATUS=$(curl -s --head -w %{http_code} "$1" -o /dev/null)
  [[ "$STATUS" = 200 ]] && return
}

# download file using wget – param 1 is the URL, param 2 the target file
function download () {
  wget --retry-connrefused --tries=25 -q -O $1 $2 # other possible options: --waitretry=1 --read-timeout=20 --timeout=15
}

# ---
# actual program

# empty call placeholder
function tsd_ () {
  DATE="$(date '+%Y-%m-%d-%H-%M-%S')"
  PARTIALSDIR="partials-${DATE}"
  mkdir -p "$PARTIALSDIR"
  cd "$PARTIALSDIR" || { echo "Error: Could not create temp directory '$PARTIALSDIR'."; exit 1; }

  # number of urls as we can handle more than one
  URL_CNT=0

  # handle all passed urls
  for URL in "$@"
  do
    echo $URL
    # create folder for streaming media
    URL_CNT=$((URL_CNT + 1)) # there are syntax alternatives; e.g. (( URL_CNT++ ))

    mkdir -p $URL_CNT
    cd $URL_CNT || exit

    (
      VIDEO_CNT=0
      # attempts: how many not-existing urls to tolerate
      ATTEMPT=0

      # download all videos
      while [ $ATTEMPT -lt 10 ]
      do
        P_URL=$(echo $URL | sed 's/#/'$VIDEO_CNT'/')

        if url_exists "$P_URL"
        then
          # download!
          download video$VIDEO_CNT.ts $P_URL &
        else
          ATTEMPT=$(($ATTEMPT + 1))
        fi
        # we want to start at 0, that's why we increase last
        VIDEO_CNT=$(($VIDEO_CNT + 1))
      done
      wait

      echo "Downloaded $VIDEO_CNT files minus $ATTEMPT fails."

      # link videos
      if [ $CONCAT = 1 ]
        then
          echo  "Linking..."
          ls -1 -- video*.ts | sort -n -k1.6 > tslist.txt # Mac does not support ls -v, that is why sort is used too
          while read -r line
          do
            cat "$line" >> "$DATE-$URL_CNT-all.ts";
          done < tslist.txt
          # move file out of url dir, partials dir
          mv "$DATE-$URL_CNT-all.ts" ../..
      fi
    ) &
    # cd out of $URL_CNT dir
    cd ..
  done
  wait

  # cd out of partials dir
  cd ..
  if [ $DELETE_PARTIALS = 1 ]
    then
      rm -rf "$PARTIALSDIR"
  fi

  echo "Processed $URL_CNT URLs"

  exit 0
}

function tsd_call_ () {
  tsd_ "$@"
}

function tsd_command_url () {
  tsd_ "$@"
}

# ---
# parse & react to options

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


