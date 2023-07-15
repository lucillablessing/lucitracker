# LuciTracker manual



## Overview

LuciTracker is a chiptune music player in the style of NES/Famicom music with microtonal support, which is also capable of playing music videos consisting of images drawn to a 64 by 64 pixel display.

Songs for LuciTracker are stored in .zip files with a custom structure; these contain assets such as samples and images, text files used for specifying information about the song, and two large text files containing instructions for playing music and animations, respectively. The music data file uses a text-based tracker-like format; every line contains instructions to several audio channels that play notes and execute effects. The animation data file consists of an easy-to-parse syntax that contains commands to draw certain elements to the screen. All assets and files within the .zip file are loaded into memory and parsed immediately when running LuciTracker, rather than being read line by line at run time.

Despite the name, LuciTracker is **not** a tracker; it can only *play* songs, not edit them.



## Playing a song

To play a song, drag and drop a valid .zip file onto the LuciTracker application; it will open and load the song. Once it's done loading, press any key to start playing. Once the song has finished, you can press any key once again to replay the song as often as you like.

If LuciTracker is started without a song, it will simply quit. If run with an invalid song, it will either error out during loading or during playback, depending on the error.



## File structure

Song files that LuciTracker can play are .zip files with the following structure:

* A folder `sound` containing .wav files that can be played as samples
* A folder `image` containing .png images used in the video animation
* A folder `config` containing .txt files (described below)
* A file `sequence.txt` describing notes and other musical instructions
* A file `video.txt` describing animation instructions

The folder `config` must contain the following files:

* `beats.txt`, describing timing information
* `samples.txt`, describing the list of .wav samples to load
* `images.txt`, describing the list of .png images to load
* `waves.txt`, describing the different waveforms the channels can use
* `envelopes.txt`, describing the different attack envelopes the channels can use
* `channels.txt`, describing the audio channels and their settings
* `tuning.txt`, describing the different notes and their names



## beats.txt

`beats.txt` consists of 4 lines, each a decimal natural number:

* `f` = framerate in frames per second (this is the frequency at which LuciTracker will run its main loop)
* `n` = number of frames per sequence line (one line from `sequence.txt` will be executed every `n` game frames)
* Sequence line to start playback from
* The number of draw channels

The first two lines control the song's tempo and timing. Note that `f` is not the same as the tempo. `f` describes the song's *refresh rate*, which is the rate at which dynamic effects (like slides and vibrato) are updated; this should be set to a higher value than the actual tempo. The song's tempo (sequence lines executed per second) is given by `f/n`. Both `f` and `n` can be changed during the song through effects.

The next value, the sequence line to start playback from, should normally be set to `0` in a finished song (as any higher value causes some parts of `sequence.txt` and `video.txt` to be ignored), but can be set to higher values for debugging purposes.

The final entry is the number of *draw channels*, which is unrelated to timing. Draw channels are objects that LuciTracker uses to play the music video. See the section on `video.txt` for more information about draw channels.

### Example in Ultrajoy

```
64
8
0
16
```

Ultrajoy has a refresh rate of `f` = 64 frames per second; every `n` = 8 of those frames, a sequence line is executed, resulting in a tempo of `f/n` = 8 lines per second (480 lines per minute; if treating each line as a triplet quaver, the tempo is 160 BPM).



## samples.txt

`samples.txt` consists of any number of lines; each line is the name of a .wav file (without the `.wav` extension) to be loaded as a playable sample. Note that LuciTracker primarily plays waveforms (like pulse, triangle, and sawtooth) and hard-coded noise samples; custom samples have a marginal role.

If a line begins with the `*` character, then the corresponding file (without the `*`) is loaded as a *looping* sample (it will loop indefinitely until the note ends); otherwise it's loaded as a *non-looping* sample (it will play only once).

The sample is assigned a zero-based index from its position in `samples.txt`; the first has index 0, the next has index 1, and so on. This is the index by which it can be referenced in `sequence.txt`. There is a limit of 256 samples; any samples beyond this limit cannot be referenced.

### Example in Ultrajoy

```
ocean
*static
final
```

There are 3 custom samples:

