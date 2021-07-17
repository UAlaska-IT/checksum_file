
SHELL := /bin/bash

lint:
	chef exec rubocop -A
	cookstyle -A .
	cookstyle -A test/fixtures/cookbooks/test_harness
	chef exec rubocop
	cookstyle .
	cookstyle test/fixtures/cookbooks/test_harness

tag:
	chef exec ruby -r "./tag.rb" -e "tag"

tag-push:
	git push --tags

share:
	# For category see https://docs.chef.io/knife_cookbook_site.html
	knife supermarket share checksum_file Utilities
