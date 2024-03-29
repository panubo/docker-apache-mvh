SUBDIRS := debian12 debian11 debian10

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