* Non-looping `ocean.wav` at index 0, used for the "ocean waves" sound effect at the beginning of the song.
* Looping `static.wav` at index 1; this is the Brownian noise heard near the ending of the song.
* Non-looping `final.wav` at index 2; used for the final note of the solo (there are too many other notes playing at that moment).



## images.txt

`images.txt` consists of any number of lines; each line contains the name of a .png file (without the `.png` extension) to be loaded as an image that can be drawn during the music video. These images aren't assigned numerical indices; instead, they're assigned their name directly, and this name is how they can be referenced in `video.txt`. For syntax reasons, the file names (apart from the `.png` extension) should only contain alphanumeric characters and underscores.

If a line contains the `#` character, then several files are loaded as *animation frames*, and treated as a single image. Their common name goes before the `#`, and the number of frames (as a decimal number) goes after the `#`. This tells LuciTracker to load several images all at once, with file names that look like `<common_name>_<i>.png` (where `i` ranges from 0 inclusive to the number of frames exclusive, in decimal), and make them available all at once under the name `common_name`.

For example, the line `img#4` tells LuciTracker to load `img_0.png`, `img_1.png`, `img_2.png`, and `img_3.png`, and make them available as frames 0, 1, 2, and 3 respectively of an image referred to as `img`.

The number of frames should not exceed 256; frames beyond this limit cannot be indexed by normal means. It's also possible, but not recommended, to load frames with non-uniform widths and heights, as the width and height of an image as drawn to the screen won't update when it switches to a different frame.

If a line does not contain the `#` character, then it simply loads a single file and makes it available under that name. Thus, the line `bg` would load the single image `bg.png` and make it available under the name `bg`.

### Example in Ultrajoy

Ultrajoy's `images.txt` has 89 lines, far less than the 308 .png images in its `image` folder, because many of these images are loaded as animation frames. These can be used for actual animation (so the frame index advances by one step at regular time intervals), but there's no convention to do so, and in fact many of Ultrajoy's images grouped into animation frames are just used for the convenience of grouping many related images under the same name with numerical indices.



## waves.txt

`waves.txt` consists of any number of lines; each line is the name of a waveform to be loaded:

* Pulse waveforms: `pulse_<m>_<n>` where `m/n` is one of `1/16`, `1/8`, `3/16`, `1/4`, `5/16`, `3/8`, `7/16`, or `1/2`
* `triangle`
* `sawtooth`

The names of the pulse waveforms describe the fraction of one cycle for which the signal is high; e.g. `pulse_1_4` describes a waveform which is high for 1/4 of a cycle and low for the remaining 3/4. `pulse_1_2` is an ordinary square wave. Cycle lengths greater than `1/2` are unavailable because they sound identical to their corresponding complementary cycles.

The waveform is assigned a zero-based index from its position in `waves.txt`; the first has index 0, the next has index 1, and so on. This is the index by which it can be referenced in `sequence.txt`. There is a limit of 16 waveforms; any waveforms beyond this limit cannot be referenced.

### Example in Ultrajoy

```
pulse_1_16
pulse_1_8
pulse_3_16
pulse_1_4
pulse_5_16
pulse_3_8
pulse_7_16
pulse_1_2
triangle
sawtooth
```

All pulse variants are available, at indices from 0 inclusive to 8 exclusive; then triangle at index 8 and sawtooth at index 9. (Ultrajoy actually only uses the odd-numbered pulse variants.)



## envelopes.txt

`envelopes.txt` consists of any number of lines; each line describes an *attack envelope*. Whenever LuciTracker begins playing a note, it applies the envelope's pattern to the volume of the note. This can be used to make staccato notes, or notes that gradually fade in over a short period of time.

Each line of `envelopes.txt` consists of a list of decimal natural numbers from 0 inclusive to 16 exclusive; separated by spaces. 0 represents silence, while 15 represents maximum volume.

Each number describes a *frame* of the envelope. Whenever a note starts playing, its volume is scaled by the first frame of the envelope; then, every game frame, the envelope frame advances by one step and updates the note's volume. Once it has reached the end of the envelope pattern, it stays on the last frame indefinitely until the note ends.

