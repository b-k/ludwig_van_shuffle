#!/usr/bin/perl -w

#Creates a playlist.  The idea here is that if you want 
#a randomized playlist but 
#have a few pieces which have multiple movememnts,
#they can be put in without any hassle.
#Mp3s in asstdir are randomized, those in 
#sequentialdir are not: each subdirectory is played out 
#at some random point in the overall random list. 

#another trick: If you have a favorite song, make 
#links to that song: ln -s fave.mp3 dummy.mp3
#and that song will appear multiple times on the list.

$asstdir = "usbotg/";
$asstdir2 = "sdcard0/pop/";
$sequentialdir = "/home/b/tele/sdcard0/oddsequential/";
$outfile = "sdcard0/list.m3u";
$xmmsoutfile = "sdcard0/list.m3u";
$gqmpeg = 0; #if you're using this for gqmpeg.


##############
sub pluck {
#give me n and a list, and I'll pull the nth element.
#list order gets mangled; I don't care.
	my ($itemno, $list) = @_;
	my $tmp = @$list[$itemno];
	if ($itemno<$#$list){
		$$list[$itemno] = pop @$list;
	} else {
		pop @$list};
	return $tmp;
}

##############
sub getsequential{
	#find all the directory names, then clean out the
	#ones that aren't at the base of the tree.
my $var3 = `find  $sequentialdir -depth -type d`;
my $last = " "; 
while ($var3 =~ m/((.*)\/[^\/]*)/g){
	my $temporary_variable = $2;
	if ($1 !~ m/^$last$/){$seq[$#seq+1]=$1;}
	$last = $temporary_variable;
	};
return @seq;
}

##############
sub getassorted{
my $var2 = `find $asstdir -follow -regex ".*\\(mp3\\|m4a\\|ogg\\)"` .`find $asstdir2 -follow -regex ".*\\(mp3\\|m4a\\|ogg\\)"`;
	#clean out anything that isn't an mp3;
	#put in array.
while ($var2=~ m/(.*mp3|.*m4a|.*ogg)\n/g){
		$asstlist[$#asstlist+1]=$1;
		}
return @asstlist;
}


##############
sub writeout {
open(OUT , "> $outfile");
if ($gqmpeg) {print OUT "# GQmpeg song playlist\n# created by version 0.17.0\n# Shuffle:0 Repeat:1 (please only use 0 or 1)\n"}
for($ct=0;@asstlist>0;$ct++){#condition has nothing to do with $ct.
	print OUT pluck(int(rand(@asstlist)),\@asstlist)."\n";

	#Work out whether to place a nonrandom block:
	for($seqct=0;$seqct<@insertion;$seqct++)
		{if ($insertion[$seqct]==$ct)#then it's time.
			{pluck($seqct,\@insertion);
			my $sdir = pluck($seqct, \@seqlist) ;
			$sdir =~ s/\n//g;
			print OUT `ls $sdir/*3 -1 `;}
			}
		}
if ($gqmpeg) {print OUT "# end of list #"}
close(OUT);
`cp $outfile $xmmsoutfile`;
}


############## main:
@seqlist = getsequential;
@asstlist = getassorted;
#make random insertion points:
while (@insertion<@seqlist){
	$insertion[$#insertion+1]=int(rand(@asstlist));
	}

writeout;


#--Ben Klemens, 11 May 2003.
