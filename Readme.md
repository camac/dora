# Domino ODP Repository Helper (dora)

Dora's primary purpose is to assist in setting up **DXL Metadata filters** for a Git Repository for an IBM Notes/Domino nsf On-Disk Project.

This project is only in it's beginning. Currently dora is implemented as a Perl script which runs in a bash-like terminal e.g. *Git Bash* on Windows.

*note* You can set up DXL Metadata filters manually, so if you don't want to use dora and just want to manually configure the Git Metadata filters yourself please see the [Manually Configuring the DXL Metadata Filters](#manually-configuring-the-dxl-metadata-filters) section below.

## Usage

To use dora, you must first install it. Then you open a terminal, navigate to a git repository's root directory and issue the command `dora`
This will open a menu in the terminal which will allow you to configure the current repository for DXL Metadata filters.

### Setting up DXL Metadata Filters

To set up the DXL Metadata filters for a repository:

1. open a bash-like terminal
2. navigate to the repository
3. run `dora`
4. Choose 1. for 'Install Something'
5. Choose 1. for 'Install Everything'
6. Follow the prompts!

If you encounter any issues (please report them!) you can set up the DXL Metadata filters manually using the following guide.

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
  - \*.xsl files used in DXL Metadata filter

### Windows + Git Bash / Git Gui

Open Git Bash, Navigate to the unzipped dora release (or the cloned camac/dora.git repository) and run ./Install.pl
Follow the prompts

### Windows using SourceTree

When using Sourcetree, these instructions assume you have enabled the setting:

Tools -> Options -> Git -> 'Use Git Bash as Terminal'

Open the terminal using the Terminal Icon in the SourceTree 'ribbon' menu. You will need to have a repository open (any will do) to access the terminal.
Once in the terminal, navigate to wherever you unzipped the release of Dora.

Then issued the command ./Install.pl

### Mac

Open a terminal, navigate to the directory that you unzipped the Dora release to, and run ./Install.pl
Follow the prompts
libxslt is already installed on a Mac, so installing these binaries is not required. 
The Installation script should detect that you are using Mac, and skip that step for you.
If you find that the Install.pl script does not detect the mac properly, then run the install script with the option *--os-mac*

## Requirements

To use dora you must have

This project has been tested using Windows 7 64-bit and Windows 8 64-bit.
To git Git for windows goto 
http://git-scm.com/download/win

When you are given the choice of which command line method choose 'Use Git Bash Only'

using Git Bash v 1.8.1.2-preview20130201
Perl (tested with 5.8.8 which is bundled in Git Bash)
  - Git Version 1.8.1.msysgit.1
  - Perl Version v5.8.8 built for msys


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
As usual, the more info the better.

### Feature Requests

