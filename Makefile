CURL_CONFIG=-XGET -f -H "Authorization: Bearer $(shell cat oauth_token)"
HOST=https://api.prod.timetoknow.com
HOST2=https://apps.prod.timetoknow.com

# TODO: scrape everything and use cairosvg

all: full_slides

%.pdf: %.svg
	cairosvg $< -o $@

slides/%:
	mkdir -p `dirname $@`
	curl -f $(HOST2)/resources/$* -o $@

pdfs: svg_images
	$(MAKE) $(shell find slides/ -name "*.svg" | sed -E "s/\.svg/\.pdf/")

svg_images: slides
	@$(MAKE) $(shell find slides -name "*.svg" \
	    | xargs -L1 sh make_svg_image_page.sh)

%.page.pdf:
	mkdir -p `dirname $@`
	cairosvg $(HOST2)/$*/$(shell basename $*).svg -o $@

%/lesson.pdf:
	cd $* && pdfunite `ls *.page.pdf | sort -n` lesson.pdf

full_slides:
	$(MAKE) $(shell find resources -name "*.pdf" \
	    | xargs -L1 dirname \
	    | uniq \
	    | xargs -L1 printf "%s/lesson.pdf\n" \
	    )

slides: lessons
	$(MAKE) $(shell ls $</* \
	    | xargs cat \
	    | jq -r ".pages | to_entries | map(.value.href)[]" \
	    | sed -E 's/([[:digit:]]+)\.html+/\1\.page.pdf/g' \
	    | grep -v blank_page)

courses: contentTree.json
	$(MAKE) \
	    $(shell cat $< \
	    | jq -r ".channelWithContentTree | map(.id)[] " \
	    | xargs printf "$@/%s.json\n" )

lessons: courses
	$(MAKE) \
	    $(shell cat $</* \
	    | jq -r '.libraryItems[] | select(.type == "LESSON") | .id' \
	    | xargs printf "$@/%s.json\n")

contentTree.json:
	curl $(CURL_CONFIG) '$(HOST)/LibraryService/v2/channels/contentTree' -o $@

lessons/%.json:
	curl $(CURL_CONFIG) '$(HOST)/PlayAppService/lessons/$*/version/1/play' -o $@

courses/%.json:
	curl $(CURL_CONFIG) '$(HOST)/LibraryService/v2/channels/$*/content' -o $@

clean:
	rm -rf lessons/* courses/* contentTree.json slides/*

.PHONY: lessons courses clean
