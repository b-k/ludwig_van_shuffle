The intent of this script is to generate a shuffled track listing, while retaining
multi-movement pieces as a unit. You write set lists, in a format intended to be
easy to write, and then run the script to build a shuffled play list.


Building set lists
=====

In a directory with some multi-track portions, add a file named `sets`, where each line is
of the form
```
track.mp3|set name
```
For example, here is my `sets` file for _Yiddishbbuk_ (St Lawrence String Quartert + Osvaldo Golijov composer).

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

I generate the base set list via a simple shell function that I wrote:
```
prep_list(){
    ls --color=none *3 | sed 's/$/|/' > sets
}
```
and then open `sets` in a text editor to add set names. 


You can also have the set list in a higher directory, with subdirectories:

```
2007-Oceana/08-Tenebrae_-__I_First_Movement.mp3|tenebrae
2007-Oceana/09-Tenebrae_-__II_Second_Movement.mp3|tenebrae
2002-Yiddishbbuk/01-Last_Round_-__I_Movido,_urgente.mp3|last round
2002-Yiddishbbuk/02-Last_Round_-__II_Lentissimo.mp3|last round
```

The script will prefix the path to the set list and use the full path for string
comparisons, so begin the line with the bare directory name (not `./` or such).
You may be able to generate a grand `sets` list for your entire collection via `find` and
a quick `sed` filter to remove the initial `./`:
```
cd /path/to/music; find . -type f -name '*mp3' | sed 's-^./--' > sets
```

Sorry Kendrick Lamar fans, but tracks on the setlist can't have a pipe in the name.

Running it
=====

Once you have a `sets` file in every directory with a collection (meaning that many album
directories may not need a `sets` file at all), go to the root of your collection and run
```
python make_playlist.py
```
and it will output `list.m3u`, with one track per line. This playlist should be ready to
load into your favorite music player (sequentially, without the music player's less discerning shuffle feature).

You can also change the `music_directory` variable on the first line to a fixed location.
