######################
#
# make chessdata
#
# Created: 2017.05.03
# Copyright: Steven E. Pav, 2017
# Author: Steven E. Pav
######################

millionbase_2.2.exe :
	wget --output-document=$@ 'http://www.top-5000.nl/dl/millionbase%202.2.exe?forcedownload'

# wine? FML
millionbase-2.22.pgn : millionbase_2.2.exe 
	wine $<

%.subpgn : %.pgn
	grep -a -P '\[(Date|White|Black|Result|WhiteElo|BlackElo)' $< | perl -pe 's/^\s*\[|\]//g;' > $@

%_resu.csv : %.subpgn extract_results.r 
	r $(filter %.r,$^) --no_names_please --require_elos $(filter %.subpgn,$^) $@

.PRECIOUS : %.subpgn

.PHONY : results

results : millionbase-2.22_resu.csv ## turn pgn data into results of Date, Elo and outcome.

.PHONY   : help 

# this will have to change b/c of inclusion file names...
help:  ## generate this help message
	@grep -h -P '^(([^\s]+\s+)*([^\s]+))\s*:.*?##\s*.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#for vim modeline: (do not edit)
# vim:ts=2:sw=2:tw=129:fdm=marker:fmr=FOLDUP,UNFOLD:cms=#%s:tags=.tags;:syn=make:ft=make:ai:si:cin:nu:fo=croqt:cino=p0t0c5(0:
