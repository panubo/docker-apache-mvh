SUBDIRS := $(shell ls -d */)

.PHONY: build push clean

build:
	for dir in $(SUBDIRS); do \
  	make -C $$dir $(MAKECMDGOALS); \
  done

push:
	for dir in $(SUBDIRS); do \
  	make -C $$dir $(MAKECMDGOALS); \
  done

clean:
	for dir in $(SUBDIRS); do \
  	make -C $$dir $(MAKECMDGOALS); \
  done
