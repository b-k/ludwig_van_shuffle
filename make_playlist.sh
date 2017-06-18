Dear_reader="
The intent of this script is to generate a shuffled track listing, while retaining
multi-movement pieces as a unit.

After you source this script, like
. ./make_lists
you will have a few functions available to build the playlist.

In a directory with some multi-track portions, use
. prep_lists
to generate a track listing in a file named 'sets'. Then use your favorite text editor to
add a name to groups. Here is my favorite album after I added a grouping for four out of
the five tracks (leaving one ungrouped):

>>>>>>>>>>
01-Minnesang.mp3|
02-Choir_Concerto_-_'O_Pavelitel'_Sushcheva_Fsevo'.mp3|choir concerto
03-Choir_Concerto_-_'Sabran'_Je_Pesen_Sikh,_Gde_Kazhdyj_Stikh'.mp3|choir concerto
04-Choir_Concerto_-_'Fsem_Tem,_Kto_Vniknet_Fsushchnast''.mp3|choir concerto
05-Choir_Concerto_-_'Sej_Trud,_Shto_Nachinal_Ja_Supavan'_Jem'.mp3|choir concerto
<<<<<<<<<<

The name can be anything (a, b, c, 1, 2, 3), just enough to uniquely identify the set within this directory.

Once you have a 'sets' file in every directory with a collection (meaning that many album
directories may not need a 'sets' file at all), go to the root of your collection and run

make_playlist

and it will output list.m3u, with one track per line.

It also generates files named posns.tracks and posns.sets (overwriting whatever is there).

Q: My favorite Android music player doesn't see the playlist after it generates
A: Try moving the file in Android's official file manager, or plug in/out a USB thumb
drive to initiate a rescan.

Q: Why didn't you do this in pyhthon or Scala or Clojure or ...?
A: This POSIX shell script is simple and standard enough that it runs via Busybox,
a stripped-down shell+utilities. I have a friend with a pair of shoes that could
run this script. You may already have Busybox on your telephone, so you can rebuild
playlists as desired on the thing you may be using to listen to music anyway. I get
to a Busybox command prompt using Sshdroid + Termius or Juicessh, or you could use a
hundred other busybox repackagings.

Q: Why is the countdown inaccurate?
A: Because it double-counts some tracks in the multi-movement sets. it's just there to
give the feeling that something is happening.
"

Tmp_dir=$HOME

#Make it easy to put out a 'sets' list.
prep_list(){
ls --color=none *3 | sed 's/$/|/' > sets
}

get_tracks() {
    find $1 -type f -name '*mp3' -or -name '*ogg' -or -name '*m4a' > $Tmp_dir/plist.tracks
}

#If your directory names have @s in them, this will break.
get_sets() {
    find $1 -type f -name 'sets' \
     -exec sh -c "sed '/|[ \t]*$/d' \"{}\" | sed -e 's@.*|@{}|@' -e 's/sets|/|/'" \;  | sort | uniq > $Tmp_dir/plist.sets

#now just paths to tracks.
    find $1  -type f -name 'sets' \
     -exec sh -c "sed '/|[ \t]*$/d' \"{}\" | sed -e 's@^\([^|]*\)|.*@{}\1@ ' | sed 's-/sets-/-'" \;  | sort | uniq > $Tmp_dir/plist.setmembers
}

#Inefficient, but chill out; we're just making a playlist.
rm_line(){
    sed "${1}d" $2 > $Tmp_dir/plist.tmp
    mv $Tmp_dir/plist.tmp $2
}

append_a_set(){
    set_dir=`sed -n "$1 p" $Tmp_dir/plist.sets | sed "s/|.*//"`
    set_to_get=`sed -n "$1 p"  $Tmp_dir/plist.sets| sed "s/.*|//"`
    grep "|$set_to_get" "$set_dir/sets" | sed -e "s/|$set_to_get//" -e "s@^@${set_dir}@" >> list.m3u
    rm_line $1 $Tmp_dir/plist.sets
}

output_list(){
    while true; do
     Lt=`cat $Tmp_dir/plist.tracks | wc -l`
     Ls=`cat $Tmp_dir/plist.sets | wc -l`
     Len=$((Lt + $Ls))
     if [ $Len -eq 0 ]; then return; fi
     Line=$((RANDOM % $Len + 1))
     if [ $((Len % 100)) -eq 0 ]; then echo $Len ; fi
     if [ $Line -le $Lt ]; then
         track="`sed -n "${Line}p" $Tmp_dir/plist.tracks`"
         if grep "$track" $Tmp_dir/plist.setmembers > /dev/null ; then
             true; #skip this one---it's in a set.
         else
             echo "$track" >> list.m3u
         fi
         rm_line $Line $Tmp_dir/plist.tracks
     else
         Line=$((Line - $Lt))
         append_a_set $Line
    fi
    done
}

make_playlist () {
    get_tracks "`pwd`"   # change these print-working-directories
    get_sets "`pwd`"     # to your favorite fixed dir if you'd like
    output_list
#    rm $Tmp_dir/plist.sets $Tmp_dir/plist.tracks
}