Thus, a line such as `15 8 4 2 1` would describe a note that starts at maximum volume and rapidly decays to 1/15 of its maximum volume over the course of 4 game frames. Changing the line to `15 8 4 2 1 0` would make the note fade out to silence after 5 game frames.

The envelope is assigned a zero-based index from its position in `envelopes.txt`; the first has index 0, the next has index 1, and so on. This is the index by which it can be referenced in `sequence.txt`. There is a limit of 16 envelopes; any envelopes beyond this limit cannot be referenced.

### Example in Ultrajoy

```
15
15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
0 3 6 9 12 15
15 12 8 6 4 3 2 1 0
15 15 15 14 14 14 13 13 13 12 12 12 11 11 11 10 10 10 9 9 9 8 8 8 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0
15 15 0
15 15 15 15 0
1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 8 8 8 9 9 9 10 10 10 11 11 11 12 12 12 13 13 13 14 14 14 15 15 15
```

There are 8 different envelopes:

* A flat envelope, which stays constant at maximum volume.
* A staccato envelope that decays from maximum volume to zero over 15 game frames.
* An envelope that fades in from silence over 5 game frames.
* Another staccato envelope which decays even faster; used for most noise notes.
* An envelope that fades out to silence a lot slower; used for cymbal-like noise notes.
* Two envelopes that cause notes to last 2 and 4 game frames respectively before being cut; used for the "letters" that appear near the end of the music video.
* An envelope that fades in from silence over a long time; used to fade in the Brownian noise near the end of the video.



## channels.txt

`channels.txt` consists of any number of lines; each line describes one *audio channel*. Audio channels are objects that control how LuciTracker makes music; each audio channel can play sound and follow instructions from `sequence.txt` independently of all the others. Each audio channel can play at most one sound at a time.

Each line of `channels.txt` consists of chunks delimited by spaces:

* The channel's *type*: one of `tone`, `noise`, or `sample`
* The number of *effect columns* to use for this channel: either `1` or `2`
* The *volume modifier*: a decimal real number between 0 and 1
* The *octave modifier*: a decimal integer, may be negative
* The default *envelope index*: a decimal natural number
* The default *waveform index*: a decimal natural number

The resulting audio channels appear in the same position in each line of `sequence.txt` as they were declared in `channels.txt`.

The channel *type* determines what the channel is capable of and what behavior it has, and also how many characters per line it gets in the sequence file. Briefly:

* `tone` channels can play waveforms like pulse, triangle, and sawtooth;
* `noise` channels can play one of sixteen noise samples of FamiTracker's 32k-bit white noise;
* `sample` channels can play samples from the `sound` folder loaded from `samples.txt`.

Like FamiTracker, channel types are fixed and can't be changed during the song. Unlike FamiTracker, any number of channels of any type, in any order, is permitted, and any tone channel can play any kind of waveform, which can change during the song.

The next entry, the number of *effect columns*, specify how many characters per sequence line this channel gets for effect instructions. More effect columns means more effects can be executed for that channel during a single line, but it also makes lines longer. Only `1` and `2` are supported as options; other numbers are possible, but will lead to playback errors.

The *volume modifier* is a global multiplier for the channel's amplitude. Raw audio data for `tone` channels is extremely loud, so it's recommended to set this to a rather low value (around `0.2`) for `tone` channels. Keep in mind as well that sharper waveforms like pulse tend to sound louder than smoother ones like triangle at the same amplitude.

The *octave modifier* is a global offset to the octave in which notes from `tone` channels are played; a value of `-1` would play every note one octave lower than written, and so on. This value can be changed with effects during the song. Non-`tone` channels ignore this entry.

The final two entries are the indices of the default *envelope* and *waveform* that this channel is initialized with (non-`tone` channels ignore the waveform entry). Envelope patterns and waveforms are declared in `envelopes.txt` and `waves.txt`, respectively.

### Example in Ultrajoy

```
tone 1 0.125 0 0 0
tone 1 0.125 0 0 0
tone 2 0.125 0 0 0
tone 2 0.125 0 0 0
tone 2 0.25 -1 0 8
tone 2 0.2 0 0 9
noise 1 1 0 3 0
sample 1 1 0 0 0
```

