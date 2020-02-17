CURL_CONFIG=-XGET -f -H "Authorization: Bearer $(shell cat oauth_token)"
HOST=https://api.prod.timetoknow.com
HOST2=https://apps.prod.timetoknow.com

# TODO: Download all SVGS and their links
# use XSLT to make all xlinks:href absolute
# Then, possibly download them all.

all: slides

# TODO: Make this prettier.
# Using curl can possibly make this simpler.
slides/%.svg:
	DIR=`echo $@ | cut -d "/" -f1` ; \
	    wget $(HOST2)/resources/$*/$(shell basename $*).svg \
	    -krp -nH \
	    --cut-dirs=1 \
	    -P $$DIR ; \
	    cd $$DIR/$* ; mv * ../ ;  cd $(shell pwd) ; rm -r $$DIR/$*

slides: lessons
	@$(MAKE) $(shell ls $</* \
	    | xargs cat \
	    | jq -r ".pages | to_entries | map(.value.href)[]" \
	    | sed -E 's/([[:digit:]]+)\.html+/\1\.svg/g' \
	    | sed -E 's/resources/$@/' \
	    | grep -v blank_page)

courses: contentTree.json
	$(MAKE) \
	    $(shell cat $< \
	    | jq -r ".channelWithContentTree | map(.id)[] " \
	    | xargs printf "courses/%s.json\n" )

lessons: courses
	$(MAKE) \
	    $(shell cat $</* \
	    | jq -r '.libraryItems[] | select(.type == "LESSON") | .id' \
	    | xargs printf "lessons/%s.json\n")

contentTree.json:
	curl $(CURL_CONFIG) '$(HOST)/LibraryService/v2/channels/contentTree' -o $@

lessons/%.json:
	curl $(CURL_CONFIG) '$(HOST)/PlayAppService/lessons/$*/version/1/play' -o $@

courses/%.json:
	curl $(CURL_CONFIG) '$(HOST)/LibraryService/v2/channels/$*/content' -o $@

clean:
	rm -rf lessons/* courses/* contentTree.json slides/*

.PHONY: lessons courses clean
