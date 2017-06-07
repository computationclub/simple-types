SHELL := /bin/bash
PATH  := $(PATH):node_modules/.bin

.PHONY: all

all: lib/parser/grammar.rb

lib/parser/%.rb: lib/parser/%.peg node_modules/.bin/canopy
	canopy $< --lang ruby

node_modules/.bin/canopy:
	npm install