There are 8 audio channels; six `tone` channels, one `noise` channel, and one `sample` channel.

* The first two `tone` channels have one effect column each, a volume modifier of 0.125, no octave modifier, and are initialized with a flat envelope and the `pulse_1_16` waveform.
* The next two `tone` channels are identical to the two above, except they have two effect columns each.
* Next, there is a `tone` channel with two effect columns, 0.25 volume, one octave lower, a flat envelope and the `triangle` waveform.
* The final `tone` channel has two effect columns, 0.2 volume, no octave modifier, a flat envelope and the `sawtooth` waveform.
* The `noise` channel has one effect column, full volume, and is initialized to a strongly decaying envelope.
* The `sample` channel has one effect column, full volume, and is initialized to a flat envelope.



## tuning.txt

`tuning.txt` consists of any number of lines; each line describes one octave-equivalent *note* and any number of its *note names*.

Each line of `tuning.txt` consists of chunks delimited by spaces. The first chunk is a decimal real number, which is the multiplicative offset in frequency of this note from an A in the same octave. Exactly one of these numbers must be equal to 1. These lines may appear in any order, though by convention they should be in ascending order.

If `notes` denotes the array of all real numbers found in `tuning.txt`, then the total space of all possible pitches is then given by `notes[i] * 2^j`, where `i` ranges over all possible indices of `notes`, and `j` is any integer. In other words, octaves (doublings of frequency) are implicit, and tunings are assumed to be octave-repeating; non-octave tunings are not supported.

All other chunks in the same line are *names* of the note. These are the strings by which these notes can be referenced in `sequence.txt`. Their order is arbitrary, and they must each be exactly two characters in length. (Other lengths result in playback errors.)

This means every note can be given as many enharmonically equivalent names as desired, according to any note-naming system. A convention is for the first character to be an uppercase letter, and the second character to be an ASCII representation of an accidental, using `-` for natural notes, but you can use any two-character names you like.

### Example in Ultrajoy

```
0.5467799543793054 CB
0.5591434341058176 C@
0.5717864698579733 Cb
0.5847153827988435 Cv
0.5979366370220706 C-
0.6114568427837341 C^ DB
0.6252827598072934 C# D@
0.6394213006632594 C& Db
0.6538795342252860 Cx Dv
0.6686646892044085 D-
0.6837841577631961 D^ EB
0.6992454992116263 D# E@
0.7150564437865267 D& Eb
0.7312248965164778 Dx Ev FB
0.7477589411741042 E- F@
0.7646668443177352 E^ Fb
0.7819570594244508 E# Fv
0.7996382311165840 E& F-
0.8177191994837889 Ex F^ GB
0.8362090045028373 F# G@
0.8551168905573541 F& Gb
0.8744523110597485 Fx Gv
0.8942249331776564 G-
0.9144446426672516 G^ AB
0.9351215488158470 G# A@
0.9562659894962550 G& Ab
0.9778885363354327 Gx Av
1.0000000000000000 A-
1.0226114356012683 A^ BB
1.0457341482224871 A# B@
1.0693796985710673 A& Bb
1.0935599087586108 Ax Bv
1.1182868682116351 B-
1.1435729397159466 B^
1.1694307655976870 B#
1.1958732740441411 B&
1.2229136855674683 Bx
```

Ultrajoy is in 31edo, or 31 equal notes per octave. Thus the numbers in the left column are powers of `2^(1/31)`, centered around A. The note names follow ups and downs notation, where the perfect fifth represents 31edo's best approximation (18 steps), and all other intervals are combinations of octaves and perfect fifths.

The list starting at C and ending at B is not arbitrary; B to C is the point where octave number changes (by music theory convention). This order of pitches ensures that `G-3` is followed by `A-3`, but `B-3` is followed by `C-4`.

The following characters are used to represent the accidentals (keep in mind that these are arbitrary choices, not LuciTracker syntax):

