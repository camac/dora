#!/bin/perl
#
# Installation Script for GitNsfFilters
#
# Copies the GNF script to the ~/bin directory
# Copies the XSL file to the ~/GitFilter/xsl directory

use strict;

package GitFiltersForNSF;

use File::Basename;

our $projname   = "Git Filters For NSF";

our $useColours = 0;
our $verbose    = 0;

our $installScriptDir     = dirname(__FILE__);
our $homeDir              = $ENV{"HOME"};

our $setupSourceFilename  = "Setup.pl";
our $setupSource          = "$installScriptDir/$setupSourceFilename";

our $setupTargetDirectory = "$homeDir/bin";
our $setupTargetFilename  = "Setup.pl";
our $setupTarget          = "$setupTargetDirectory/$setupTargetFilename";

our $xslSourceFilename    = "../xsl/transform.xsl";
our $xslSource            = "$installScriptDir/$xslSourceFilename";

our $xslTargetDirectory  = "$homeDir/GitFilters";
our $xslTargetFilename   = "NonBinaryDxl.xsl";
our $xslTarget           = "$xslTargetDirectory/$xslTargetFilename";

processArgs();
main();

installNSFRepoScript();
installXSL();

sub main {

  mycls();

  print "=======================================\n";
  print "$projname Installation\n\n";

  print "Current Status:\n\n";

  print "NSF Repo Setup ...";
  print "Installed at location\n";
  print "XSL Stylesheet ...";
  print "Installed at location\n";

  print "\nChoose a Menu Option\n\n";


  print "1. Install\n";
  print "2. Uninstall\n";

  print "\n\nEnter Menu Option: ";

  my $opt = <>;

  chomp($opt);

  if ($opt eq "1") {
    install();
  } elsif ($opt eq "2") {
    uninstall();
  }

  exit 0;

}

sub install() {
  installNSFRepoScript();
  installXSL();
}


sub installNSFRepoScript {

  if (-e $setupTarget) {
    print "NSF Repo Setup script is already installed\n";
  } else {
    print "NSF Repo Setup script will be installed\n";

    # Check if the Home Bin directory exists
    if (-d $setupTargetDirectory) {
      print "...Target \$HOME/bin directory already exists\n";
    } else {
      mkdir $setupTargetDirectory;
      print "...Created Directory: $setupTargetDirectory\n";      
    }

    # Copy the Setup script to the Target Directory
    use File::Copy;
    copy($setupSource, $setupTarget) or die "...Failed Copying: $!\n";
    print "...Installed NSF Repo Setup Script to $setupTarget\n";

  }

}


sub installXSL {

  if (-e $xslTarget) {
    print "XSL File is already installed\n";
  } else {
    print "XSL File will be installed\n";

    # Check if the Home Bin directory exists
    if (-d $xslTargetDirectory) {
      print "...XSL directory $xslTargetDirectory already exists\n";
    } else {
      mkdir $xslTargetDirectory;
      print "...Created Directory for XSL: $xslTargetDirectory\n";
    }

    # Copy the xsl file to the Target Directory
    use File::Copy;

    copy($xslSource, $xslTarget) or die "Failed Copying: $!\n";
    print "...Installed XSL to $xslTarget\n";

  }

  print "\n";

}

sub checkXsltproc {
  
  #TODO implement inspection of xslt environment


}

sub uninstall() {

  print "\nPerforming uninstall of $projname\n\n";

  print "Attempt to remove nsfrepo script ... ";
  if (-e $setupTarget) {
    unlink $setupTarget or warn "Could not remove $setupTarget: $!\n";
    print " uninstalled.\n";
  } else {
    print " already uninstalled, no action taken\n";
  }

  print "Attempt to remove xsl script     ... ";  
  if (-e $xslTarget) {
    unlink $xslTarget or warn "Could not remove $xslTarget: $!\n";
    print " uninstalled.\n";
  } else {
    print " already uninstalled, no action taken\n";
  }

  print "\n";

}

sub processArgs {

  my $numArgs = $#ARGV + 1;

  foreach my $argnum (0 .. $#ARGV) {

    if ($ARGV[$argnum] eq '--no-color') {
      $useColours = 0;
    }

    if ($ARGV[$argnum] eq '--remove') {
      uninstall();
      exit 0;
    }

    if ($ARGV[$argnum] eq '-v') {
      $verbose = 1;
    }

    print "$ARGV[$argnum]\n";
  }

}

sub mycls {
  system("clear");  
}
