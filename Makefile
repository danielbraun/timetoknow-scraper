CURL_CONFIG=-XGET -f -H "Authorization: Bearer $(shell cat oauth_token)"
COURSE_ID=088f88db-a0e6-4262-8551-6009f930b64b

all: course.json lesson.json

course.json: oauth_token
	curl $(CURL_CONFIG) 'https://api.prod.timetoknow.com/LibraryService/v2/channels/088f88db-a0e6-4262-8551-6009f930b64b/content' -o $@

lesson.json: oauth_token
	curl $(CURL_CONFIG) 'https://api.prod.timetoknow.com/PlayAppService/lessons/e4a3ce49-120f-41b7-b20c-1885e9fb7bab/version/1/play' -o $@
