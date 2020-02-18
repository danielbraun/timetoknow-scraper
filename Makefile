CURL_CONFIG=-XGET -f -H "Authorization: Bearer $(shell cat oauth_token)"
HOST=https://api.prod.timetoknow.com
HOST2=https://apps.prod.timetoknow.com

all: svg_images

slides/%:
	mkdir -p `dirname $@`
	curl -f $(HOST2)/resources/$* -o $@

svg_images: slides
	@$(MAKE) $(shell find slides -name "*.svg" \
	    | xargs -L1 sh make_svg_image_page.sh)

slides: lessons
	@$(MAKE) $(shell ls $</* \
	    | xargs cat \
	    | jq -r ".pages | to_entries | map(.value.href)[]" \
	    | sed -E 's/([[:digit:]]+)\.html+/\1\/\1\.svg/g' \
	    | sed -E 's/resources/$@/' \
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
