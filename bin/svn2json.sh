#! /bin/sh

. xmljson/bin/activate
svnlite co --depth empty svn://svn.freebsd.org/base ~/src/freebsd-base
MAX=$( svnlite log -l 1 src/freebsd-base | head -n 2 | tail -n 1 | cut -d '|' -f 1 | cut -d r -f 2 )
STEP=100

TMPDIR=/var/tmp/`basename $0`
mkdir -p $TMPDIR

START=$(( $MAX - ( ($MAX - 1) % STEP ) ))
END=$(( $START + $STEP - 1 ))
echo $MAX rm $TMPDIR/commits.$START-$END.json.gz
if test -f $TMPDIR/commits.$START-$END.json.gz
then
  rm $TMPDIR/commits.$START-$END.json.gz
else
  rm $TMPDIR/commits.$(($START-$STEP))-$(($END-$STEP)).json.gz
fi

START=1
END=$(( $START + $STEP - 1 ))
while test $START -lt $MAX
do
	if ! test -f $TMPDIR/commits.$START-$END.json.gz; then
		TMPEND=$END
		if test $TMPEND -gt $MAX; then
			TMPEND=$MAX
		fi
		svnlite log --xml -r $START:$TMPEND -v ~/src/freebsd-base > $TMPDIR/svn.log.xml
		bin/xml2json.py $TMPDIR/svn.log.xml > $TMPDIR/commits.$START-$END.json
		gzip -f $TMPDIR/commits.$START-$END.json
	fi
	START=$(( $START + $STEP ))
	END=$(( $START + $STEP - 1 ))
done
echo "{" \
	\"version\":1, \
	\"head\":$MAX, \
	\"start\":$(($START - $STEP)), \
	\"step\":$STEP \
     "}" | gzip > $TMPDIR/meta.info.json.gz
scp -p -i ~/.ssh/webmaster \
	$(find $TMPDIR -ctime -1d -name "commits.*.json.gz") \
	$TMPDIR/meta.info.json.gz \
	webmaster@klop.ws@ftp.greenhost.nl:klop.ws/www/freebsd-data/