* `-` for natural notes.
* `^` and `v` for semisharp and semiflat.
* `#` and `b` for sharp and flat.
* `&` and `@` for sesquisharp and sesquiflat (from the `&` and `@` accidentals of diamond-mos notation).
* `x` and `B` for double sharp and double flat.



## sequence.txt

`sequence.txt` contains the instructions to play music, and is usually the largest text file in the .zip archive in terms of bytes. This file follows a structure similar to that of FamiTracker: its lines are executed in the order they appear, and each line is divided into segments corresponding to each audio channel (in the same order as they were declared in `channels.txt`), with data such as note information, volume control, and effects. Hex digits occur commonly in this file; those hex digits that aren't decimal digits can freely be either uppercase or lowercase.

Segments corresponding to audio channels are not delimited; instead, their lengths in characters are determined by each channel's type and number of effect columns, `e`:

* For `tone` channels, the length is `4 + 3 * e` (7 if `e` = 1; 10 if `e` = 2).
* For `noise` channels, the length is `2 + 3 * e` (5 if `e` = 1; 8 if `e` = 2).
* For `sample` channels, the length is `3 + 3 * e` (6 if `e` = 1; 9 if `e` = 2).

In other words, `tone`, `noise`, and `sample` channels contain 4, 2, and 3 characters of non-effect data, respectively, and 3 characters per effect column, per line. The total length of each line is the sum of the lengths of all segments. Lines must not be shorter than this amount; empty entries should always be filled with space characters.

For example, if `channels.txt` declares two tone channels with two effect columns each, one noise channel with one effect column, and one sample channel with two effect columns, then each line will be 10 + 10 + 5 + 9 = 34 characters long; and the following ranges (start point inclusive, end point exclusive) within each line correspond to each channel:

* First tone channel: from 0 to 10;
* Second tone channel: from 10 to 20;
* Noise channel: from 20 to 25;
* Sample channel: from 25 to 34.

### Volume

For every channel, the last character of non-effect data (the character that directly precedes the effect columns) controls the channel's volume. This character must be either a space or a hex digit. A hex digit sets the channel's volume to a new value (`0` represents silence, `F` represents maximum volume), while a space leaves it unchanged.

This volume control is independent of the envelope, so that the actual volume of a channel is given by `(volume control) * (envelope volume) * (volume modifier) * (constant factor for normalization)`.

### Tone channels

A `tone` channel has three characters of non-effect, non-volume data. They represent an instruction to start playing a note, stop playing a note, or do neither.

* If the three characters are three spaces, it's a *do nothing* instruction.
* If the three characters are `---`, it's an instruction to immediately stop playing the current note.
* Otherwise: see below.

If the first two of the three characters are a valid note name as declared in `tuning.txt`, and the following character is a single-digit decimal number `n`, then this is an instruction to start playing a note with the given note name in octave `n`. For example, if the three characters are `G#2`, it will play the note with the name `G#` in octave 2. Octave numbers correspond to those seen in FamiTracker, which are one less than expected, so that a note declared as `1.0` in `tuning.txt` (an A) will play at 440 Hz when played in octave 3, not 4. This type of instruction will also cause a previous note, if any, to stop playing (unless automatic portamento is enabled, in which case it will gradually slide to the new pitch instead; see the section on effects).

### Noise channels

A `noise` channel has one character of non-effect, non-volume data:

* If the character is a space, it's a *do nothing* instruction.
* If the character is `-`, it's an instruction to immediately stop playing the current note.
* Otherwise, the character must be a hex digit, and it's an instruction to start playing one of the 16 noise samples from FamiTracker, where `0` is lowest and `F` is highest. This will also cause a previous note, if any, to stop playing.

### Sample channels

A `sample` channel has two characters of non-effect, non-volume data:

* If the two characters are two spaces, it's a *do nothing* instruction.
* If the two characters are `--`, it's an instruction to immediately stop playing the current note.
* Otherwise, the characters must form a two-digit hex number, and it's an instruction to start playing one of the (at most 256) custom samples indexed by the number. This will also cause a previous note, if any, to stop playing.

### Effects

