# Tutorial

*This document is a work in progress at the moment.*

## Introduction to Bookie

Most web browsers organize bookmarks into folders and titles. The idea behind bookie is that bookmarks don't organize well into folders. Wouldn't it be nice to just type something in and have all your related bookmarks appear? There's nothing magical or technologically advanced about bookie & marks. They're mostly about UI. Bookie tries to be a little more pleasant, human, and mortal (as in you can kill your data in the cloud permanently).

Bookie understands a bookmark to be a pairing between a URL and a tagline. The tagline is similar to a bookmark title in a browser. What makes a tagline different from a title is a tagline is used as a stream of consiousness. It is intended for the user to fill a tagline with a collection of mental associations he or she has with the URL. When the user then searches for a bookmark, he or she will enter some words (synomous with tags) and bookie will return a list of URLs and taglines that match. Every word in the tagline is an individual tag.

If a user sends a search to bookie with a line of text such as "for physics", bookie will return a list of entries where the words "for" and "physics" are words in the tagline or a sub-string of a word in the tagline. Two possible results are the following:

    TAGS : Physics Forums science discussions
    URL  : http://physicsforums.com/
    
    TAGS : Physics for kids
    URL  : http://somedoamin.com/

The reason the two above match is because the word "physics" appears in both taglines, "for" appears in the second tagline as a complete word and as a substring in the first tagline. The following example doesn't match: 

    TAGS : Cat forums for cat lovers
    URL  : http://catscatscatscatscats.com/

Although "for" is a sub-string of "forums", the string "physics" doesn't appear in the tagline.


## Using marks

As noted elsewhere, marks is an official client for the bookie service. In general, marks tries to automate tasks for you and be smart about what you're going to need. However, it isn't forceful and is very forgiving. marks doesn't assert any direction for how you use your content or what your content is. It tries to work for you.


As a starter, when you run marks for the first time without any arguments, it immediately displays a help text:

    $ marks
    Usage: marks [action] [args...]
           marks [label]
    
    Action Details:
      add      (a)   [url]  [tagline]   Add an entry
      append   (aa)  [url]  [tagline]   Append tags to the end of the tagline
      delete   (d)   [url]              Delete an entry
      search   (s)   [url]  [tags]      Search url and tags
      tag      (t)   [tags]             Search taglines for the given tags
      url      (u)   [url]              Search url
      ls                                List all entries
      keys                              List all keys
      key                               Sub menu for managing keys
      raw                               Output raw database dump
      check                             Check for dead URLs and other issues
      ingest         [filename]         Import a bookie backup file
      import         [filename]         Import Netscape bookmark file
      kill kill kill                    Wipe out all your data from the cloud
      help   (?)                        Display this

### Adding, Appending & Deleting Bookmarks

You can immediately start adding bookmarks and they will go up into the bookie cloud.

    $ marks add https://github.com/FragmentedCurve/py-marks Bookie power user client marks python pymarks

This will immediately go up into the cloud using a key that marks has automatically generated behind the scenes. You'll read about keys later. There are some things to note about adding a bookmark entry. In your shell, all of these are equivalent:

    $ marks add https://github.com/FragmentedCurve/py-marks Bookie power user client marks python pymarks
    $ marks add https://github.com/FragmentedCurve/py-marks "Bookie power user client marks python pymarks"
    $ marks a https://github.com/FragmentedCurve/py-marks "Bookie power user" client marks python pymarks

Throughout all of marks' features, you don't need to provide a tagline as a single shell argument. marks will assemble all of the arguments after the URL into the tagline. Most commands in marks have short-hands, especially the commonly used ones. Therefore, you may always replace `add` with `a`.

We can list all the entries we have in our bookie database by doing,

    $ marks ls
    TAGS :  Bookie power user client marks python pymarks
    URL  :  https://github.com/FragmentedCurve/py-marks

Let's say we don't like our tagline because we consider the phrase "power user" and "pymarks" unessacary. We can easily replace the entire tagline by using the *add* command again.

    $ marks a https://github.com/FragmentedCurve/py-marks Bookie client marks python
	$ marks ls
    TAGS :  Bookie client marks python
    URL  :  https://github.com/FragmentedCurve/py-marks

