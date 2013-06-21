#!/usr/bin/env bash

# Процедура prepare подготавливает каталоги к работе
prepare()
{
	# Получаем название исполнителя из .cue файла
	PERFORMER=$(cueprint -d %P "$1")
	echo "Performer: ${PERFORMER}"

	# Получаем название альбома из .cue файла
	ALBUM_TITLE=$(cueprint -d %T "$1")
	echo "Album title: ${ALBUM_TITLE}"

	YEAR="$3"
	if [ -n "${YEAR}" ];
	then
		DESTDIR="$2/${PERFORMER}/${YEAR} - ${ALBUM_TITLE}"
	else
		DESTDIR="$2/${PERFORMER}/${ALBUM_TITLE}"
	fi

	mkdir -p "${DESTDIR}"
}

# Процедура convert разбивает .ape-файл на несколько .flac файлов
convert()
{
	shnsplit -d "$3" -f "$1" -o "flac flac -V --best -o %f -" "$2" -t "%n %p - %t"
}

# Процедура flactag заполняет метаданными полученные .flac файлы
flactag()
{
	METAFLAC="metaflac --remove-all-tags --import-tags-from=-"
	fields='TITLE ALBUM TRACKNUMBER TRACKTOTAL ARTIST PERFORMER DESCRIPTION GENRE DATE'

	TITLE='%t'
	#VERSION=''
	ALBUM='%T'
	TRACKNUMBER='%n'
	TRACKTOTAL='%N'
	ARTIST='%c %p'
	PERFORMER='%p'
	#COPYRIGHT=''
	#LICENSE=''
	#ORGANIZATION=''
	DESCRIPTION='%m'
	GENRE='%g'
	DATE="$4"
	#LOCATION=''
	#CONTACT=''
	#ISRC='%i %u'

	(for field in ${fields}; do
		value=""
		for conv in `eval echo \\$$field`; do
			value=`cueprint -n $1 -t "${conv}\n" "$3"`

			if [ -n "${value}" ]; then
				echo "${field}=${value}"
				break
			fi
		done
	done) | ${METAFLAC} "$2"
}

main()
{
	CUE_FILE=$1
	DESTDIR=$2
	YEAR=$3

	echo "Source file: ${CUE_FILE}"
	echo "Destination directory: ${DESTDIR}"

	APE_FILE=`echo "${CUE_FILE}" | sed "s/[Cc][Uu][Ee]/ape/"`
	if [ -f "${APE_FILE}" ];
	then
		echo "Ape file: ${APE_FILE}"
	else
		echo "Ape file not found!"
		exit 1
	fi

	prepare "${CUE_FILE}" "${DESTDIR}" "${YEAR}"
	convert "${CUE_FILE}" "${APE_FILE}" "${DESTDIR}"
	trackno=1
	for file in "${DESTDIR}/"*flac; do
		flactag ${trackno} "${file}" "${CUE_FILE}" "${YEAR}"
		trackno=$((${trackno} + 1))
	done
}

main "$@"
