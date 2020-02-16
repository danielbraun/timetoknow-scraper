CURL_CONFIG=-XGET -f -H "Authorization: Bearer $(shell cat oauth_token)"
HOST=https://api.prod.timetoknow.com
HOST2=https://apps.prod.timetoknow.com

# TODO: Download all SVGS and their links
# use XSLT to make all xlinks:href absolute
# Then, possibly download them all.

all: repl

7.svg:
	wget https://apps.prod.timetoknow.com/resources/bd980e8a-850b-4064-86f9-cac88f402904/IDR/3849757b-d78f-4ac3-ae4e-8c20d64d6573/7/7.svg

download: lessons
	@ls $</* \
	    | xargs cat \
	    | jq -r ".pages | to_entries | map(.value.href)[]" \
	    | xargs printf "$(HOST2)/%s\n" $- \
	    | sed -E 's/([[:digit:]]+)\.html+/\1\/\1\.svg/g'  \
	    | xargs wget -krp


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
	rm -f lessons/* courses/* contentTree.json

.PHONY: lessons courses clean