The last data in each segment is effect data. It's divided into groups of three; each such group is called an *effect column*, of which there is either 1 or 2, depending on the channel declaration in `channels.txt`. Because the length of each segment and line is required to be constant, all effect columns must be present in each line, even if unused. A larger number of effect columns means more effects that can potentially be applied during the same sequence line, but it also causes all sequence lines to be longer.

Effects allow for additional control over a channel: actions such as sliding to a new pitch, vibrato, cutting a note short early, or changing the envelope or waveform of a channel. The effect list is heavily based on that of FamiTracker. Also similar to FamiTracker, an effect generally remains active until explicitly disabled.

If the effect data consists of a space followed by two arbitrary characters (usually also spaces), then it represents the lack of an effect. Otherwise, it consists of an *effect ID*, a *left parameter* `l`, and a *right parameter* `r`. The effect ID is a single uppercase letter which refers to a particular effect, and the left and right parameters are hex digits passed as arguments to the effect function. Depending on the effect, one of the parameters may be ignored, or both can be treated jointly as a single, two-digit hex number `d`.

### Effect list

#### U, D: Pitch Up, Pitch Down

Ignores `l`. If `r` is zero, disables the effect. Otherwise, starts sliding the pitch upwards or downwards indefinitely, with `r` pitch increments every game frame. Can only be used with `tone` channels.

#### P: Portamento

If `d` is zero, disables the effect. Otherwise, enables *automatic portamento*: new notes will gradually slide to their pitches, instead of snapping to a new pitch instantly, with `d` pitch increments every game frame. Can only be used with `tone` channels.

#### V: Vibrato

If `l` is zero, disables the effect. Otherwise, enables vibrato. `l` sets the speed, and `r` the intensity of the vibrato. Can only be used with `tone` channels.

#### S: Set Speed

Sets the number of game frames per sequence line (the `n` value from `beats.txt`) to `d`. Works in any channel.

#### T: Set Tempo

Sets the framerate or refresh rate (the `f` value from `beats.txt`) to `d`. Works in any channel.

#### Q, R: Slide Up, Slide Down

Slides the current note up or down by `r` tuning steps (so that if the old pitch was at position `x` in `tuning.txt`, the new pitch will be at position `x + r` or `x - r`). `l` sets the speed. Can only be used with `tone` channels.

#### C: Cut

Cuts the current note short after `d` game frames. Useful for notes that should be shorter than the duration of one sequence line.

#### I: Instrument Change

Changes the envelope and waveform of the current channel. This change applies before the note, if any. `l` sets the new envelope index, and `r` the new waveform index. Non-`tone` channels ignore `r`.

#### O: Octave Change

Changes the octave modifier of the current channel. `d` is treated as a two's complement number to allow negative numbers. Has no effect on non-`tone` channels.

### Example in Ultrajoy

An excerpt from near the beginning of the song, annotated with segment division based on the declarations in `channels.txt`:

```
   0      1        2         3         4         5      6     7  
[-----][-----][--------][--------][--------][--------][---][----]


D-25I03D-45I03B-35I03   F#35I03                       4A         
                                                                 
E-2    C#4    A#3       E#3                           4          
                                            D-36I09              
F#2    Cv4    A-3       E-3                           4          
                                                                 
G-16I07B-35I03G-35I03   D-35I03             B-36P0C   06         
          4                                                      
          3      4         4                                     
---       2                                           83         
```

* Channels 1, 2, and 3 play a chord sequence (`F#-B-D`, `E#-A#-C#`, `E-A-Cv`) at volume 5, with the flat envelope (index 0) and the `pulse_1_4` waveform (index 3). When they end up on a G major chord, after some time they lower their volume to 4, except channel 1 which lowers it all the way to 2.
* Channel 0 also plays along with the chords, but switches to `pulse_1_2` (index 7) and volume 6 on the G major chord. It also stops playing once channel 1 has reached volume 2.
* Channel 4 is silent during this excerpt.
* Channel 5 starts playing midway through the chords, with the `sawtooth` waveform and volume 6. It slides from its first note `D-3` to its second note `B-3` automatically using the `P` (portamento) effect, whose speed is set to `0C` (decimal 12).
* Channel 6 is the noise channel. It plays sample 4 at volume A (decimal 10) three times during the chords, then sample 0 at volume 6 during the G major chord, and finally sample 8 at volume 3 when channel 0 goes silent. It's been initialized to use a quickly decaying envelope, so these notes are staccato and don't persist indefinitely.
* Channel 7 is the sample channel, and is silent during this excerpt.



