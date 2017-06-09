SHELL := /bin/bash
PATH  := $(PATH):node_modules/.bin

parsers := lib/parser/grammar.rb

.PHONY: all clean test

all: $(parsers)

lib/parser/%.rb: lib/parser/%.peg node_modules/.bin/canopy
	canopy $< --lang ruby

node_modules/.bin/canopy:
	npm install

clean:
	rm -rf $(parsers)

test: all
	bundle exec rspec
