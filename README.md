
# chessdata

![is true](https://img.shields.io/badge/chess%20nut%3F-yes!-red.svg)

Scripts for processing a huge file of pgn data down to results, for some
research on Elo ratings.

-- Steven E. Pav, shabbychef@gmail.com

*Note* These scripts source their data from the 'top 5000' millionbase
database, which has disappeared. I would love to host the data, but
am not sure how to do so.

## run it 

You will need some R packages for the last part: `readr`, `dplyr`, and
`zipper`. The latter is [not on CRAN](https://github.com/shabbychef/zipper "zipper"), but
you can install as follows:

```r
# via drat:
if (require(drat)) {
    drat:::add("shabbychef")
    install.packages("zipper")
}
# get snapshot from github (may be buggy)
if (require(devtools)) {
	install_github('shabbychef/zipper')
}
```

You will also need PERL and wine:

```bash
make help
make -n results
```

```
wget --output-document=millionbase_2.2.exe 'http://www.top-5000.nl/dl/millionbase%202.2.exe?forcedownload'
wine millionbase_2.2.exe
grep -a -P '\[(Date|White|Black|Result|WhiteElo|BlackElo)' millionbase-2.22.pgn | perl -pe 's/^\s*\[|\]//g;' > millionbase-2.22.subpgn
r extract_results.r --no_names_please --require_elos millionbase-2.22.subpgn millionbase-2.22_resu.csv
```

```bash
# watch the blinkenlights ...
make results
```
