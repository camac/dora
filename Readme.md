Git Filters for NSF
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