We forgot to add "bookmark manager" to our tagline. Instead of replacing the entire tagline by typing it out again, we can use the append command.

    $ marks append https://github.com/FragmentedCurve/py-marks bookmark manager

And for the sake of emphasis, the following are equivalent:

    $ marks aa https://github.com/FragmentedCurve/py-marks bookmark manager
	$ marks aa https://github.com/FragmentedCurve/py-marks "bookmark manager"
	$ marks append https://github.com/FragmentedCurve/py-marks "bookmark manager"

Deleting a bookmark is straightfoward. Simply give the delete command a URL. However, the URL must be exactly how it appears in bookie. For example, if we do the following

	$ marks add https://github.com Source code hosting
	$ marks ls
	TAGS : Source code hosting
	URL  : https://github.com/
	
bookie appends a trailing slash in an attempt to normalize the URL. Therefore we must supply marks with the exact URL.

    $ marks delete https://github.com/


### Searching

Searching is slightly more involved than adding and deleting bookmarks, but not by much. There are three commands to search for bookmarks in marks: `search`, `tag`, and `url`. The commands `tag` and `url` are used for only searching the tagline and URL respectively; *search* returns entries that match both the URL and tagline.

For this section, let's assume we have the following entries in our bookie cloud:

    $ marks ls
    TAGS :  American Mathematical Society Homepage
    URL  :  http://www.ams.org/
    
    TAGS :  Brilliant - Challenging math problems and physics problems
    URL  :  https://brilliant.org/
    
    TAGS :  Google Search Engine
    URL  :  https://google.com/
    
    TAGS :  DuckDuckGo Privacy Search Engine [No targeted ads]
    URL  :  https://duckduckgo.com/
    
    TAGS :  StartPage Search Engine Privacy [Uses google results]
    URL  :  https://startpage.com/

When searching, the behavior of marks will change depending on whether there is more than one result or not. If only one result is found, marks will automatically copy the URL to your operating system's clipboard and open it in your default browser. For example,

    $ marks tag physics
    TAGS :  Brilliant - Challenging math problems and physics problems
    URL  :  https://brilliant.org/

will be printed and "https://brilliant.org/" will be opened in the browser and copied to the clipboard. On some platforms, marks may not be able to open a browser or use the clipboard. In such situations, you we at least get the output in the terminal. 


When there's more than one result, a sub-shell prompt is given.

    $ marks t math
    0 ) TAGS : American Mathematical Society Homepage
    0 ) URL  : http://www.ams.org/
    
    1 ) TAGS : Brilliant - Challenging math problems and physics problems
    1 ) URL  : https://brilliant.org/
    
    #


## Keys

You don't have to ask marks to show help. In addition to this, marks will automatically generate a key for you in the background. If you run `marks keys`, you'll see output similar to the following:

    $ marks keys
    > XTO5ERqIOKyn784m4EQ5wswnZ7vjjLM97BsZIYeejkVKVt9BpXVOy0LxAOEzihGa12PII default

There are three pieces of information here:

  1. The `>` character informs you what key marks is set to use.
  2. This is following by a string which is the key. In this case: `XTO5ERqIOKyn784m4EQ5wswnZ7vjjLM97BsZIYeejkVKVt9BpXVOy0LxAOEzihGa12PII`
  3. Lastly, the word `default` is a friendly label for the key.

A label can consist of only letters and numbers. You need to protect your key and keep it safe. It's how you access your data and sync up your computers. You may have noticed already that there is an argument called `key` in addition to `keys`. If we run this argument, we're given a sub-menu.

    $ marks key
    Usage: marks key [action] [args...]
    Details:
      add         [label] [key]             Add a key with a label
      use    (s)  [label]                   Switch the default key
      copy   (c)  [src label] [dest label]  Copy the key from one label to another label
      delete (d)  [label]                   Delete a key with the given label
      list   (ls)                           List all keys and labels
      show                                  Show the default key
      help   (?)                            Display this

In general, you don't want to spend much time with these commands. They're only purpose is to manage your keys on the local machine. If you want to have more than one key, you can easily do this by using the `marks key add` command. Both the label and key parameters are optional. **You can easily lose your current key by not using the label parameter.** Doing the following,

    $ marks key add

