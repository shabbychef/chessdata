# /usr/bin/r
#
# summarize results file.
#
# Created: 2017.05.04
# Copyright: Steven E. Pav, 2017
# Author: Steven E. Pav <steven@gilgamath.com>
# Comments: Steven E. Pav

suppressMessages(library(docopt))       # we need docopt (>= 0.3) as on CRAN

doc <- "Usage: summarizer.r [-v] INFILE [OUTFILE]

Convert results csv to summary form.

-v --verbose                     Be more verbose
-h --help                        show this help text"

suppressMessages({
	library(readr)
	library(dplyr)
	library(magrittr)
})

if (interactive()) {
	opt <- docopt(doc,args='millionbase-2.22_resu.csv')
} else {
	opt <- docopt(doc)
}

indat <- readr::read_csv(opt$INFILE,
												 col_types=readr::cols(WhiteElo=col_double(),BlackElo=col_double(),WhiteResult=col_double()))

sdat <- indat %>% 
	filter(!is.na(WhiteElo),!is.na(BlackElo),!is.na(WhiteResult)) %>%
	mutate(WMB=WhiteElo - BlackElo) %>%
	mutate(meanElo=0.5*(WhiteElo + BlackElo)) %>%
	mutate(result=ifelse(WMB >= 0,WhiteResult,1-WhiteResult),
				 deltaElo=abs(WMB)) %>%
	mutate(Year=as.numeric(gsub('^(\\d{4}).*$','\\1',Date))) %>%
	mutate(Year=as.integer(Year),
				 deltaElo=as.integer(deltaElo),
				 meanElo=as.integer(meanElo)) %>%
	filter(!is.na(Year)) %>%
	select(Year,deltaElo,meanElo,result) 

if (is.null(opt$OUTFILE)) {
	format_csv(sdat) %>%
		print()
} else {
	readr::write_csv(sdat,opt$OUTFILE)
}

#for vim modeline: (do not edit)
# vim:fdm=marker:fmr=FOLDUP,UNFOLD:cms=#%s:syn=r:ft=r
