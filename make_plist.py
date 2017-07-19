music_directory="."

import os,random

def get_tracks():
  tracks= []
  for root, subdirs, files in os.walk(music_directory):
    for i in files:
        name,e = os.path.splitext(i)
        if e=='.mp3' or e=='.m4a' or e=='.ogg' or e=='.MP3' or e=='.M4A' or e=='.OGG':
          tracks.append(root+ '/'+ i)
  return tracks

def get_sets():
  sets=[]
  for root, subdirs, files in os.walk(music_directory):
    for i in files:
        if i=='sets':
            s=open(root+ '/'+ i, 'r')
            for line in s.readlines():
                line=line.strip()
                if len(line.split('|'))>1 and line.split('|')[1] !="\n":
                  sets.append(list((os.path.join(root, line.split('|')[0]), os.path.join(root, line.split('|')[1]))))
  return sets

tracks=get_tracks()
sets = get_sets()

setlist=list(set([s[1] for s in sets]))

# Sequenced tracks are in the general track list; remove them.
for t in sets:
    if t[0] in tracks:
        del tracks[tracks.index(t[0])]

random.seed() #with time
while len(tracks)>0:
    i=random.randint(0,len(tracks)+len(setlist)-1)
    if i < len(tracks):
        t=tracks[i]
        print(t)
        del tracks[i]
    else: #you drew a set. Write out its elements
        s=i-len(tracks)
        group=[tr[0] for tr in sets if tr[1]==setlist[s]]
        for i in group:
            print(i)
        del setlist[s]
