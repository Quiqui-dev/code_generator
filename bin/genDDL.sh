#!/bin/bash

for FILE in $1/*; do
    short=${FILE%.*}
    short=${short##*/}
    java -jar ~/Saxon/saxon-he-11.3.jar $FILE $2/DDL.xsl -o:${3}/${short}.sql
done