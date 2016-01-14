#!/bin/bash
DATE_TOKEN=`date "+%Y_%m_%d"`
DOWNLOADED_FILE="input/ofac_full_$DATE_TOKEN.xml"
OUTPUT_DIR="output_$DATE_TOKEN"
DICT="dictionary/alldictionary.html"

############################################## DOWNLOAD FULL DAILY

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
echo "fetching full"
wget http://www.treasury.gov/ofac/downloads/sdn.xml -q -O temp
sed -e 's/<sdnList xmlns:xsi="http:\/\/www.w3.org\/2001\/XMLSchema-instance" xmlns="http:\/\/tempuri.org\/sdnList.xsd">/<sdnList>/' temp > "$DOWNLOADED_FILE"
rm temp
echo "generating program based files"

dos2unix $DOWNLOADED_FILE

function doprogram {
  PROGRAM=$1
  file="$OUTPUT_DIR/ofac_program_$PROGRAM.xml"
  xmllint --xpath "//program[text()='$PROGRAM']//ancestor::sdnEntry" "$DOWNLOADED_FILE" > $file
   echo "<?xml version=\""1.0\"" standalone=\""yes\""?>" >> $file.tmp
   #echo "<sdnList xmlns:xsi=\""http://www.w3.org/2001/XMLSchema-instance\"" xmlns=\""http://tempuri.org/sdnList.xsd\"">" >> $file.tmp
   echo "<sdnList>" >> $file.tmp
   cat $file >> $file.tmp
   echo "</sdnList>" >> $file.tmp
   mv $file.tmp $file
}

############################################# GENERATE PROGRAM FILES FROM FULL FILE
doprogram "BURMA"
doprogram "CUBA"
doprogram "FTO"
doprogram "SYRIA"
doprogram "IFSR"
doprogram "NPWMD"
doprogram "IRAN-TRA"
doprogram "IRAN"
doprogram "IRAQ3"
doprogram "IRGC"
doprogram "HRIT-IR"
doprogram "LIBERIA"
doprogram "BALKANS"
doprogram "BELARUS"
doprogram "JADE"
doprogram "SDGT"
doprogram "SDNT"
doprogram "SDNTK"
doprogram "SDT"
doprogram "SDNB"
doprogram "SDNC"
doprogram "SDNCO"
doprogram "SDNI"
doprogram "SDNL"
doprogram "SDNLB"
doprogram "SDNLR"
doprogram "SDNM"
doprogram "SDNR"
doprogram "SDNS"
doprogram "SDNSO"
doprogram "SDNSY"
doprogram "SDNZ"
doprogram "SDNV"
doprogram "SDME"

#sed -e 's/<sdnList>/<sdnList xmlns:xsi="http:\/\/www.w3.org\/2001\/XMLSchema-instance" xmlns="http:\/\/tempuri.org\/sdnList.xsd">/' "$DOWNLOADED_FILE" > temp
#mv temp "$DOWNLOADED_FILE"

dos2unix $OUTPUT_DIR/*.xml

############################################# CALCULATE TOKENS TO BE TRANSLATED FROM FULL FILE

xmltag[0]='//address1'
xmltag[1]='//city'
xmltag[2]='//country'
xmltag[3]='//lastName'
xmltag[4]='//firstName'
xmltag[5]='//title'
xmltag[6]='//placeOfBirth'
xmltag[7]='//dateOfBirth'
xmltag[8]='//remarks'
xmltag[9]='//type'
xmltag[10]='//category'
xmltag[11]='//address2'
xmltag[12]='//address3'
xmltag[13]='//stateOrProvince'
xmltag[14]='//postalCode'
xmltag[15]='//vesselOwner'
xmltag[16]='//callSign'

sedexpr[0]='s/<address1>([^><]+)<\/address1>/\1\|\n/g'
sedexpr[1]='s/<city>([^><]+)<\/city>/\1\|\n/g'
sedexpr[2]='s/<country>([^><]+)<\/country>/\1\|\n/g'
sedexpr[3]='s/<lastName>([^><]+)<\/lastName>/\1\|\n/g'
sedexpr[4]='s/<firstName>([^><]+)<\/firstName>/\1\|\n/g'
sedexpr[5]='s/<title>([^><]+)<\/title>/\1\|\n/g'
sedexpr[6]='s/<placeOfBirth>([^><]+)<\/placeOfBirth>/\1\|\n/g'
sedexpr[7]='s/<dateOfBirth>([^><]+)<\/dateOfBirth>/\1\|\n/g'
sedexpr[8]='s/<remarks>([^><]+)<\/remarks>/\1\|\n/g'
sedexpr[9]='s/<type>([^><]+) <\/type>/\1\|\n/g'
sedexpr[10]='s/<category>([^><]+)<\/category>/\1\|\n/g'
sedexpr[11]='s/<address2>([^><]+)<\/address2>/\1\|\n/g'
sedexpr[12]='s/<address3>([^><]+)<\/address3>/\1\|\n/g'
sedexpr[13]='s/<stateOrProvince>([^><]+)<\/stateOrProvince>/\1\|\n/g'
sedexpr[14]='s/<postalCode>([^><]+)<\/postalCode>/\1\|\n/g'
sedexpr[15]='s/<vesselOwner>([^><]+)<\/vesselOwner>/\1|\n/g'
sedexpr[16]='s/<callSign>([^><]+)<\/callSign>/\1\|\n/g'


function calcTokens {
   SRC="$OUTPUT_DIR/ofac_program_$1.xml"
   if [ "$1" = "FULL" ]; then
    SRC=$DOWNLOADED_FILE
   fi

   filename="$OUTPUT_DIR/$1.txt"
   for (( i = 0 ; i < ${#xmltag[@]} ; i++ ))
	do 
	 xmllint --xpath ${xmltag[i]} $SRC > foo1
	 sed -r ${sedexpr[i]} foo1 >> $filename
	rm foo1
   done
   cat $filename | sort | uniq > $filename
}

function tobetranslated() {
 filename="$OUTPUT_DIR/FULL.txt"
 output="$OUTPUT_DIR/NEW_TOBE_TRANSLATED.txt"
 	while read line           
	do           
		token=`echo $line | tr -d '|\n'`
		istokentranslated=`grep -i "^$token" "$DICT" | wc -l`
		if [[ "$istokentranslated" = "0"  ]]; then
		  echo $line >> $output
		fi
	done <$filename

 
}

echo "generating token files"
calcTokens "FULL"
calcTokens "BURMA"
calcTokens "CUBA"
calcTokens "FTO"
calcTokens "SYRIA"
calcTokens "IFSR"
calcTokens "NPWMD"
calcTokens "IRAN-TRA"
calcTokens "IRAN"
calcTokens "IRAQ3"
calcTokens "IRGC"
calcTokens "HRIT-IR"
calcTokens "LIBERIA"
calcTokens "BALKANS"
calcTokens "BELARUS"
calcTokens "JADE"
calcTokens "SDGT"
calcTokens "SDNT"
calcTokens "SDNTK"
calcTokens "SDT"
calcTokens "SDNB"
calcTokens "SDNC"
calcTokens "SDNCO"
calcTokens "SDNI"
calcTokens "SDNL"
calcTokens "SDNLB"
calcTokens "SDNLR"
calcTokens "SDNM"
calcTokens "SDNR"
calcTokens "SDNS"
calcTokens "SDNSO"
calcTokens "SDNSY"
calcTokens "SDNZ"
calcTokens "SDNV"
calcTokens "SDME"

tobetranslated

cp  $DOWNLOADED_FILE $OUTPUT_DIR
