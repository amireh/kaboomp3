## kaBOOM?

kaBoomp3 is a very simple tool that _organizes_ your music library according to some options you can customize. For example, you can arrange your music directory to look something like this: 

    Library/Genres/Artists/Albums/Tracks

One very good use of kaBoomp3 is in sharing iPods; if you "rip", or copy the music contents of an iPod, they will be named cryptically, however, by allowing the application to organize it, you will have a tidy music library of your iPod music!

### You're gonna blow my files up?

Well, contrary to what the name might imply, kaBoomp3 is very safe in running its business; it will show you a *preview* of all the changes before committing them. Only if you approve of the changes will it process your library.

### What kind of music files can you organize?

Currently, supported music file formats are:

* .mp3

## Installing & Running

I plan to package the application and all its dependencies into a portable executable, which will include the Ruby interpreter, to save you the hassle of building the necessary dependencies. However, if for some reason you have/want to run it off the repository, here's what you need:

* Qt 4.6.3 development libraries 
* qtruby gem (or qtbindings)
* id3lib-ruby gem
* active_record gem (will be removed in a later build)
* sqlite3-ruby gem

## To-do

* add support for parsing other audio codecs
* add a "Super/Sub Genres" sorting field, ie: Heavy Metal and Gothic Metal genres would fall under Metal genre
* offer levels of organizing: 
  * __light__: does not modify filenames or tags, only moves files around
  * __normal__: obeys user sorting preferences, renames known files and moves them according to their id3 tag
  * __aggressive__: attempts to correctly fill in missing id3 fields

## Known Issues

* corrupt MP3 files will cause the program to **HANG**; currently there's no workaround, as there is no way to validate a file for corruption and the parser gem (id3lib) does not crash or throw any exception, it just hangs indefinitely
* UI: message box dialogues are confined to a small area