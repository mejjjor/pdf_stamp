#!/bin/sh
FILE=$1

#split pdf by page
pdftk $FILE burst output split_%02d.pdf compress
echo "File $FILE splited"

# for each page
INDEX=0
for PAGE in split_*.pdf
do
	INDEX=$((INDEX+1))

	CURRENT_TEMPLATE="template_empty.pdf"

	if pdfgrep -i "arrco" $PAGE > /dev/null 2>&1; then
		CURRENT_TEMPLATE="template_assedic.pdf"
	fi

	if pdfgrep -i "Si vous n’êtes pas inscrit à notre Caisse, contactez-nous à l’adresse ci-dessus mentionnée afin que nous procédions à votre immatriculation." $PAGE > /dev/null 2>&1; then
		CURRENT_TEMPLATE="template_conges_spectacles.pdf"
	fi

	BACKGROUNDS_TEMPLATE=$"$BACKGROUNDS_TEMPLATE${CURRENT_TEMPLATE} "

	echo "Page $INDEX done with $CURRENT_TEMPLATE"
done

#create background stamp
pdftk $BACKGROUNDS_TEMPLATE cat output background.pdf
echo "Stamp created"

OUTPUT_FILE=${FILE::-4}_signed.pdf
#create new pdf signed
pdftk $FILE multistamp background.pdf output $OUTPUT_FILE
echo "Stamp applied"

# clean
rm -rf split_*.pdf background.pdf doc_data.txt
echo "Folder clean"
echo "File $OUTPUT_FILE is ready ! "