## video.txt

`video.txt` contains the instructions for a music video that plays in sync with the music. Unlike the very "rectangular" syntax of `sequence.txt`, which includes spaces everywhere to indicate the lack of an instruction, `video.txt` only contains the non-null instructions along with the data about when they should happen, in a simple, easily deserializable format. Hex digits occur commonly in this file; those hex digits that aren't decimal digits can freely be either uppercase or lowercase.

Much like the music is governed by audio channels, the animation is governed by so-called *draw channels*. Each draw channel is an independent object that can draw an image to the screen, fill the screen with a solid color, or do nothing.

Unlike audio channels, the order of draw channels is important, as they always apply their effects in order: channel 0 first, then channel 1, and so on. They can also be thought of as increasing in "depth" or "z-level" towards the "front of the screen" for this reason, with channel 0 being the most in the "background".

Also unlike audio channels, all draw channels are created equal, with the same capabilities and instruction set. For this reason, there's no declaration of draw channels, only the declaration of their number in `beats.txt`.

Drawing is **not** updated every game frame; rather, it only updates on every new sequence line. This means the video framerate is equal to the song tempo in lines per second (`f/d`), and every action on the screen is synced with a sequence line.

### Line structure

Each line of `video.txt` consists of chunks delimited by commas. The first chunk is a single decimal natural number; it specifies the sequence line during which this line is to be executed. (Keep in mind that LuciTracker treats sequence lines as zero-indexed, while most text editors display one-based line numbers.) These are the only decimal numbers in `video.txt`; all other numbers are in hex.

Every further chunk after the first consists of commands to a particular draw channel; these chunks may appear in any order. Each such chunk begins with an index of a draw channel (a hex number), followed by any number of commands to the channel. Each command begins with a `!`, `#`, or `-` character, and lasts until the next such character, comma, or end of the line. At most one of these commands can be a *principal command* (begins with `!` or `#`), all others are *effect commands* (begin with `-`). If a principal command appears, it must be the first.

Every line of `video.txt` ignores all space characters inside of it, and all descriptions of the syntax are to be applied to lines which have been stripped of spaces. Spaces may be inserted for better readability or left out for compactness to your liking.

Lines may appear in any order, though they should be in ascending order by convention. Empty lines are ignored, as are lines that begin with the character `@`.

### Image command

A principal command that starts with `!` is an *image command*, which tells a draw channel to start drawing a specific image to the screen. Its contents are parsed as follows:

* The first four characters are hex digits, and specify two 2-digit hex numbers `x` and `y`, each in the range from 0 inclusive to 64 exclusive.
* The remaining characters are an image name that has been loaded into the image table from `images.txt`.

The meaning of the command is to start drawing the image with the given name, with its top-left corner at the given `x` and `y` position. If the image has animation frames, then the frame with index 0 will be drawn by default. The coordinate system's origin is in the top-left corner of the screen; `x` increases towards the right, while `y` increases downwards.

### Color command

A principal command that starts with `#` is a *color command*, which usually tells a draw channel to fill the screen with a solid color (thus it normally only makes sense to give this command to at most one draw channel at a time). Its contents should be exactly six characters, all of which should be hex digits, specifying a hex color code according to the scheme `#rrggbb`.

The meaning of the command is usually to fill the screen with the specified color. However, if the color code is exactly `#DECADE` (red 222, green 202, blue 222), the channel will instead be turned off, so that it draws nothing to the screen until reactivated (though effects, if any, will stay active).

### Effects

Any other command is an *effect command*, and starts with `-`. Its contents are always one uppercase letter which refers to an effect (the *effect ID*), followed by exclusively hex digits. The number of hex digits, and how they combine to form numbers, depends on the effect.

Much like effects to audio channels, these allow draw channels to perform more actions when drawing images. Also like effects to audio channels, once activated, will stay that way until explicitly deactivated, even if no longer drawing an image.

