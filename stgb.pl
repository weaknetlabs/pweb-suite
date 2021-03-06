#!/usr/bin/perl -w
#
# Simple Text Google Browser
# 2012 - WeakNet Labs
#
# requires: grep,sed,curl,Term::ANSIColor 
#
use Term::ANSIColor;
name(); # make it pretty
if(!$ARGV[0]){
	usage();
}
my %ref = (' ' => '+','\!'=>'%21','\"'=>'%22','\#'=>'%23', # there are some you will not want to change here!
	'\$'=>'%24',"\'"=>'%27',';'=>'%2B',
	'\('=>'%28','\)'=>'%29','\*'=>'%2A',
	'\,'=>'%2C','\-'=>'%2D','\.'=>'%2E','\:'=>'%3A','\<'=>'%3C','\='=>'%3D','\>'=>'%3E',
	'\?'=>'%3F','\@'=>'%40','\]'=>'%5D','\^'=>'%5E',
	'\_'=>'%5F','\`'=>'%60','\{'=>'%7B','\|'=>'%7C',
	'\}'=>'%7D','\~'=>'%7E'); # If you add to this hash, you need backslashes so they dont get interpreted below in the s///
my $page = 0; # start at the first page
my $dork; # our Google Dork
my $pref='';
# The user agent is important to have to Google doesnt think your a robot - that would defeaet the whole purpose of this app
my $ua = '--user-agent \'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17\'';
args2string(); # Now we create our dork
my $gooString = 'http://www.google.com/search?q=' . $dork . '&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a&start=';
# this filter is growing, it parses our garbage form the Google reply:
my $filter = 'grep \'<a href="http\' | tr \'<\' \'\n\' | grep -i href | sed -e \'s/a href="//\' -e \'s/".*//\'';
	$filter .= ' -e \'s/\&amp;/\&/g\' | grep ^htt | grep -v webcache.googleuse | grep -v \'www.google.com/search?q=\'';
	if($pref ne ''){
		$filter .= " | sed -E -e 's/[+]?$pref.*//'"; # for Google docs results
		$gdocs = '(https?:\/\/)docs.google.com\/viewer\?a=v&q=cache:.+:';
		$backref = '\1';
		$filter .= " | sed -E -e 's/$gdocs/$backref/'";
	}
getURL(); # call it once
while($_ = <STDIN>){ # press enter to continue
	getURL(); # compartmentalized for initial query
}
sub getURL{
        my $appNum = $gooString . $page; # append our new start value
        # to DEBUG your URL query put a break here ;)
        # print $appNum . "\n"; exit;
        $page+=10;
        system("curl -s \'$appNum\' $ua | $filter\n"); # single quotes are not optional around URL
        print "\n [ ";
	colorTxt("bold green",">");
	print " ] press return for more results, ";
	colorTxt("bold red","CTRL+C ");
	print "to quit\n"; # continue?
}
sub name{
	colorTxt('bold white',"\n Simple ");
	colorTxt('bold blue','G');
	colorTxt('red','o');
	colorTxt('yellow','o');
	colorTxt('blue','g');
	colorTxt('green','l');
	colorTxt('bold red','e');
	colorTxt("bold white"," Text Browser\n");
	print " 2012 - WeakNet Labs\n\n";
}
sub colorTxt{
	print color $_[0];
	print $_[1];
	print color 'reset';
}
sub args2string{
	if ($ARGV[0] =~ m/(^[a-z]+):[a-z]/i){
		$pref = $1;
	}
	# did you specify that you needed help?
	if(grep(/(-)?-h(elp)?/,@ARGV)){
		usage();
	}else{
		$dork = $ARGV[0];
		while (($key, $value) = each(%ref)){
			$dork =~ s/$key/$value/;
		} # if you wanna debug below is a good place for a break ;)
	}
}
sub usage{ # Something went wrong
	print " Usage: ./stgb <DORK>\n\n";
	exit;
}