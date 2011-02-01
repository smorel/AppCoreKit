KEYWORDS="TODO:|FIXME:|\?\?\?:|\!\!\!:"
git ls-files | grep -v Frameworks | grep -e "\\.[h,m]$" | xargs egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/ warning: \$1/"

#git ls-files | xargs grep -n -e "FIXME\|TODO"
