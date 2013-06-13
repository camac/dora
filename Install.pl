#!/bin/perl
#
# Installation Script for GitNsfFilters
#
# Copies the GNF script to the ~/bin directory
# Copies the XSL file to the ~/GitFilter/xsl directory
# TODO Use FTP to download latest libxslt
# TODO Unzip libxslt packages
# TODO MD5 checksum the libxslt packages after download

use strict;

package GitFiltersForNSF;

use File::Basename 'dirname';
use File::Copy 'copy';
use File::Spec;

our $projname   = "Git Filters For NSF";

our $useColours = 0;
our $verbose    = 0;

our $thisAbs = File::Spec->rel2abs(__FILE__);
our ($thisVol, $thisDir, $thisFile) = File::Spec->splitpath($thisAbs);

our $installScriptDir     = $thisDir;
$installScriptDir =~ s:/$::;

our $homeDir              = $ENV{"HOME"};

our $setupSourceFilename  = "Setup.pl";
our $setupSource          = "$installScriptDir/$setupSourceFilename";

our $setupTargetDir = "$homeDir/bin";
our $setupTargetFilename  = "Setup.pl";
our $setupTarget          = "$setupTargetDir/$setupTargetFilename";

our $binTargetDir					= $setupTargetDir;

our $xslSourceFilename    = "xsl/transform.xsl";
our $xslSource            = "$installScriptDir/$xslSourceFilename";

our $xslTargetDir  = "$homeDir/GitFilters";
our $xslTargetFilename   = "NonBinaryDxl.xsl";
our $xslTarget           = "$xslTargetDir/$xslTargetFilename";

our $libxsltDir		= "$installScriptDir/libxslt";
our @libxsltBins  = (
	'iconv-1.9.2.win32/bin/iconv.dll', 
	'iconv-1.9.2.win32/bin/iconv.exe', 
	'libxml2-2.7.8.win32/bin/libxml2.dll', 
	'libxml2-2.7.8.win32/bin/xmlcatalog.exe', 
	'libxml2-2.7.8.win32/bin/xmllint.exe', 
	'libxslt-1.1.26.win32/bin/libexslt.dll', 
	'libxslt-1.1.26.win32/bin/libxslt.dll', 
	'libxslt-1.1.26.win32/bin/xsltproc.exe', 
	'zlib-1.2.5/bin/minigzip.exe',
	'zlib-1.2.5/bin/zlib1.dll'
);



sub installEverything {

  installHelper();
  installXSL();
	installLibxslt();

}

sub uninstallEverything {

	uninstallHelper();
	uninstallXSL();
	uninstallLibxslt();

}


sub installHelper {

  if (-e $setupTarget) {
    print "NSF Repo Setup script is already installed\n";
  } else {
    print "NSF Repo Setup script will be installed\n";

    # Check if the Home Bin directory exists
    if (-d $setupTargetDir) {
      print "...Target \$HOME/bin directory already exists\n";
    } else {
      mkdir $setupTargetDir;
      print "...Created Directory: $setupTargetDir\n";      
    }

    # Copy the Setup script to the Target Directory
    use File::Copy;
    copy($setupSource, $setupTarget) or die "...Failed Copying: $!\n";
    print "...Installed NSF Repo Setup Script to $setupTarget\n";

  }

}

sub uninstallHelper {

	print "Attempt to remove Helper script ... ";

	if (-e $setupTarget) {

		unlink $setupTarget or warn "Could not remove $setupTarget: $!\n";
		print " uninstalled.\n";

	} else {

		print " already uninstalled, no action taken\n";

	}

}


sub installXSL {

  if (-e $xslTarget) {
    print "XSL File is already installed\n";
  } else {
    print "XSL File will be installed\n";

    # Check if the Home Bin directory exists
    if (-d $xslTargetDir) {
      print "...XSL directory $xslTargetDir already exists\n";
    } else {
      mkdir $xslTargetDir;
      print "...Created Directory for XSL: $xslTargetDir\n";
    }

    # Copy the xsl file to the Target Directory
    use File::Copy;

    copy($xslSource, $xslTarget) or die "Failed Copying: $!\n";
    print "...Installed XSL to $xslTarget\n";

  }

  print "\n";

}

