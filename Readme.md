# Domino ODP Repository Helper (dora)

Dora is a helper script with the intention of providing some automation for some common tasks involved in setting up a git repository

* 	Initialising a new repository for NSF use
*		Setting the .gitignore file consistently
* 	Installing DXL Metadata filters for better source control
* 	Keeping a Custom Control updated with the latest version

This project is only in it's beginning. Currently dora is implemented as a Perl script (dora.pl) which runs in the bash-like *Git Bash* on Windows.

*note* If you don't want to use dora and just want to manually configure the Git Metadata filters yourself please see the **Manually Configuring Git Filters** section below.

## Usage

To use dora, you open a terminal, navigate to a git repository's root directory and issue the command *dora*
This will open a menu in the terminal which will allow you to configure the current repository using dora.

### Setting up DXL Metadata Filters

To set up the DXL Metadata filters, open a terminal, navigate to the repository, and run 'dora'
Then choose the menu option for 'Installation'
Then choose the option 'Install Everything'

If you encounter any issues (please report them!) you can set up the DXL Metadata filters manually using the following guide.

#### Manually Configuring the DXL Metadata Filters 

If you cannot configure the filters due to any problems when running the Dora Helper script (please report bugs!), you can still manually configure your repository to run the DXL Metadata Filter

1. 	(windows only) Install libxslt to a directory that is on your PATH
1.  Install the DXL Metadata filter to the git config file

You can do this either by issuing git config commands or by editing the .git/config file in your repository.
To do this using git config commands run the following:

    git config --local filter.dxlmetadata.clean    xsltproc xsl\DXLClean.xsl -
    git config --local filter.dxlmetadata.smudge   xsltproc xsl\DXLSmudge.xsl - 
    git config --local filter.dxlmetadata.required true

To do this via editing the .git/config file, make sure it has this entry

    [filter "dxlmetadata"]
      clean = xsltproc xsl/DXLClean.xsl -
      smudge = xsltproc xsl/DXLSmudge.xsl -
      required = true

2. Create a directory called *xsl* within your repository for your XSL Stylesheets
2. Copy the XSL Transform Stylesheets DXLClean.xsl and DXLSmudge.xsl to the newly created xsl directory
2. Add the entry *xsl/* to your .gitignore file

4. Configure the .gitattributes file to select which files to filter
4. If you don't have one, Create a *.gitattributes* file in the root of your repository
4. add the following entry for each file extension you want to filter
\*.ext filter=dxlmetadata text eol=lf

## Installation

To install Dora, the first step is to obtain the latest release. You can do this 3 ways:

* Download the latest release from camac/dora project on github.com
* Download the latest release from the releases section in the OpenNTF Project
* Clone the repository from https://github.com/camac/dora.git and checkout the master branch

The installation process just copies the required executables and resources to 2 directories in your home directory. I will use the symbol ~ to refer to the home dir

Target Executables directory : ~/bin
Target Resources directory   : ~/dora

The reason that ~/bin was chosen is that it is already included on the PATH environment variable when using Git Bash. This means that executables placed in this directory can be run from any other location.

Executables that are copied

  - dora.pl (The Dora Helper Script) copied as dora
  - libxslt win 32 Binaries (windows only)

Resources
  - XSL files used in DXL Metadata filter

### Windows + Git Bash / Git Gui

Open Git Bash, Navigate to the unzipped dora release (or the cloned camac/dora.git repository) and run ./Install.pl
Follow the prompts

### Windows using SourceTree

When using Sourcetree, these instructions assume you have enabled the setting:

Tools -> Options -> Git -> 'Use Git Bash as Terminal'

Open the terminal using the Terminal Icon in the SourceTree 'ribbon' menu. You will need to have a repository open (any will do) to access the terminal.
Once in the terminal, navigate to wherever you unzipped the release of Dora.

Then issued the command ./Install.pl

*IMPORTANT* For the DXL Metadata filters to work using sourcetree, you must add the Dora Executables directory to the Windows PATH environment variable, otherwise SourceTree will not be able to run xsltproc and will fail.
 
### Mac

Open a terminal, navigate to the directory that you unzipped the Dora release to, and run ./Install.pl
Follow the prompts
libxslt is already installed on a Mac, so installing these binaries is not required. 
The Installation script should detect that you are using Mac, and skip that step for you.
If you find that the Install.pl script does not detect the mac properly, then run the install script with the option *--os-mac*

### Manual Installation

If the *Install.pl* script fails for any reason (please report bugs!) you can still install manually 

1. Create 2 directories in your home directory
* ~/bin
* ~/dora
2. Copy the dora.pl file to ~/bin/dora (no extension)
2. (For windows only) Copy the libxslt binaries from within directories under libxslt/ to ~/bin
2. Copy the XSL Files from xsl/ to ~/dora

## Requirements

This project has been tested using Windows 7 64-bit and Windows 8 64-bit.
To git Git for windows goto 
http://git-scm.com/download/win

When you are given the choice of which command line method choose 'Use Git Bash Only'

using Git Bash v 1.8.1.2-preview20130201
Perl (tested with 5.8.8 which is bundled in Git Bash)

## Contributing

Contributions can be made in varying forms. You can give feedback, opinions, bug reports, feature requests or even make coding contributions by forking the project and then submitting pull requests.

### Evaluating the Correctness/Effectiveness of DXLClean.xsl 

The DXLClean.xsl file is the *recipe* for choosing which elements and attributes we want to filter from the DXL.
The version of DXLClean.xsl included in this repository is only a result of what I (Cameron Gregor) have been using so far, and not necessarily a proclamation of what is a good idea by many.

One of the outcomes I am hoping to get from collaboration, is an agreed *safe version* of DXLClean.xsl that is considered safe to recommend to people. Riskier options for this filtering may then be provided in a separate optional xsl, or contained within the same \*.xsl file, and activated by parameters.

So, I would really appreciate feedback on the contents of DXLClean.xsl, and whether you think that it needs some modification. 

To help inform your decision, you can read through the Domino DTD (search from Designer Help for 'DTD') which theoretically documents the possible elements and attributes and whether or not they are optional (implied which is denoted by a Question Mark ?)

Also if you have not done XPath or XSLT before or need a refresher, the tutorials at www.w3schools.com were helpful to me, and may be of use to you too.

### Reporting Bugs

Please report bugs through [Dora's OpenNTF project page](http://www.openntf.org/internal/home.nsf/project.xsp?action=openDocument&name=Dora) 'Defects' page.

### Feature Requests

Feature requests can be made through [Dora's OpenNTF project page](http://www.openntf.org/internal/home.nsf/project.xsp?action=openDocument&name=Dora) 'Feature Requests' page.Please feel free to fork this project and have a go at any new features yourself! 

## Testing

### Testing an XSL Transformation Stylesheet

To test an XSL Transformation Stylesheet, you will 2 files, the source xml file that you want to manipulate, and the xsl file that contains the instructions for the transformation.
You then use the xsltproc program from a terminal as follows:

xsltproc.exe <xslfile> <sourcexml>

This will output the resulting xml to the terminal.

If you would like to capture the output in a file instead, you can use the *-o* option like so

xsltproc.exe -o <outputfile> <xslfile> <sourcexml>

For a full list of parameters for xsltproc.exe just run xsltproc.exe with no parameters.

## Licence

See LICENCE file

This project contains a set of git filters and scripts which assist when collaborating on a Domino Project.

The set up information describes how to install and use them when using Git Bash which is the linux-like command prompt tool for using git under windows.

Installation
------------------


GitHub for Windows
  - Git Version 1.8.1.msysgit.1
  - Perl Version v5.8.8 built for msys

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