### Effect list

#### C: Crop

Takes eight hex digits, grouped into four 2-digit hex numbers `x`, `y`, `w`, `h`. If drawing an image, changes a rectangular "cut-out" of the image to draw to the screen, specified by:

* `x` = x-coordinate of the top-left corner of the rectangle, as an offset to the right from the top-left corner of the image
* `y` = y-coordinate of the top-left corner of the rectangle, as an offset downwards from the top-left corner of the image
* `w` = width of the rectangle
* `h` = height of the rectangle

If the width or height are less than those of the image, the image is "cropped", hence the name. If the width or height are greater, the image is tiled.

#### W, A, S, D: Move Up, Left, Down, Right

Take two hex digits `s` and `t`. If drawing an image:

* If `s` is zero, disables the effect.
* Otherwise, if `t` is zero, translates the position of the image by `s` pixels in the respective direction.
* Otherwise, makes the image start "moving" in the respective direction, translating its position by `s` pixels every `t` sequence lines.

#### I, J, K, L: Travel Up, Left, Down, Right

Take two hex digits `s` and `t`. If drawing an image:

* If `s` is zero, disables the effect.
* Otherwise, if `t` is zero, translates the position of the "cut-out" rectangle by `s` pixels in the respective direction.
* Otherwise, makes the rectangle start "moving" in the respective direction, translating its position by `s` pixels every `t` sequence lines. This has the effect of a "camera" moving in the given direction.

#### M: Set Frame

Takes two hex digits, grouped into a number `m`. If drawing an image with multiple animation frames, sets the frame index to `m`.

#### N: Increment Frame

Takes two hex digits `s` and `t`. If drawing an image with multiple animation frames:

* If `s` is zero, disables the effect.
* Otherwise, makes the frame's index automatically increment by `s` (wrapping around, modulo the total number of frames) every `t` sequence lines. This is the effect that makes "animation frames" actually work like their name implies.

#### X, Y: Set X, Set Y

Take two hex digits, grouped into a number `h`. If drawing an image, sets the x or y position to `h`.

### Example in Ultrajoy

An excerpt from the intro to the song:

```
@ --- BOOT SCREEN ---

0,    0 #000000, 1 ! 02 02 boot -C 02 02 30 09
6,    1 -C 02 02 34 12
12,   1 -C 02 02 34 1E
21,   1 -C 02 02 34 2A

@ --- INTRO ---

30,   0 ! 00 00 start, 1 #DECADE
36,   0 -K 11
84,   0 -K 00
92,   1 ! 1F 2C mario_jump, 2 ! 1D 2B mario_spawn
93,   2 -M 01
94,   1 -Y 2D, 2 #DECADE
95,   1 -Y 2E
```

At sequence line 0, draw channel 0 is made to draw a black background, while channel 1 draws progressively larger cut-outs of the image `boot` at (2, 2). The widths and heights of the cut-outs are (48, 9), then (52, 18), then (52, 30), and finally (52, 42).

Then, at line 30, channel 0 switches to drawing the image `start` at (0, 0), while channel 1 turns off. At line 36, channel 0's "camera" begins moving downwards at a rate of 1 pixel every 1 line, and stops moving at line 84.

At line 92, channel 1 becomes active again, drawing `mario_jump` at (31, 44), and channel 2 draws `mario_spawn` at (29, 43). Note that `mario_spawn` is an image with multiple animation frames, and so channel 2 draws the frame with index 0. At line 93, this frame index is changed to 1. At line 94, channel 1 moves its image's y-coordinate to 45 (one pixel downwards), while channel 2 turns off; finally, at line 95, channel 1 moves its image one more pixel downwards to a y-coordinate of 46.

The two lines beginning with `@`, as well as the empty lines, and all spaces, are ignored.



## Legal stuffies

LuciTracker's source code is released under the [Unlicense](https://choosealicense.com/licenses/unlicense/), which means it's in the public domain. That means you can do whatever you want with it: read it, learn from it, mod it, reverse engineer it, or feed it as input to your Markov chain generator.
