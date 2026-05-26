# Retro Edutainment

I got fed up with the modern crop of "educational" videogames for my kids that
are crappy iphone apps or thinly-veiled pay-to-play crap with some math
problems thrown in.

The kids have been interested in retro gaming recently, so I decided to see if
I could find some of my old favorites.

## Overview
These games are DOS and early Windows games (8 and 16-bit architectures) from
The Learning Company, Broderbund, and the like. I run them on [DOSBox Staging];
an actively-maintained fork of DOSBox that is built for Apple Silicon. I have
the global config file set up with most of the settings I want (fullscreen on
launch, etc.)

The games each have their own folders in `dosgames`; for most of them I tried
to keep the folder names under 8 characters because of dos's limitations, but
it's not actually all that important. Each game's folder has the game files
and a `game.conf` file that is a config override for DOSBox; this lets us tune
DOSBox's settings to specific games if necessary. The game's config file also
has an autoexec section with commands to run on launch -- this way we can
launch the game within dosbox without having to manually mount anything or run
any DOS commands.

I use an applescript (the template is `play_dosbos_game.scpt`) exported as an
application to create icons on the desktop that launch individual games, and
some trickery with those can get you the game icons for each one.

### Quickstart
If you have games already, you can hopefully ignore all the stuff about
installing, tuning and setting up the games themselves. you'll need:

1. Setting up DOSBox Staging
2. Launching a Game From the Desktop

You may need to adjust the file paths in the applescript template and
game.conf files to match your system, but hopefully that's it.

## Setting up DOSBox Staging
You can download [DOSBox Staging] from their website, or install it via
homebrew: `brew install dosbox-staging`. The global config file should be in
your preferences directory, `~/Library/Preferences/DOSBox/dosbox-staging.conf`.

Copy ~/dosbox/dosbox-staging-conf from this bundle to the global location.

[DOSBox Staging]: https://www.dosbox-staging.org/

## Installing a Game
I found that the DOS games tended to all just be folders with files in them;
you mount the folder and launch the executable. Estract your games files into
`~/dosgames/mygame/game.exe`, open DOSBox, and run:

```
mount c ~/dosgames
c:
cd mygame
game.exe
```

## Tuning a Game
I mostly asked ChatGPT or another answer engine for help here. Games like
Treasure Galaxy run veeeery slowly with default settings, but I found
increasing the cycles setting smoothed them up a lot (this is already in the
game.conf for Treasure Galaxy). You may have more luck with other settings.
There may also be tuning you can do to video/audio settings to get better
outcomes with some games. Put those in the game.conf files.

## Launching a Game From the Desktop
You can use AppleScript to create an "application" that launches dosbox and
automatically launches a particular game. The file `play_dosbox_game.scpt` is
the template for how we do this.

### Configure DOSBox to Auto-run Your Game
Assuming your game is in a directory named `mygame` with an executable named
`game.exe`, put the following at the bottom of your game.conf:

```
[autoexec]
mount c ~/dosgames
c:
cd mygame
game.exe
exit
```

### Launch DOSBox From a Script
Open `play_dosbox_game.scpt` in the `Script Editor`. You should see the
following:

```
set game to "cove"

set homepath to POSIX path of (path to home folder)
set dosbox to homepath & "Applications/DOSBox Staging.app/Contents/MacOS/dosbox"
do shell script (quoted form of dosbox) & " -conf ~/dosgames/" & game & "/game.conf"
```

Make sure the `dosbox` variable actually points to the dosbox-staging
executable on your machine (it might be in `/Applications` instead of
`~/Applications` if you used homebrew, or somewhere else entirely if you did
something custom), and make sure the last line actually points to the
directory (`~/dosbox` in the example) where your games library lives.

Once you have everything else set up, the first line is all you need to change
to create a launcher for any game in your library: change `cove` to the
directory within `~/dosbox` that holds the game you want to play.

Test the script by pushing the "Run the Script" button (a "play" arrow), then
create the desktop shortcut by going to `File > Export`, naming the
application, choosing where to put it, and *important* changing the File
Format from "Script" to "Application". Double-click this icon to launch your
game!

#### Setting the Application Icon
If you want to use a custom icon for the game, you can create an icon set and
tell the launcher you made to use that.

First find the image you want to use (there are a seletion of them in the
`game icons` directory in this project). If you don't have a `.icns` file,
install `image2icon` (`brew install image2icon`) and use that to create a
`.icns` file from your image.

