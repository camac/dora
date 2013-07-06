Domino ODP Repository Helper (dora)
===================================

Dora is a helper script with the intention of providing some automation for some common tasks involved in setting up a git repository

* 	Initialising a new repository for NSF use
*		Setting the .gitignore file consistently
* 	Installing metadata filters for better source control
* 	Temporarily ignore some configuration files

and more!


This project is only in it's beginning. Currently dora is implemented as a Perl script (dora.pl) which runs in the linux-like *Git Bash* on Windows.

*note* If you don't want to use dora and just want to manually configure the Git Metadata filters yourself please see the **Manually Configuring Git Filters** section below.

System Requirements
-------------------

This project has been tested using Windows 7 64-bit and Windows 8 64-bit.
To git Git for windows goto 
http://git-scm.com/download/win

When you are given the choice of which command line method choose 'Use Git Bash Only'

using Git Bash v 1.8.1.2-preview20130201
Perl (tested with 5.8.8 which is bundled in Git Bash)


Git Filter
----------


Testing scripts

App Version Sync
----------------

New Repo Setup
--------------

This project contains a set of git filters and scripts which assist when collaborating on a Domino Project.

The set up information describes how to install and use them when using Git Bash which is the linux-like command prompt tool for using git under windows.

Installation
------------------

This project has been tested using the following setup

GitHub for Windows
  - Git Version 1.8.1.msysgit.1
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

Feature Requests
----------------

* Install xsl files as tagged blobs in the git repo, instead of committed to a branch
* Better identification of which version of filter was used on a file
* Ability to choose where to install binaries and dora resources

Other Ideas
-----------

* Tell Domino Designer team to give us the option to filter this stuff for us so we don't have to :)
* Update EGit to replicate Filter functionality 
* Somebody with Java and Domino Designer Extension plugin experience could investigate if you can extend NsfToPhysical and filter at this point?
* re-write Dora as a Domino Designer Plugin instead of a Perl Script, with Eclipse based User Interface
* Helper functionality to do bulk updates on design elements, e.g. Make sure all view Column Headers are certain font.

Known Issues
------------

Git Filter reports an error if the file is empty
Git Filter reports an error if the source is not well formed xml. This happens during a merge conflict.

if file is empty then will fail e.g.
nsf/AppProperties/database.properties
nsf/Code/dbscript.lsdb
nsf/Resources/AboutDocument

Forms, System Actions showed up

DXL Notes

Frameset frame got a new Border style
Forms don't like it when Background element has a text node these need to be deflated
Forms without action bar get a default set of system actions


Manually Configuring the Git Filter
-----------------------------------

1. 	Install libxslt on your PATH
2.	Copy the XSL Transform Stylesheets (modify if necessary)
3. 	Install the Filter to git config
4. 	Configure the .gitattributes file to select which files to filter



