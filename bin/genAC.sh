#!/bin/bash

for FILE in $1/*; do
    short=${FILE%.*}
    short=${short##*/}
    java -jar ~/Saxon/saxon-he-11.3.jar $FILE $2/ReadClass.xsl -o:${3}/${short}Read.py
    java -jar ~/Saxon/saxon-he-11.3.jar $FILE $2/WriteClass.xsl -o:${3}/${short}Write.py
done