will generate a new key and **overwrite** an existing key with the label `default`. You have been warned. When making a new key, it's recommended to always supply a label and rarely supply a key.

    $ marks key add test
    $ marks keys
    > XTO5ERqIOKyn784m4EQ5wswnZ7vjjLM97BsZIYeejkVKVt9BpXVOy0LxAOEzihGa12PII default
      DxqQhJaSYUZJVAnh1TeWGGQBwExCQPzOJdU86APg1y976LqfsCr1ELqeXDuJ6PCVyerJQ test

Using the optional key parameter is useful when you want to use marks on another computer. You can easily import a key from one computer to another: `marks key add fromdestkop DxqQhJaSYUZJVAnh1TeWGGQBwExCQPzOJdU86APg1y976LqfsCr1ELqeXDuJ6PCVyerJQ`


Now we're going to want to use our key labeled `test`. Again, this is a place where marks tries to make this simple. If the first argument given to marks isn't an action command, marks will check if its a label and set that label's key to be used.

    $ marks test
    $ marks keys
      XTO5ERqIOKyn784m4EQ5wswnZ7vjjLM97BsZIYeejkVKVt9BpXVOy0LxAOEzihGa12PII default
    > DxqQhJaSYUZJVAnh1TeWGGQBwExCQPzOJdU86APg1y976LqfsCr1ELqeXDuJ6PCVyerJQ test

Notice how the arrow has switched to the `test` key, indictating that any requests we make to the bookie service will be done with this key. You might be wondering: what do I do if I labeled my key with a marks command? For example: `marks key add key`. This would create a new key with the label `key`. You may use `marks key use` to switch your current key.

    $ marks key add key
    $ marks keys
      XTO5ERqIOKyn784m4EQ5wswnZ7vjjLM97BsZIYeejkVKVt9BpXVOy0LxAOEzihGa12PII default
    > DxqQhJaSYUZJVAnh1TeWGGQBwExCQPzOJdU86APg1y976LqfsCr1ELqeXDuJ6PCVyerJQ test
      dJsfguGjxDCWjll7fo0oqwwCCr72cheQdMFlpxXruhxcAxu4bIVNdvRcVlflrjjzWMtel key
    $ marks key use key
    $ marks keys
      XTO5ERqIOKyn784m4EQ5wswnZ7vjjLM97BsZIYeejkVKVt9BpXVOy0LxAOEzihGa12PII default
      DxqQhJaSYUZJVAnh1TeWGGQBwExCQPzOJdU86APg1y976LqfsCr1ELqeXDuJ6PCVyerJQ test
    > dJsfguGjxDCWjll7fo0oqwwCCr72cheQdMFlpxXruhxcAxu4bIVNdvRcVlflrjjzWMtel key

Let's relabel this key to `tutorial` by using the copy and delete commands.

    $ marks key copy key tutorial
    $ marks key delete key
    ERROR: You can't delete the key that's currently in use. Switch keys before deleting.
    $ marks tutorial
    $ marks keys
      XTO5ERqIOKyn784m4EQ5wswnZ7vjjLM97BsZIYeejkVKVt9BpXVOy0LxAOEzihGa12PII default
      DxqQhJaSYUZJVAnh1TeWGGQBwExCQPzOJdU86APg1y976LqfsCr1ELqeXDuJ6PCVyerJQ test
      dJsfguGjxDCWjll7fo0oqwwCCr72cheQdMFlpxXruhxcAxu4bIVNdvRcVlflrjjzWMtel key
    > dJsfguGjxDCWjll7fo0oqwwCCr72cheQdMFlpxXruhxcAxu4bIVNdvRcVlflrjjzWMtel tutorial
    $ marks key delete key
    $ marks keys
      XTO5ERqIOKyn784m4EQ5wswnZ7vjjLM97BsZIYeejkVKVt9BpXVOy0LxAOEzihGa12PII default
      DxqQhJaSYUZJVAnh1TeWGGQBwExCQPzOJdU86APg1y976LqfsCr1ELqeXDuJ6PCVyerJQ test
    > dJsfguGjxDCWjll7fo0oqwwCCr72cheQdMFlpxXruhxcAxu4bIVNdvRcVlflrjjzWMtel tutorial
