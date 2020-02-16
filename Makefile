CURL_CONFIG=-XGET -f -H "Authorization: Bearer $(shell cat oauth_token)"
HOST=https://api.prod.timetoknow.com
# TODO: Download all SVGS and their links
# use XSLT to make all xlinks:href absolute
# Then, possibly download them all.

all: lessons

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
