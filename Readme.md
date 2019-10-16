### Overview

Ludwig van Shuffle will generate a shuffled track listing, while retaining
multi-movement pieces as a unit.
You can specify your favorite pieces so they are put on the playlist more often.

Here is a sample output from my music directory. Each line is a single filename for a
single mp3/m4a/ogg, which is a common playlist format handled by most music
players as an `.m3u` file. A quick skim shows three blocks of multi-track pieces shuffled in with
everything else. 

```
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
various/SXSW_2014_Showcasing_Artists_Part1/Ingrid_Michaelson-Girls_Chase_Boys.mp3
RuPaul/supermodel_of_the_world/03_Free_Your_Mind.mp3
Nields/gotta_get_over_greta/05-i_know_what_kind_of_love_this_is.mp3
Osvaldo_Golijov/2007-Oceana/08-Tenebrae_-__I_First_Movemen.mp3
Osvaldo_Golijov/2007-Oceana/09-Tenebrae_-__II_Second_Movement.mp3
Ana_Tijoux/2009-1977/13-Avaricia.mp3
Leadbelly/Where_did_you_sleep_last_night.mp3
various/Jobim_songbook/06_Antonio_Carlos_Jobim___Só_Danço_Samba.mp3
```

### Building set lists

Before building playlists, you will first have to provide set lists indicating which pieces should hold together.
Ludwig van Shuffle uses plain text files because directory structures and the ID3v2 TSST tag are not
as reliable, text files are easy to write, and once you have prepared one you will never have to
think about it again.

In a directory with some multi-track portions, add a file named `sets`, where each line is of the form
```
track.mp3|set name
```
For example, here is a sample of a `sets` file for _Yiddishbbuk_ (St Lawrence String Quartet + Osvaldo Golijov composer):

```
01-Last_Round_-__I_Movido,_urgente.mp3|last round
02-Last_Round_-__II_Lentissimo.mp3|last round
03-Lullaby_and_Doina_-__1_Lullaby.mp3
04-Lullaby_and_Doina_-__2_Doina.mp3
05-Lullaby_and_Doina_-__3_Gallop.mp3|
06-Yiddishbbuk_-__Ia._D.W._(1932-1944).mp3|yiddishbbuk
07-Yiddishbbuk_-__II_I.B.S._(1904-1991).mp3|yiddishbbuk
08-Yiddishbbuk_-__III_L.B._(1918-1990).mp3|yiddishbbuk
```

The name can be anything—a, b, c or 1, 2, 3 are sufficient, just enough to uniquely identify the set within this directory.
Note that tracks 3-5 are unlabelled in the example, because those are a loose set of songs that are OK to shuffle.

* Tracks 3 and 4 have no pipe at all, and track 5 has a pipe followed by nothing; either works.

* The script will prefix the path to the set list and use the full path for string
comparisons, so begin the line with the bare directory name (not `./` or such).

* The easiest way to generate the file may be to write a directory listing to the sets file via `ls > sets`,
then open `sets` in a text editor to add set names. 

You can also a grand `sets` file in a higher directory, with subdirectories:

```
2007-Oceana/08-Tenebrae_-__I_First_Movement.mp3|tenebrae
2007-Oceana/09-Tenebrae_-__II_Second_Movement.mp3|tenebrae
2002-Yiddishbbuk/01-Last_Round_-__I_Movido,_urgente.mp3|last round
2002-Yiddishbbuk/02-Last_Round_-__II_Lentissimo.mp3|last round
```

* The `find` utility produces output that looks like this. Here is a pipeline to
get a listing, then use a `sed` filter to remove the initial `./` and add a final `|`:
```
cd /path/to/music; find . -type f -name '*mp3' | sed 's-^./--' | sed 's/$/|/' | sort > sets
```


### Running it

Once you have a `sets` file in every directory with a collection (meaning that many album
directories may not need a `sets` file at all), go to the root of your collection and run
```
python make_playlist.py > list.m3u
```
This playlist should be ready
to load into your favorite music player (sequentially, without the music player's less
discerning shuffle feature).  Typical music players look for an `.m3u` ending to the
file name.

* The script writes to stdout, so you have the option to write to any file name or location you
  need, or to filter the output, such as modifying the path names to suit your music
  player's expectations or filtering out tracks by an artist you aren't in the mood for today.
* The playlist is generated from the directory you are running the script from, but
  you can also change the `music_directory` variable at the top of the script to a fixed location.
* The random number generator is seeded with the time, so you will get a newly-shuffled
  playlist on every run (as long as your runs are more than a second apart).

### Weights

By default, all tracks are equally likely to be drawn---they each have a weight of one. You can
build a score file to modify this.
The `scores` file is separate from the `sets` file(s) under the presumption that it will change
as your preferences change, whereas Beethoven's fifth symphony will always have four movements.

Each line is a pipe delimited list of the form
```
path/to/element|weight
```
where `element` is either a file or the name of a set, and `weight` is the new weight. 
Here is a sample score file with some weights set:

```
Björk_Guðmundsdóttir/1995-post/05_Enjoy.mp3|2
2007-Oceana/tenebrae|2
2007-Oceana/last round|1.7
Ana_Tijoux/2009-1977/13-Avaricia.mp3|.6
Leadbelly/Where_did_you_sleep_last_night.mp3
```

* The first two items are each now twice as likely to be drawn.
* For sets, instead of a file name use the label for the set, as with `tenebrae` and `last round`
  as defined in the `sets` list above.
* If a track has been overplayed and you want to give it a rest, you can give a weight less than
  one. The Ana Tijoux track is 60% as likely to play as before.
* The same rules apply as for the `sets` lists: lines with no pipe or a pipe followed by nothing are
  ignored, as in the last line of the above example, and paths are relative to the current
  directory or the `music_directory` you set at the top of the script, and should not have any initial `./`
  or `/`.
* By default, the file should be named `scores`, in the `music_directory`, but set it as you prefer
  at the top of the script. If the file is not found, then no weights are changed.

Once Ludwig puts a track on a new playlist, it will not appear again, no matter how much weight it had.
If you set `list_length` at the top of the script to a number larger than the number of elements
you have, every track will be put on the list exactly once, but higher-weighted tracks are
likely to appear higher in the set list.
If you want a favorite track to appear multiple times in a playlist, concatenate together a number of short lists.