sub uninstallXSL {

	print "Attempt to remove xsl script     ... ";  

	if (-e $xslTarget) {

		unlink $xslTarget or warn "Could not remove $xslTarget: $!\n";
		print " uninstalled.\n";

	} else {

		print " already uninstalled, no action taken\n";

	}

	print "\n";

}

sub installLibxslt {

	#mycls();

	my $binSource = '';
	my $binTarget	= '';

	print "$libxsltDir\n";

	#heading("Install libxslt win 32 binaries");

	print ("\nThis step will install the binaries required to run xsltproc\n\n");
	print ("xsltproc is the program used to filter the DXL using an xsl file\n");

	# Copy the contents to the bindir
	if (-d $binTargetDir) {
		
		# for each binary in the folder
		foreach (@libxsltBins)  {
	
			$binSource = "$libxsltDir/$_";

			my ($volume, $directories, $file) = File::Spec->splitpath( $binSource );

			$binTarget = "$binTargetDir/$file";

			if (-e $binTarget) {

				printf("%-40s ...already Installed\n", $binTarget);

			} else {

				use File::Copy;
				copy($binSource, $binTarget) or warn "Failed copying\n$binSource to \n$binTarget: $!\n\n";

			}

		}	

	} else {
		print "$binTargetDir is not set up\n\n";
	}

}

sub uninstallLibxslt {

	my $binSource = '';
	my $binTarget	= '';

	#heading("Uninstall libxslt win 32 binaries");

	# Copy the contents to the bindir
	if (-d $binTargetDir) {
		
		# for each binary in the folder
		foreach (@libxsltBins)  {
	
			$binSource = "$libxsltDir/$_";

			my ($volume, $directories, $file) = File::Spec->splitpath( $binSource );

			$binTarget = "$binTargetDir/$file";

			if (-e $binTarget) {

				my $noDelete = unlink $binTarget or warn "Could not remove $binTarget: $!\n";

				if ($noDelete == 1) {
					printf("%-40s ...removed\n", $binTarget);
				}

			} else {

				printf("%-40s ...not there anyway\n", $binTarget);

			}

		}	

	} else {
		print "$binTargetDir is not set up\n\n";
	}

	

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

sub main {

	processArgs();

	my $opt = "";
	my $invalidOpt = 0;

	mycls();

	while (1) {

		print "=======================================\n";
		print "$projname Installation\n\n";

		print "Current Status:\n\n";

		print "NSF Repo Setup ...";
		print "Installed at location\n";
		print "XSL Stylesheet ...";
		print "Installed at location\n";

		print "\nChoose a Menu Option\n\n";

		print "1. Install   Everything\n";
		print "2. Uninstall Everything\n\n";
		print "3. Install   Git Helper Script\n";
		print "4. Uninstall Git Setup Scr\n";
		print "5. Install   xsl stylesheet\n";
		print "6. Uninstall xsl stylesheet\n";
		print "7. Install   libxslt binaries\n";
		print "8. Uninstall libxslt binaries\n";

		print "\nq. Quit\n";

		if ($invalidOpt) {
			printf ("%s is an invalid option\n", $opt);
		} else {
			print "\n";
		}

		print "\nEnter Menu Option: ";

		$invalidOpt = 1;
		my $opt = <>;

		chomp($opt);

		exit 0 if $opt =~ m/^q/i;

		if ($opt eq "1") {

			installEverything();

		} elsif ($opt eq "2") {

			uninstallEverything();

		} elsif ($opt eq "3") {

			installHelper();	

		} elsif ($opt eq "4") {

			uninstallHelper();

		} elsif ($opt eq "5") {

			installXSL();

		} elsif ($opt eq "6") {

			uninstallXSL();

		} elsif ($opt eq "7") {

			installLibxslt();

		} elsif ($opt eq "8") {

			uninstallLibxslt();

		} else {
			$invalidOpt = 1;
		}

	}

}

main();

