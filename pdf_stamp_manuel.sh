#!/bin/sh
FILE=$1
#build template list
TEMPLATE_PROMPT=''
INDEX=0
for TEMPLATE in template_*.pdf
do
	TEMPLATE_PROMPT=$"$TEMPLATE_PROMPT$INDEX) $TEMPLATE
" 
	TEMPLATE_ARRAY[INDEX]=$TEMPLATE
	INDEX=$((INDEX+1))
done

#split pdf by page
pdftk $FILE burst output split_%02d.pdf compress

# for each page
INDEX=0
for PAGE in split_*.pdf
do
	qpdfview $PAGE > /dev/null 2>&1 & 
	read -p "
Choose (page: $INDEX):
$TEMPLATE_PROMPT" TEMPLATE_SELECTED
	BACKGROUNDS_TEMPLATE=$"$BACKGROUNDS_TEMPLATE${TEMPLATE_ARRAY[$TEMPLATE_SELECTED]} "
	kill $!
	INDEX=$((INDEX+1))
done

#create background stamp
pdftk $BACKGROUNDS_TEMPLATE cat output background.pdf

#create new pdf signed
pdftk $FILE multibackground background.pdf output ${FILE::-4}_signed.pdf

#clean
rm -rf split_*.pdf background.pdf doc_data.txt