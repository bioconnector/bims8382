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

textbook: textbook.preface.md r-basics.md r-dplyr.md r-tidy.md r-ggplot2.md r-rnaseq-airway.md
	cat $^ > textbook.md
	pandoc --toc -s -V geometry:margin=1in -V documentclass:report -V fontsize=12pt textbook.md -o textbook.pdf
	open textbook.pdf