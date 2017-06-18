music_directory="."

import os,random

def get_tracks():
  tracks= []
  for root, subdirs, files in os.walk(music_directory):
    for i in files:
        name,e = os.path.splitext(i)
        if e=='.mp3' or e=='.m4a' or e=='.ogg':
          tracks.append(root+ '/'+ i)
  return tracks

def get_sets():
  sets=[]
  for root, subdirs, files in os.walk(music_directory):
    for i in files:
        if i=='sets':
            s=open(root+ '/'+ i, 'r');
            for line in s.readlines():
                if line.split('|')[1] !="\n":
                  sets.append(list((root+'/' + line.split('|')[0], root+'/' + line.split('|')[1])))
  return sets

tracks=get_tracks()
sets = get_sets()

setlist=list(set([s[1] for s in sets]))

# Sequenced tracks are in the general track list; remove them.
for t in sets:
    if t[0] in tracks:
        del tracks[tracks.index(t[0])]

random.seed() #with time
f=open("list.m3u","w")
while len(tracks)>0:
    i=random.randint(0,len(tracks)+len(setlist)-1)
    if i < len(tracks):
        t=tracks[i]
        f.write(t+"\n")
        del tracks[i]
    else: #you drew a set. Write out its elements
        s=i-len(tracks)
        group=[tr[0] for tr in sets if tr[1]==setlist[s]]
        for i in group:
            f.write(i+"\n")
        del setlist[s]
