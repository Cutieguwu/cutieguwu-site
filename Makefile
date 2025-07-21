SASS_SRC=src/style.scss
SASS_DEST=target/style.css

SASS_CMD=sass \
	$(SASS_SRC) \
	$(SASS_DEST)

BALLOON_CMD=~/.pyenv/versions/3.12.9/bin/python \
	balloon.py

sass:
	$(SASS_CMD)

balloon:
	$(BALLOON_CMD)

all: sass balloon

.DEFAULT_GOAL := all