Feature requests can be made through [Dora's OpenNTF project page](http://www.openntf.org/internal/home.nsf/project.xsp?action=openDocument&name=Dora) 'Feature Requests' page.Please feel free to fork this project and have a go at any new features yourself! 

## Testing

To test the DXL Metadata filters are working 
#TODO Finish this

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

## Manual Installation

### Manual Installation of Dora

If the *Install.pl* script fails for any reason (please report bugs!) you can still install Dora manually 

1.  Create 2 directories in your home directory
    * ~/bin
    * ~/dora
2.  Copy the dora.pl file to ~/bin/dora (no .pl extension)
3.  (For windows only) Copy the libxslt binaries from within directories under libxslt/ to ~/bin
4.  Copy the XSL Files from xsl/ to ~/dora

### Installing libxslt from Original project

To run the DXL Metadata filters you need to have libxslt installed. If you are on a mac, libxslt should already be installed. If you are running windows, Dora will install these necessary files for you, however if you would like to install it manually yourself, follow these steps.

[libxslt](http://xmlsoft.org/XSLT/) is the XSLT C library developed for the GNOME project. If you go to the downloads section of the project page, you can find a link to the Windows versions, which are currently maintained by Igor Zlatkovic.

1.  Download the necessary files from Igor's [download area](ftp://ftp.zlatkovic.com/libxml/). If you read the [documentation](http://www.zlatkovic.com/libxml.en.html)
 it will tell you that to use libxslt you need to download the following packages:
    * iconv
    * libxml2
    * libxslt
    * zlib
2.  Extract the contents of the downloaded files
3.  Make a directory called *bin* in your HOME directory
    e,g. C:\Users\Cameron\*bin*
4.  Copy the contents of each of the download's *bin* directories to your HOME\bin directory 
    For example, at the time of writing this, the contents I needed to copy were:
    * iconv.dll
    * iconv.exe
    * libexslt.dll
    * libxml2.dll
    * libxslt.dll
    * minigzip.exe
    * xmlcatalog.exe
    * xmllint.exe
    * xsltproc.exe
    * zlib1.dll

<a id="manualDXL"></a>
### Manually Configuring the DXL Metadata Filters 

If you cannot configure the filters for a repository due to any problems when running the Dora Helper script (please report bugs!), you can still manually configure your repository to run the DXL Metadata Filters.

1. 	(windows only) Make sure libxslt binaries are installed to a directory that is on your PATH environment variable
    See the section below on manually installed libxslt binaries.
2.  Install the DXL Metadata filter to the git config file
    You can do this either by issuing git config commands or by editing the .git/config file in your repository.
    To do this using git config commands run the following:

        git config --local filter.dxlmetadata.clean    xsltproc xsl\DXLClean.xsl -
        git config --local filter.dxlmetadata.smudge   xsltproc xsl\DXLSmudge.xsl - 
        git config --local filter.dxlmetadata.required true

    or to do this via editing the .git/config file, make sure it has this section

        [filter "dxlmetadata"]
          clean = xsltproc xsl/DXLClean.xsl -
          smudge = xsltproc xsl/DXLSmudge.xsl -
          required = true

3.  Create a directory called *xsl* within your repository for your XSL Stylesheets
4.  Copy the XSL Transform Stylesheets DXLClean.xsl and DXLSmudge.xsl to the newly created xsl directory
5.  Add the entry *xsl/* to your .gitignore file
6.  Configure the .gitattributes file to select which files to filter
    If you don't have one, Create a *.gitattributes* file in the root of your repository
    add the following entry for each file extension you want to filter
        *.<ext> filter=dxlmetadata text eol=lf
    Here is some entries you can use as a starting point
        *.aa filter=dxlmetadata text eol=lf
        *.column filter=dxlmetadata text eol=lf
        *.dcr filter=dxlmetadata text eol=lf
        *.fa filter=dxlmetadata text eol=lf
        *.field filter=dxlmetadata text eol=lf
        *.folder filter=dxlmetadata text eol=lf
        *.form filter=dxlmetadata text eol=lf
        *.frameset filter=dxlmetadata text eol=lf
        *.ija filter=dxlmetadata text eol=lf
        *.ja filter=dxlmetadata text eol=lf
        *.javalib filter=dxlmetadata text eol=lf
        *.lsa filter=dxlmetadata text eol=lf
        *.lsdb filter=dxlmetadata text eol=lf
        *.metadata filter=dxlmetadata text eol=lf
        *.navigator filter=dxlmetadata text eol=lf
        *.outline filter=dxlmetadata text eol=lf
        *.page filter=dxlmetadata text eol=lf
        *.subform filter=dxlmetadata text eol=lf
        *.view filter=dxlmetadata text eol=lf
        AboutDocument filter=dxlmetadata text eol=lf
        database.properties filter=dxlmetadata text eol=lf
        IconNote filter=dxlmetadata text eol=lf
        Shared?Actions filter=dxlmetadata text eol=lf
        UsingDocument filter=dxlmetadata text eol=lf


## Ideas for future

* Tell Domino Designer team to give us the option to filter this stuff for us so we don't have to :)
* Update EGit to replicate Filter functionality 
* Somebody with Java and Domino Designer Extension plugin experience could investigate if you can extend NsfToPhysical and filter at this point?
* re-write Dora as a Domino Designer Plugin instead of a Perl Script, with Eclipse based User Interface
* Helper functionality to do bulk updates on design elements, e.g. Make sure all view Column Headers are certain font.
* Install xsl files as tagged blobs in the git repo, instead of committed to a branch
* Better identification of which version of filter was used on a file
* Ability to choose where to install binaries and dora resources


## Known Issues

*   DXL Metadata filter throws an error if the source is not well formed xml. This happens during a merge conflict.
*   DXL Metadata filter throws an error if file is empty then will fail e.g.
    * nsf/AppProperties/database.properties
    * nsf/Code/dbscript.lsdb
    * nsf/Resources/AboutDocument
    Are all blank when you create a new nsf and will fail until you save them first.

## DXL Notes

* Frameset frame got a new Border style 
* Forms don't like it when Background element has a text node, these need to be deflated
* Forms without action bar get a default set of system actions

