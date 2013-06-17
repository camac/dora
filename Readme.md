Git NSF ODP Helper
===================

This project contains a set of git filters and scripts which assist when collaborating on a Domino Project.

The set up information describes how to install and use them when using Git Bash which is the linux-like command prompt tool for using git under windows.

I have yet to test for eGit for Domino Designer however I don't see a reason why it won't work for that too, as the setup is based on git config and native git functionality.

* How to hide any updates from Git Status which are Meta Information only
* How to deal with Merge Conflict
* Remove the noteinfo element
* Remove the replicaid attribute from the note element
* Remove the version attribute from the note element
* Diff filter to ignore NoteInfo and check in standard values for 
* Clean Filter for checking in values
  * Sequence Number
  * Replica ID
  * Signer
  * Modified Dates etc
* Smudge Filter for Checking out
  * Sequence Number
  * Replica ID
  * Signer
  * Modified Dates etc


i need a program to
Take Standard Input
Replace anything that is ReplicaID="" with "##REPLICAID##"

and vice versa
Replace anything that in ReplicaID="##REPLICAID##" with the contents of the blob tag NSFREPLICA


Installation
------------------

This project has been tested using the following setup

GitHub for Windows
  - Git Version 1.8.1.msysgit.1
  - Java version ???
  - Perl Version v5.8.8 built for msys

Step 1 - Choose where you will keep the scripts

Your options here are
  * Install in the GitNSFFilters folder in your HOME directory e.g ~/GitNSFFilters (Default option)
  * Install in another folder of your choosing and:
      * Specify that folders location when you configure Git Filters for your repository
      * Add that folder to your PATH environment variable 

The default location to install the scripts is a folder called 'GitNSFFilters' in your home directory. 
To find your home directory run 
$ cd ~
/c/Users/cgregor
git clone https://github.com/camac/GitNSFFilters


Here is a Testing Script for Demonstration purposes

User 1
1. Create a new NSF File -> New Application
1. Team -> Set up Source Control and create new ODP
1. Add some Folders, views, script libraries etc
1. git init
1. Configure git repo for GitFiltersForNSF
1. git add .
1. git commit -m "First Commit"
1. git push origin master

User 2
1. git clone <remote-repo-location>
1. Open Java Perspective
1. Import -> Existing Project
1. Team -> Create new nsf
1. Tools -> Recompile all lotusscript
1. Open a view and save
1. git status
1. git add .
1. git status


Running Tests
----------------

To view an example of what happens using certain filters you can run a test like so

xsltproc stylesheet file

so to run the form.xsl filter 

xsltproc xsl/form.xsl testdata/Form/Form.view

When installed, the actual filter will have a hyphen for the filename. The hyphen tells the xsltproc program to use <<stdin>>
xsltproc xsl/form.xsl -


Vim Tip
when viewing an xml file that does not have the extension .xml, you can use
:set filetype=xml
and it will do pretty xml colours!



Installing XSLTPROC
-------------------

http://www.zlatkovic.com/libxml.en.html

Read his documentation

Download:

iconv
libxml2
libxslt
zlib

I am running Windows 8 64-bit, and downloaded the 32-bit versions because Git Bash runs as 32-bit 

iconv-1.9.2.win32
libxml2-2.7.8.win32
libxslt-1.1.26.win32
zlib-1.2.5.win32

Check your path, there should be an entry on there for your home dir + bin
echo $PATH

Make a directory called bin in your home directory
e.g.
C:\Users\Cameron\bin

Extract all the zip files, and then go into each one and copy the files from the bin dirs to your home\bin 

iconv.dll
iconv.exe
libexslt.dll
libxml2.dll
libxslt.dll
minigzip.exe
xmlcatalog.exe
xmllint.exe
xsltproc.exe
zlib1.dll



Setting up first NSF
--------------------
For example setting up a Teamroom


Create a folder named after the Application
Teamroom

Create a sub folder called nsf
Teamroom\nsf

Create the gitignore file
Teamroom\.gitignore

Create a directory for the xsl file
Teamroom\xsl

Copy the XSL file into the directory  
Teamroom\xsl\transform.xsl

Add the Filter to Git Config

Add the .gitattributes file

Set core.autocrlf = false
git config core.autocrlf falseo

Cloning from Remote NSF
-----------------------
Go to your Workspace

git clone <repo> <directory>
run dogh.pl and make sure Filters are installed into git Config!!

Go to Domino Designer on Eclipse
Switch Perspective to 'Java'

File - > New -> Project
Choose General -> Project
  - Enter your Project Name 'Teamroom'
  - deselect 'Use default location'
  - Browse to the NSF folder that is within the newly cloned repository
  - Do not add a related project

Then switch back to Domino Designer perspective
Window -> Show Eclipse View -> Navigator

Find your new project 'Teamroom'
Right-click and choose
  - Team Development -> Associate with New NSF
Choose where you will put your new nsf

Wait for it to import!





Notes
-----

if file is empty then will fail e.g.
nsf/AppProperties/database.properties
nsf/Code/dbscript.lsdb
nsf/Resources/AboutDocument


git update-index --assume-unchanged nsf/AppProperties/database.properties
git update-index --assume-unchanged nsf/Resources/IconNote

git update-index --no-assume-unchanged nsf/AppProperties/database.properties
git update-index --no-assume-unchanged nsf/Resources/IconNote


Forms, System Actions showed up

Filters fail in the merge conflict ...
