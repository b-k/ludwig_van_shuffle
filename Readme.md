Overview
=====

The intent of this script is to generate a shuffled track listing, while retaining
multi-movement pieces as a unit. You write simple set lists
and then run the script to build a shuffled play list.

Here is a sample output from my music directory. Each line is a single filename for a
single mp3 (or m4a or ogg), which is a common playlist format handled by most music
players as an `.m3u` file. Three blocks of multi-track pieces are shuffled in with
everything else. 

```
...
Budos_Band/2007-Budos_Band/05-Monkey_See,_Monkey_Do.mp3
various/SXSW_2014_Showcasing_Artists_Part1/Boldy_James-Moochie.mp3
Witold_Lutosławski/2015-Piano_Concerto,_Symphony_No._2/01-Concerto_for_Piano_and_Orchestra_-__1_♩._=_ca._110.mp3
Witold_Lutosławski/2015-Piano_Concerto,_Symphony_No._2/02-Concerto_for_Piano_and_Orchestra_-__2_Presto_-_Poco_meno_mosso_-_Lento.mp3
Witold_Lutosławski/2015-Piano_Concerto,_Symphony_No._2/03-Concerto_for_Piano_and_Orchestra_-__3_♪_=_ca._85_-_Largo.mp3
Witold_Lutosławski/2015-Piano_Concerto,_Symphony_No._2/04-Concerto_for_Piano_and_Orchestra_-__4_♩_=_ca._84_-_Presto.mp3
Moon HoP/Welcome Back To The Moon/07_Mambo_Es_Ska.mp3
Björk_Guðmundsdóttir/1995-post/05_Enjoy.mp3
Remy_Zero/The_golden_hum/01-the_golden_hum.mp3
Remy_Zero/The_golden_hum/02-glorious_1.mp3
Remy_Zero/The_golden_hum/03-out_in.mp3
various/SXSW_2014_Showcasing_Artists_Part1/Boldy_James-Moochie.mp3
RuPaul/supermodel_of_the_world/03_Free_Your_Mind.mp3
various/Movers!/05-Soul_Searchers--Think.mp3
Nields/gotta_get_over_greta/05-i_know_what_kind_of_love_this_is.mp3
Osvaldo_Golijov/2007-Oceana/08-Tenebrae_-__I_First_Movemen.mp3
Osvaldo_Golijov/2007-Oceana/09-Tenebrae_-__II_Second_Movement.mp3
Ana_Tijoux/2009-1977/13-Avaricia.mp3
Leadbelly/Where_did_you_sleep_last_night.mp3
various/Jobim_songbook/06_Antonio_Carlos_Jobim___Só_Danço_Samba.mp3
...
```

To make this work, you will have to provide set lists indicating which pieces should hold
together. Ludwig van Shuffle does this via plain text files, because directory structures
and the ID3v2 TSST tag are not as reliable. You should be able to spend a few seconds setting up
a set list for an album, then never think about it again.

Once your set lists are in place, just run `python make_plist.py > list.m3u` to generate a playlist.



Building set lists
=====

In a directory with some multi-track portions, add a file named `sets`, where each line is
of the form
```
track.mp3|set name
```
For example, here is my `sets` file for _Yiddishbbuk_ (St Lawrence String Quartet + Osvaldo Golijov composer).

```
01-Last_Round_-__I_Movido,_urgente.mp3|last round
02-Last_Round_-__II_Lentissimo.mp3|last round
03-Lullaby_and_Doina_-__1_Lullaby.mp3|
04-Lullaby_and_Doina_-__2_Doina.mp3|
05-Lullaby_and_Doina_-__3_Gallop.mp3|
06-Yiddishbbuk_-__Ia._D.W._(1932-1944).mp3|yiddishbbuk
07-Yiddishbbuk_-__II_I.B.S._(1904-1991).mp3|yiddishbbuk
08-Yiddishbbuk_-__III_L.B._(1918-1990).mp3|yiddishbbuk
09-The_Dreams_and_Prayers_of_Isaac_the_Blind_-__Prelude.mp3|dp
10-The_Dreams_and_Prayers_of_Isaac_the_Blind_-__I_Agitato.mp3|dp
11-The_Dreams_and_Prayers_of_Isaac_the_Blind_-__II_Teneramente.mp3|dp
12-The_Dreams_and_Prayers_of_Isaac_the_Blind_-__III_Calmo,_sospeso.mp3|dp
13-The_Dreams_and_Prayers_of_Isaac_the_Blind_IV._Postlude_-__Lento.mp3|dp
```

The name can be anything—a, b, c or 1, 2, 3 are sufficient, just enough to uniquely identify the set within this file.
Note that tracks 3-5 are unlabelled in the example, because those are a loose set of songs that are OK to shuffle.

You can also have the `sets` file in a higher directory, with subdirectories:

```
2007-Oceana/08-Tenebrae_-__I_First_Movement.mp3|tenebrae
2007-Oceana/09-Tenebrae_-__II_Second_Movement.mp3|tenebrae
2002-Yiddishbbuk/01-Last_Round_-__I_Movido,_urgente.mp3|last round
2002-Yiddishbbuk/02-Last_Round_-__II_Lentissimo.mp3|last round
```

The script will prefix the path to the set list and use the full path for string
comparisons, so begin the line with the bare directory name (not `./` or such).

Sorry Kendrick Lamar fans, but tracks in the `sets` file can't have a pipe in the name.

The `sets` file starts with a directory listing with a pipe after each name, which is
simple enough that there are many, may means of generating such a list from the command line.
I generate the base set list via a simple shell function that I wrote:
```
prep_list(){
    ls --color=none *3 | sed 's/$/|/' > sets
}
```
and then I open `sets` in a text editor to add set names. 

Or, generate a grand `sets` list for your entire collection via `find` and
a quick `sed` filter to remove the initial `./` and add a final `|`:
```
cd /path/to/music; find . -type f -name '*mp3' | sed 's-^./--' | sed 's/$/|/' | sort > sets
```


Running it
=====

Once you have a `sets` file in every directory with a collection (meaning that many album
directories may not need a `sets` file at all), go to the root of your collection and run
```
python make_playlist.py > list.m3u
```
This playlist should be ready
to load into your favorite music player (sequentially, without the music player's less
discerning shuffle feature).  Typical music players look for an `.m3u` ending to the
file name.

The script writes to stdout, so you have the option to write to any file name/location you
need, and to filter the output, such as modifying the path names to suit your music
player's expectations or filtering out tracks by an artist you aren't in the mood for today.

The playlist is generated from the directory you are running the script from, but
you can also change the `music_directory` variable on the first line to a fixed location.

The random number generator is seeded with the time, so you will get a newly-shuffled
playlist on every run (as long as your runs are more than a second apart).
