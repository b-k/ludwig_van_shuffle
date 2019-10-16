music_directory="."
list_length=100 #Max number of items on the playlist (where 1 set==1 item).
score_file=music_directory+ '/scores'

import os,random

def get_a_set(sets, root, s):
    """Given a sets file s, append the elements to the sets list"""
    for line in s.readlines():
        ls=line.split('|')
        if len(ls)>1 and len(ls[1].strip())>0:
           sets.append([os.path.join(root, ls[0].strip()),
                             os.path.join(root, ls[1].strip())])

def get_tracks():
    """Walk through the directory adding every track to the list, without regard to any set lists to be gathered later."""
    tracks= []
    sets = []
    for root, subdirs, files in os.walk(music_directory):
      for i in files:
        name,e = os.path.splitext(i)
        if e=='.mp3' or e=='.m4a' or e=='.ogg' or e=='.MP3' or e=='.M4A' or e=='.OGG':
          tracks.append(root+ '/'+ i)
        if i=='sets':
          get_a_set(sets, root, open(root+ '/'+ i, 'r'))
    return tracks, sets

def get_scores(tracks, weights):
    try: s=open(score_file, 'r')
    except: return

    for line in s.readlines():
        line=line.strip()
        if len(line.split('|'))>1 and len(line.split('|')[1].strip())>0:
            try:
                tracknumber=tracks.index(music_directory+"/"+line.split('|')[0])
            except:
                print("trouble finding " + music_directory+"/"+line.split('|')[0] + " in the list. Skipping it.")
            else:
                weights[tracknumber] = float(line.split('|')[1])

def find_in_CMF(cmf, target):
    return sum([1 for x in cmf if x < target])

"""The program itself. First, build the lists of tracks and sets, then set up the distribution of
weights, then make the series of random draws to either pull a track or a set."""

tracks, sets =get_tracks()
setlist=list(set([s[1] for s in sets]))

weights=[1]*(len(tracks)+len(setlist))
get_scores(tracks + setlist, weights)

# Sequenced tracks are in the general track list; remove them.
for t in sets:
    if t[0] in tracks:
        weights[tracks.index(t[0])]=0

"""The random draw uses a cumulative mass function (CMF), i.e., the running total weight beginning at the first cell."""
cmf =list(weights)
for i in range(1, len(weights)):
    cmf[i]+= cmf[i-1]

random.seed() #with time
for ctr in range(0, list_length):
    if cmf[-1]<=0: break

    r=random.random()*(cmf[-1])
    i=find_in_CMF(cmf, r)
    if i < len(tracks): #You drew a non-set track.
        print(tracks[i])
    else: #you drew a set. Write out its elements
        s=i-len(tracks)
        group=[tr[0] for tr in sets if tr[1]==setlist[s]]
        for j in group:
            print(j)

    # Adjust the CMF from this element forward to eliminate the element's weight. Round away floating-point noise.
    cmf[i:]=[ round(c-weights[i], 5) for c in cmf[i:] ]
