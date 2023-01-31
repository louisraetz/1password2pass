#!/bin/bash

SUPPORTED_FILE_TYPES=("*.csv")
FILE_NAME=$1
SKIP=false

read -r -p "This script is experimental. If you have multi-line notes in your csv make sure to remove and safe them,
since they are not being converted in this script. Want to proceed? (y/n) " yn

case $yn in
	[Yy] ) ;;
	[Nn] ) echo exiting...;
		exit;;
	* ) echo Please choose either yes or no.;
		exit 1;;
esac

if [[ "$FILE_NAME" == ${SUPPORTED_FILE_TYPES[0]} ]]; then
  while IFS=',' read -r TITLE URL USER_NAME PASSWORD OTP_AUTH FAVORITE ARCHIVED TAGS NOTES || [[ -n "$TITLE" ]]; do
    # Skip the first line (header)
    if [[ "$SKIP" == false ]]; then
      SKIP=true
      continue
    fi

    ROW=($TITLE $URL $USER_NAME $PASSWORD $OTP_AUTH $FAVORITE $ARCHIVED $TAGS $NOTES)
    NAME=$USER_NAME

    if [ "${#ROW[@]}" -lt 4 ];then
      echo "Invalid csv row. Skipping..."
      continue
    fi

    if [[ -z $TITLE ]]; then
       echo "Invalid csv row. Skipping..."
       continue
    fi

    F_TITLE=${TITLE// /_} # replacing white spaces with '_'
    F_TAGS=${TAGS/;/, }

    if [[ -z $USER_NAME ]]; then
       NAME=$F_TITLE
    fi

    echo -ne "#####                     33% (Adding $F_TITLE)\r"

    echo -e "${PASSWORD}\nURL: ${URL}\nOTP_AUTH: ${OTP_AUTH}\nTags: ${F_TAGS}\nNotes: ${NOTES}" | pass insert -f -m ${F_TITLE}/${NAME} > /dev/null

    echo -ne "######################### 100% (Added $F_TITLE)\r"

    echo -ne '\n'
  done < $FILE_NAME
else
  echo "Unsupported file type."
fi