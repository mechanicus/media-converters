#!/usr/bin/env bash

File=${1/.flac/}
Quality=$2

echo "   File: ${File}.flac"
echo "Quality: ${Quality}"

getTag()
{
	eval tag=\$${1}
	eval ${1}=`metaflac --show-tag="${tag}" "${2}" | sed s/${tag}=//i | sed "s/ /\\\\\ /g"`
}

Fields='Title Artist Album Date Genre Track'

Title='title'
Artist='artist'
Album='album'
Date='date'
Genre='genre'
Track='tracknumber'

for Field in ${Fields}; do
	getTag "${Field}" "${File}.flac"
done

flac -c -d "${File}.flac" | oggenc -t "${Title}" -a "${Artist}" -G "${Genre}" -l "${Album}" -d "${Date}" -N "${Track}" -o "${File}.ogg" -q "${Quality}" -
