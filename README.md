# MonkeyWM
Monkey Window Manager (MonkeyWM)

MonkeyWM is a lightweight WM written in Freepascal.
http://www.freepascal.org/
If you have problems with the url above:
http://www.hu.freepascal.org/

Requirements:
Xlib and Imlib2
To compile MonkeyWM you will need the Freepascal compiler.
http://sourceforge.net/project/showfiles.php?group_id=2174

Compile:
cd into the monkeywm-0.2/src folder and
ppc386 ./monkeywm.lpr

Running:
In your $HOME folder you should have a file named: .xinitrc
add "exec /path/to/monkeywm" (without the quotes)
NOTE: If you already have a window manager setup you will need to
comment that line out.

I have only gotten MonkeyWM running on Linux so far. (Slackware 11
and Arch Linux 2007.08-2)
I tried to run MonkeyWM on FreeBSD 6.2 but it would not run long.
I did not have the time to investigate why it was crashing.

A week long search for a usable pascal window manager came up empty.
The only thing that I did find was XPDE
http://www.xpde.com/
XPDE is written in Kylix. I do not have Kylix and I do not want to
pay for Kylix when we have great free programs like Freepascal.
I decided to start from scratch working on a lightweight WM in Freepascal.
I looked at 2 other WM for pointers.
SWM - http://www2.informatik.hu-berlin.de/~sperling/prog/swm.html
WindowLab - http://nickgravgaard.com/windowlab/

I wrote MonkeyWM using Lazarus (it is what I am used to)
http://www.lazarus.freepascal.org/

MonkeyWM is not finished (is any program ever finished ;)) and
I will be working to add more features.

monkeywm.ini
The first file that MonkeyWM reads is monkeywm.ini and it is setup
like this:
[Settings]
Debug=False
Debug_To_File=False
Num_Lock_On=True
Number_Of_Desktops=4

[LaunchBar]
Use=True
Icons_Size=32
Use_Dbl_Click=False
Dbl_Click_time=300

[Desktop]
Use=True
Icons_Size=48
Use_Dbl_Click=True
Dbl_Click_time=300

[Theme]
Use_Theme=True
Folder=default

[Colors]
Background=green
Foreground=white
Border_Color=black

Most of the settings are self-explanatory.
[Settings]
Debug=True will turn on the debugging.
Debug_To_File=True will write debug info to file. $HOME/.monkeywm/debug/Debug-MonkeyWM.txt
Num_Lock_On=True turns number lock on when MonkeyWM starts.
Number_Of_Desktops=4 Number of desktops. Minimum is 1 and maximum is 12.

[LaunchBar]
Use=True will turn on the launchbar.
Icons_Size=32 is the size you want the icons
Use_Dbl_Click=True turn on the need to double click to launch 
Dbl_Click_time=300 the time betweens to judge if double click or not

[Desktop]
Use=True will turn on desktop icons
Icons_Size=48 is the size you want the icons
Use_Dbl_Click=True turn on the need to double click to launch 
Dbl_Click_time=300 the time betweens to judge if double click or not

[Theme]
Use_Theme=True enables the use of a theme.
Folder=default the subfolder that the theme is located in.
  $HOME/.monkeywm/themes/default
  $HOME/.monkeywm/themes/ is the base folder.

[Colors]
Background=green
Foreground=white
Border_Color=black
  At the moment colors are not used. I have to look into cleaning it up.


Startup programs:
To startup programs when MonkeyWM starts up you need to make a file
called "startup" in your $HOME/.monkeywm/ folder.
Add the execution name of the program. 1 per line.
I only have conky in mine:
conky

The startup file can only contain the execution name.
No arguments can be handled. That will be fixed soon.

LaunchBar:
If you plan on using the launchbar you will need to make a file called "launchbar"
in your $HOME/.monkeywm/ folder.
Each line will contain:
Program Name|/path/to/icon/image.png|program
Program Name is the Name you wish to call it.
/path/to/icon/image.png is the image that you want to show on the launchbar.
program is the execution name. Arguments ARE supported in the launchbar file. Up to 6.
Program Name
Icon
Execution
Seperated by "|"
Program Name|Icon|Execution

Popup menu:
To have a menu popup when you right-click on your desktop you need to make
a file named "menu" in your $HOME/.monkeywm/ folder.
Each line will contain:
Program Name|/path/to/icon/image.png|program
Program Name is the Name you wish to call it.
/path/to/icon/image.png is the image that you want to show on the popup menu.
program is the execution name.
Program Name
Icon
Execution
Seperated by "|"
Program Name|Icon|Execution



