#!/bin/bash

pages=".pages | map_values(.href) | to_entries | map(.value) | @tsv"
lesson_name=".lesson.properties.name"
domain="https://apps.prod.timetoknow.com"

for page in $(cat lesson.json | jq -r "$pages"); do
    file=$page
    dir=$(cat lesson.json | jq -r "$lesson_name")
    mkdir -p "$dir"
    curl $domain/$file | xsltproc --html add_base_tag.xsl - > $dir/$(basename $file)
done
