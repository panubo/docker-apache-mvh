SUBDIRS := buster bullseye

.PHONY: build push clean

build:
	for dir in $(SUBDIRS); do \
		make TAG=$$dir -C $$dir $(MAKECMDGOALS); \
  done

push:
	for dir in $(SUBDIRS); do \
		make TAG=$$dir -C $$dir $(MAKECMDGOALS); \
	done

clean:
	for dir in $(SUBDIRS); do \
		make TAG=$$dir -C $$dir $(MAKECMDGOALS); \
	done