Find the launcher you made for your game in Finder. There are two things
you can do here; the first is right-click it and select "Show Package
Contents". Navigate down into `Contents > Resources` and copy your icns file
into that directory. Delete `applet.icns` and rename your custom icns file to
`applet.icns`. That actually didn't work for me, so what I did after was
right-click the launcher icon again and choose "Get Info". drag your icns file
to the little icon in the very upper-left of the info window and that should
set the application's icon.

## Windows Games
Windows games are a little trickier. DOSBox can run Windows 3.1 (although
apparently there are better options out ther; explore and rejoice!) but you
need to actually install windows and usually run the game's installer. You
also have to contend with driver issues.

### Installing Windows
Launch dosbox, mount the directory where you want your Windows installation to
live, mount the installer cd image, mount the video drivers we need, and run
the installer:

```
mount c ~/dosbox/windows
imgmount b ~/dosbox/win.iso -t cdrom
mount f ~/dosbox/drivers
b:
setup.exe
```

Revel in the retro glory. Press c early on to do a "custom" installation.
Leave the system directory as "C:\WINDOWS", but on the next screen arrow up to
"VGA" and hit enter to change the dispaly driver. go down the list to select
"other" and change the location to `f:\s3-964~1` then select "S3 964 1.41B5
640x480 256"

When the graphical portion of the insaller starts, uncheck "Set Up Printers"
"Set up Applications Already on Hard Disk". On the next screen uncheck all the
optional files, and on the next screen click "Networks > No Windows support
for networks." to skip network configuration. Click "continue", "Ok", "Skip
Tutorial", and "Restart Computer". Your Windows will reboot and drop you back at
the dosbox prompt.

Remount your windows directory as C: and your install disk as b:, then launch
windows again:

```
mount c ~/dosbox/windows
imgmount b ~/dosbox/win.iso
c:
cd windows
win
```

Go to "Control Panel > Drivers" and click "Add", then select "Creative Labs
Sound Blaster 1.5". Choose Port 220 and Interrupt 7 and finish out the
installation. (make sure your dosbox config file has `sbtype=sbpro2` in the
`[sblaster]` section)

Terminate DOSBox now. However, this still isn't quite enough; you can't launch
the windows games' binaries from dos, so we need to create a StartUp item for
the game. Since that'll only work for one game we'll want a fresh copy of this
windows installation for each game.

### Isn't This Just Containers
I mean basically yeah. If you wanna do it with Docker be my guest. To create
a fresh copy of the install for each game, we can just copy-paste the
directory into the game's folder. You can just put all the files together, but
I decided it makes more sense to make a little more structure:

```
cp -r ~/dosbox/windows ~/dosgames/mygame/windows
```

My file structure for these looks something like:

```
 dosgames
 └── mygame
    ├── game.conf
    ├── gamecd.iso
    ├── GAME
    └── windows
```

(the GAME directory doesn't exist yet, but that's where I have the installer
extract the files to)

### Install the Game
Launch dosbox and mount your game's windows install as `C`, the game's directory
as `D`, and the game's CD image as `E` _(NOTE: if the game needs the CD
inserted to play in the future, you need to mount it as the same drive letter
as you did during installation)_

```
mount c ~/dosgames/rescue/windows
imgmount e ~/dosgames/rescue/ssrwincd.iso -t cdrom
mount d ~/dosgames/
c:
cd windows
win
```

Open the file manager, click the CD drive, e: in the top bar, and find the
game's installer (`setup.exe` or `install.exe` or similar). Run that and
install the game to its directory: `d:\rescue\game` in this case. Once it's
done you can run the game to test that it worked (many of them have some kind
of calibration they run at this stage, but it should only happen the once).
After that, we need to create the StartUp item:

At the bottom of the Program Manager you should see a folder called "StartUp".
Double-click that, then click "File > New > Program Item > OK" Use the game's
name as the Description, and the path to the executable as "Command Line".
Something like: `D:\rescue\game\ssrwincd.exe`. Click OK. Now whenever you
launch this windows installation, that game should launch automatically.

### Your New game.conf Autoexec
The windows games need to mount their CDs (if necessary) and launch windows
instead of just launching the game's executable, so the Windows games'
`game.conf` files have an updated `[autoexec]` section:


```
[autoexec]
mount c ~/dosgames/rescue/windows
imgmount e ~/dosgames/rescue/ssrwincd.iso -t cdrom
mount d ~/dosgames/
c:
cd windows
win
```
