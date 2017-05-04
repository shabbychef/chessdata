# /usr/bin/r
#
# convert a cruddy pgn file to a file of results
#
# Created: 2017.04.27
# Copyright: Steven E. Pav, 2017
# Author: Steven E. Pav <steven@gilgamath.com>
# Comments: Steven E. Pav

suppressMessages(library(docopt))       # we need docopt (>= 0.3) as on CRAN

doc <- "Usage: extract_results.r [-v] [--no_names_please] [--require_elos] INFILE [OUTFILE]

Convert pgn summary to a dataframe csv

--no_names_please                Do not include names of Black and White players.
--require_elos                   Do not include games unless both BlackElo and WhiteElo are non-na.
-v --verbose                     Be more verbose
-h --help                        show this help text"

suppressMessages({
	library(readr)
	library(dplyr)
	library(magrittr)
# from my drat
	library(zipper)
})

if (interactive()) {
	opt <- docopt(doc,args='million_summary.txt')
} else {
	opt <- docopt(doc)
}

indf <- readLines(opt$INFILE)

isDate <- which(grepl('^Date\\s',indf))
isWhite <- which(grepl('^White\\s',indf))
isBlack <- which(grepl('^Black\\s',indf))
isWhiteElo <- which(grepl('^WhiteElo\\s',indf))
isBlackElo <- which(grepl('^BlackElo\\s',indf))
isResult <- which(grepl('^Result\\s',indf))

row_White <- zipper::zip_le(isDate,isWhite)
row_Black <- zipper::zip_le(isDate,isBlack)
row_WhiteElo <- zipper::zip_le(isDate,isWhiteElo)
row_BlackElo <- zipper::zip_le(isDate,isBlackElo)
row_Result <- zipper::zip_le(isDate,isResult)

library(dplyr)
fooz <- data.frame(Date=gsub('^Date\\s*"(.+)"\\s*$','\\1',indf[isDate]),
									 White='',Black='',WhiteElo=NA_real_,BlackElo=NA_real_,Result='',stringsAsFactors=FALSE)

fooz[row_White,'White'] <- gsub('^\\s*White\\s+"(.+)\\s*\\(wh\\)\\s*"\\s*$','\\1',indf[isWhite])
fooz[row_Black,'Black'] <- gsub('^\\s*Black\\s+"(.+)\\s*\\(bl\\)\\s*"\\s*$','\\1',indf[isBlack])
fooz[row_WhiteElo,'WhiteElo'] <- as.numeric(gsub('^\\s*WhiteElo\\s*"(\\d{1,4})"\\s*$','\\1',indf[isWhiteElo]))
fooz[row_BlackElo,'BlackElo'] <- as.numeric(gsub('^\\s*BlackElo\\s*"(\\d{1,4})"\\s*$','\\1',indf[isBlackElo]))
fooz[row_Result,'Result'] <- gsub('^\\s*Result\\s*"(.+)"\\s*$','\\1',indf[isResult])

rm(indf)

fooz %<>% 
	mutate(WhiteResult=ifelse(grepl('1-0',Result),1,ifelse(grepl('1/2-1/2',Result),0.5,ifelse(grepl('0-1',Result),0,NA_real_)))) 

if (opt$no_names_please) {
	fooz %<>%
		select(Date,WhiteElo,BlackElo,WhiteResult)
} else {
	fooz %<>%
		select(Date,White,Black,WhiteElo,BlackElo,WhiteResult)
}

if (opt$require_elos) {
	fooz %<>%
		filter(!is.na(WhiteElo),!is.na(BlackElo))
}


if (is.null(opt$OUTFILE)) {
	format_csv(fooz) %>%
		print()
} else {
	readr::write_csv(fooz,opt$OUTFILE)
}

#for vim modeline: (do not edit)
# vim:fdm=marker:fmr=FOLDUP,UNFOLD:cms=#%s:syn=r:ft=r
