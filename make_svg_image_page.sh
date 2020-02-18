xsltproc --novalid extract_svg_images.xsl $1 | xargs -L1 printf "%s/%s\n" $(dirname $1)
