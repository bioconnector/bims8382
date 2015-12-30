HTML_FILES := $(patsubst %.Rmd, %.html ,$(wildcard *.Rmd)) \
              $(patsubst %.md,  %.html ,$(wildcard *.md))

all: clean html fixme


html: $(HTML_FILES)

%.html: %.Rmd
	Rscript -e "set.seed(42);rmarkdown::render('$<')"

%.html: %.md
	Rscript -e "set.seed(42);rmarkdown::render('$<')"

.PHONY: clean
clean:
	$(RM) $(HTML_FILES)

fixme:
	@echo "Remaining fixes?"
	@grep --color -nri --include \*.md --include \*.Rmd fixme .
