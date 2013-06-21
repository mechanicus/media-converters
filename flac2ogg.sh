#!/bin/bash
file=${1/.flac/}
qual=$2
echo "   File: $file.flac"
echo "Quality: $qual"
title=`metaflac --show-tag="title" "$file.flac" | sed "s/title=//i"`
artist=`metaflac --show-tag="artist" "$file.flac" | sed "s/artist=//i"`
album=`metaflac --show-tag="album" "$file.flac" | sed "s/album=//i"`
date=`metaflac --show-tag="date" "$file.flac" | sed "s/date=//i"`
genre=`metaflac --show-tag="genre" "$file.flac" | sed "s/genre=//i"`
track=`metaflac --show-tag="tracknumber" "$file.flac" | sed "s/tracknumber=//i"`

flac -c -d "$file.flac" | oggenc -t "$title" -a "$artist" -G "$genre" -l "$album" \
 -d "$date" -n "$track" -o "$file".ogg -q "$qual" -
