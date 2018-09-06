# sequence-downloader

Use this command line utility to download a sequence of files and append one onto the other.

## About

This tool was started as a way to download `.ts`-files and appending them in the right order to get the `mp4`-file.

At the moment, it does only create the combined `.ts` file. To get an mp4, you can use e.g. [ffmpeg](https://www.ffmpeg.org)
(`ffmpeg -i 1-all.ts -acodec copy -vcodec copy all.mp4`) or [VideoLAN VLC](http://www.videolan.org).

## Usage

Run the `./ts-downloader.sh` with the download-URL as an argument, e.g. `./ts-downloader.sh url $YOUR_URL`.
Replace the number-sequence from which to generate all URLs with a `#`-sign.

Available options:
 - n: no concatenation of the downloaded files
 - d: delete the partials downloaded
 - h: get help / a list of options
 - v: get the version of this script

## Contributions

Contributions are very welcome, in any form, don't hesitate!

[dispatch.sh](https://github.com/Mosai/workshop/blob/master/doc/dispatch.md) is used to handle arguments & options.

### ToDo

[ ] handle # in URL : replace with other char? Add option?
[ ] require ffmpeg to auto-convert
