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
use Term::ANSIColor;

our $projNameShart  = "dora";
our $projNameLong   = "Domino ODP Repository Assistant";

our $useColours = 1;
our $verbose    = 0;

our $thisAbs = File::Spec->rel2abs(__FILE__);
our ($thisVol, $thisDir, $thisFile) = File::Spec->splitpath($thisAbs);

our $installScriptDir     = $thisDir;
$installScriptDir =~ s:/$::; # remove trailing slash

our $homeDir              = $ENV{"HOME"};

our $setupSourceFilename  = "dora.pl";
our $setupSource          = "$installScriptDir/$setupSourceFilename";

our $setupTargetDir       = "$homeDir/bin";
our $setupTargetFilename  = "dora.pl";
our $setupTarget          = "$setupTargetDir/$setupTargetFilename";

our $binTargetDir					= $setupTargetDir;

our $xslSourceDir         = "$installScriptDir/xsl";
our @xslSourceFilenames   = (
  "DXLFilter.xsl",
  "DXLPretty.xsl",
  "DXLDeflate.xsl",
	"AppVersioner.xsl",
	"AppVersionClean.xsl"
);

our $xslTargetDir        = "$homeDir/dora";

# Vars for Hook installation
our $hookSourceDir				= "$installScriptDir/hooks";
our $hookTargetDir				= "$homeDir/dora";

our @hookSourceFilenames 	= (
	'post-commit',
	'post-checkout'
);

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

# Variables used to check current configuration
our $chkHelper 	= 0;
our $chkXSL			= 0;
our $chkLibxslt = 0;
our $chkHooks		= 0;

sub installEverything {

  installHelper();
  installXSL();
	installLibxslt();
	installHooks();

}

sub uninstallEverything {

	uninstallHelper();
	uninstallXSL();
	uninstallLibxslt();
	uninstallHooks();

}


sub installHelper {


	heading("Install the Helper");

	print "This step will install the $setupTargetFilename script into $setupTargetDir\n";
	print "The helper script is used to help set up and configure git repositories for nsf use\n";

  if (-e $setupTarget) {
		colorSet("bold yellow");
    print "\nThe helper script is already installed, if you continue it will overwrite the existing copy.\n";
		colorReset();
  }

	return 0 if !confirmContinue();
	
  # Check if the Home Bin directory exists
  if (-d $setupTargetDir) {
		printFileResult($setupTargetDir,"directory already exists",0);
  } else {
    mkdir $setupTargetDir or die "Could not create Directory: $!\n";
		printFileResult($setupTargetDir,"directory created", 1);
  }

  # Copy the Setup script to the Target Directory
  use File::Copy;
  copy($setupSource, $setupTarget) or die "...Failed Copying: $!\n";
	printFileResult($setupTarget,"Installed",1);

}

sub uninstallHelper {

	heading("Uninstall the Helper");

	if (-e $setupTarget) {

		print "This step will remove the Helper script located at: \n";
		colorSet("bold white");
		print "\n$setupTarget\n";
		colorReset();

		return 0 if !confirmContinue();

		unlink $setupTarget or warn "Could not remove $setupTarget: $!\n";
		printFileResult($setupTarget, "removed", -1);

	} else {

		print "The helper script is not installed, no action taken\n";

	}

}

sub checkHelper {

	return (-e $setupTarget);

}

sub getXSLTarget {

	# get input parameter
	my ($srcFile) = @_;

	# get full path of Source Binary
	my $xslSource = "$xslSourceDir/$srcFile";

	# Determine the FileName of the Stylesheet
	my ($volume, $directories, $file) = File::Spec->splitpath($xslSource);

	# Return the Target Source Path of the XSL Stylesheet
	return "$xslTargetDir/$file";

} 

sub installXSL {

	my $xslSource = '';
	my $xslTarget	= '';
	my $xslExist  = 0;

	heading("Install the XSL Stylesheets");

	print "This step will install the XSL Stylesheets to:\n\n";
	colorSet("bold white");
	print "  $xslTargetDir\n\n";
	colorReset();
	print "The XSL Stylesheets are used by the NSF Metadata filter\n";
	print "When you use the helper script to setup a repository for NSF Metadata filtering,\n";
	print "the helper script will copy the above file to the ";
	colorSet("bold white");
	print "xsl/";
	colorReset();
	print " folder of the repository\n";

  # Show the user that xsl files will be overwritten
 	foreach (@xslSourceFilenames) {

	  $xslTarget = getXSLTarget($_);

		if (-e $xslTarget) {
	
			colorSet("bold yellow");
			if (!$xslExist) {
				print "\nThe Following XSL Stylesheets are already installed and will be overwritten if you continue:\n";
				$xslExist = 1;
			}
		  print "$xslTarget\n";
	  colorReset();
	
    }
  }	

	return 0 if !confirmContinue();

  # Check if the Home Bin directory exists
  if (-d $xslTargetDir) {
		printFileResult($xslTargetDir, "directory already exists", 0);
  } else {
    mkdir $xslTargetDir or die "Could not create directory$xslTargetDir: $!";
		printFileResult($xslTargetDir, "directory created", 1);
  }

  foreach(@xslSourceFilenames) {

    my $xslSource = "$xslSourceDir/$_";
    my $xslTarget = getXSLTarget($_);

    # Copy the xsl file to the Target Directory
    use File::Copy;

    copy($xslSource, $xslTarget) or die "Failed Copying: $!\n";
	  printFileResult($xslTarget, "Installed", 1);

  }

  print "\n";

}

sub uninstallXSL {

	my $xslSource = '';
	my $xslTarget	= '';
	my @xslExist = ();

	heading("Uninstall the XSL File");

	foreach(@xslSourceFilenames) {
		$xslTarget = getXSLTarget($_);
		push(@xslExist, $xslTarget) if (-e $xslTarget);
	}

	if (!@xslExist) {
		print "No XSL Stylesheets are currently installed, no action taken\n";
		return 0;
	}

	print "This step will remove the following XSL Stylesheets\n\n";

	colorSet("bold white");
	foreach(@xslExist) {
		print "$_\n";
	}
	colorReset();
	

	if (!confirmContinue()) {
		print "aborting un-installation of XSL Stylesheets\n";
		return 0;
	}

	# for each binary in the folder
	foreach (@xslSourceFilenames)  {
	
		$xslTarget = getXSLTarget($_);

		if (-e $xslTarget) {

			my $noDelete = unlink $xslTarget or warn "Could not remove $xslTarget: $!\n";

			if ($noDelete == 1) {
				printFileResult($xslTarget,"removed",-1);
			}

		} else {

			printFileResult($xslTarget,"not there anyway",0);

		}

	}	

}

sub checkXSL {

	foreach (@xslSourceFilenames) {

		my $xslTarget = getXSLTarget($_);

		if (!-e $xslTarget) {
			return 0;
		}

	}

	return 1;

}

sub getHookTarget {

	# get input parameter
	my ($srcFile) = @_;

	# get full path of Source Binary
	my $hookSource = "$hookSourceDir/$srcFile";

	# Determine the FileName of the Stylesheet
	my ($volume, $directories, $file) = File::Spec->splitpath($hookSource);

	# Return the Target Source Path of the Hook Stylesheet
	return "$hookTargetDir/$file";

} 


sub installHooks {

	my $hookSource 	= '';
	my $hookTarget	= '';
	my $hookExist  	= 0;

	heading("Install the Hooks");

	print "This step will install the Hooks to:\n\n";
	colorSet("bold white");
	print "  $hookTargetDir\n\n";
	colorReset();
	print "The Hooks are used by Auto-Version system to keep a custom control updated with the latest version number.\n";
	print "When you use the helper script to setup a repository for version tagging,\n";
	print "the helper script will copy the above file to the ";
	colorSet("bold white");
	print ".git/hooks";
	colorReset();
	print " folder of the repository\n";

  # Show the user that hook files will be overwritten
 	foreach (@hookSourceFilenames) {

	  $hookTarget = getHookTarget($_);

		if (-e $hookTarget) {
	
			colorSet("bold yellow");
			if (!$hookExist) {
				print "\nThe Following Hooks are already installed and will be overwritten if you continue:\n";
				$hookExist = 1;
			}
		  print "$hookTarget\n";
	  colorReset();
	
    }
  }	

	return 0 if !confirmContinue();

  # Check if the Home Bin directory exists
  if (-d $hookTargetDir) {
		printFileResult($hookTargetDir, "directory already exists", 0);
  } else {
    mkdir $hookTargetDir or die "Could not create directory$hookTargetDir: $!";
		printFileResult($hookTargetDir, "directory created", 1);
  }

  foreach(@hookSourceFilenames) {

    my $hookSource = "$hookSourceDir/$_";
    my $hookTarget = getHookTarget($_);

    # Copy the hook file to the Target Directory
    use File::Copy;

    copy($hookSource, $hookTarget) or die "Failed Copying: $!\n";
	  printFileResult($hookTarget, "Installed", 1);

  }

  print "\n";

}

sub uninstallHooks {

	my $hookSource = '';
	my $hookTarget	= '';
	my @hookExist = ();

	heading("Uninstall the Hooks");

	foreach(@hookSourceFilenames) {
		$hookTarget = getHookTarget($_);
		push(@hookExist, $hookTarget) if (-e $hookTarget);
	}

	if (!@hookExist) {
		print "No Hooks are currently installed, no action taken\n";
		return 0;
	}

	print "This step will remove the following Hooks\n\n";

	colorSet("bold white");
	foreach(@hookExist) {
		print "$_\n";
	}
	colorReset();
	

	if (!confirmContinue()) {
		print "aborting un-installation of Hooks\n";
		return 0;
	}

	# for each hook in the folder
	foreach (@hookSourceFilenames)  {
	
		$hookTarget = getHookTarget($_);

		if (-e $hookTarget) {

			my $noDelete = unlink $hookTarget or warn "Could not remove $hookTarget: $!\n";

			if ($noDelete == 1) {
				printFileResult($hookTarget,"removed",-1);
			}

		} else {

			printFileResult($hookTarget,"not there anyway",0);

		}

	}	

}

sub checkHooks {

	foreach (@hookSourceFilenames) {

		my $hookTarget = getHookTarget($_);

		if (!-e $hookTarget) {
			return 0;
		}

	}

	return 1;

}


sub getLibxsltTarget {

	# get input parameter
	my ($srcFile) = @_;

	# get full path of Source Binary
	my $binSource = "$libxsltDir/$srcFile";

	# Determin the FileName of the binary
	my ($volume, $directories, $file) = File::Spec->splitpath($binSource);

	# Return the Target Source Path of the binary
	return "$binTargetDir/$file";

} 

sub installLibxslt {

	my $binSource = '';
	my $binTarget	= '';
	my $binsExist = 0;

	heading("Install libxslt win 32 binaries");

	print ("\nThis step will install the binaries required to run xsltproc\n\n");
	print ("xsltproc is the program used to filter the DXL using an xsl file\n");

	foreach (@libxsltBins) {

		$binTarget = getLibxsltTarget($_);

		if (-e $binTarget) {
	
			colorSet("bold yellow");
			if (!$binsExist) {
				print "\nThe Following binaries are already installed and will be overwritten if you continue:\n";
				$binsExist = 1;
			}
			print "$binTarget\n";
			colorReset();
	
		}	

	}

	return 0 if !confirmContinue();

	# Set up bin directory if not there
	if (-d $binTargetDir) {
		printFileResult($binTargetDir, "directory already exists", 0);
  } else {
    mkdir $binTargetDir or die "Could not create directory $binTargetDir: $!";
		printFileResult($binTargetDir, "directory created", 1);
  }

	# for each binary in the folder
	foreach (@libxsltBins)  {
	
		$binSource = "$libxsltDir/$_";

		my ($volume, $directories, $file) = File::Spec->splitpath( $binSource );

		$binTarget = "$binTargetDir/$file";

		use File::Copy;
		my $cpResult = copy($binSource, $binTarget) or warn "Failed copying\n$binSource to \n$binTarget: $!\n\n";

		printFileResult($binTarget,"copied successfully",1) if $cpResult;

	}	

}

sub uninstallLibxslt {

	my $binSource = '';
	my $binTarget	= '';
	my @binsExist = ();

	heading("Uninstall libxslt win 32 binaries");

	foreach(@libxsltBins) {
		$binTarget = getLibxsltTarget($_);
		push(@binsExist, $binTarget) if (-e $binTarget);
	}

	if (!@binsExist) {
		print "No Libxslt binaries are currently installed, no action taken\n";
		return 0;
	}

	print "This step will remove the following Libxslt binaries\n\n";

	colorSet("bold white");
	foreach(@binsExist) {
		print "$_\n";
	}
	colorReset();
	

	if (!confirmContinue()) {
		print "aborting un-installation libxslt binaries\n";
		return 0;
	}

	# for each binary in the folder
	foreach (@libxsltBins)  {
	
		$binTarget = getLibxsltTarget($_);

		if (-e $binTarget) {

			my $noDelete = unlink $binTarget or warn "Could not remove $binTarget: $!\n";

			if ($noDelete == 1) {
				printFileResult($binTarget,"removed",-1);
			}

		} else {

			printFileResult($binTarget,"not there anyway",0);

		}

	}	

}

sub checkLibxslt {

	foreach (@libxsltBins) {

		my $binTarget = getLibxsltTarget($_);

		if (!-e $binTarget) {
			return 0;
		}

	}

	return 1;

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

sub checkSetup {

	$chkHelper	= checkHelper();
	$chkXSL 		= checkXSL();
	$chkLibxslt	= checkLibxslt();
	$chkHooks		= checkHooks();

}


sub main {

	processArgs();

	my $opt = "";
	my $invalidOpt = 0;


	while (1) {

		checkSetup();

		mycls();

		heading("$projNameLong Installation");

		print "Current Status:\n\n";

		printInstallStatus("Git Helper Script", $chkHelper);
		printInstallStatus("XSL Stylesheet",		$chkXSL);
		printInstallStatus("libxslt binaries", 	$chkLibxslt);
		printInstallStatus("Hooks",							$chkHooks);

		print "\nChoose a Menu Option\n\n";

		menuOption("1", "Install Everything");
		menuOption("2", "Uninstall Everything");
		menuSeparator();
		menuOption("3", "Install Git Helper Script");
		menuOption("4", "Install XSL Stylesheets");
		menuOption("5", "Install libxslt binaries");
		menuOption("6", "Uninstall Git Helper Script");
		menuOption("7", "Uninstall XSL stylesheets");
		menuOption("8", "Uninstall libxslt binaries");
		menuSeparator();
		menuOption("9", "Install Hooks");
		menuOption("10", "Uninstall Hooks");
		menuSeparator();
		menuOption("q", "Quit");

		if ($invalidOpt) {
			printf ("%s is an invalid option\n", $opt);
		} else {
			print "\n";
		}

		print "\nEnter Menu Option: ";

		$invalidOpt = 0;
		my $opt = <>;

		chomp($opt);

		exit 0 if $opt =~ m/^q/i;

		if ($opt eq "1") {

			mycls();
			installEverything();

		} elsif ($opt eq "2") {

			mycls();
			uninstallEverything();

		} elsif ($opt eq "3") {

			mycls();
			installHelper();	

		} elsif ($opt eq "4") {

			mycls();
			installXSL();

		} elsif ($opt eq "5") {

			mycls();
			installLibxslt();

		} elsif ($opt eq "6") {

			mycls();
			uninstallHelper();

		} elsif ($opt eq "7") {

			mycls();
			uninstallXSL();

		} elsif ($opt eq "8") {

			mycls();
			uninstallLibxslt();

		} elsif ($opt eq "9") {

			mycls();
			installHooks();

		} elsif ($opt eq "10") {

			mycls();
			uninstallHooks();

		} else {
			$invalidOpt = 1;
		}

		confirmAnyKey() if !$invalidOpt;

	}

}

# Terminal Helper Functions

sub colorSet {
  my ($color) = @_;
  print Term::ANSIColor::color($color) if $useColours;
}

sub colorReset {
  print Term::ANSIColor::color("reset") if $useColours;
}

sub menuOption {

  my ($num, $text) = @_;

  printf("%4s. %s\n", $num, $text);


}

sub menuSeparator {
	print "  ---------------------\n";
}

sub printFileResult {

  my ($filename, $resultdesc, $indicator) = @_;

  printf("%-50s ...", $filename);

  colorSet("bold green")  if ($indicator == 1);
	colorSet("bold white") 	if ($indicator == 0);
  colorSet("bold red")    if ($indicator == -1);

  print("$resultdesc\n");

  colorReset();

}

sub printInstallStatus {

  my ($element, $status) = @_;

  my $statusText = ($status) ? "Installed" : "Not Installed";

  printf("%-25s : ",$element);

  colorSet("bold green")  if ($status);
  colorSet("bold")        if (!$status);

  print("$statusText\n");

  colorReset();

}

sub installRemoveOption {

  my ($num, $text, $enabled, $installed) = @_;

  # Set up install or remove color
  if ($useColours) {
    if ($enabled) {
      if ($installed) {
        print Term::ANSIColor::color("bold red");
      } else {
        print Term::ANSIColor::color("bold green");
      }
    }
  }

  # Print option number
  print "$num. ";

  # Print the Action
  if (!$enabled) {
    print "n/a     ";
  } elsif ($installed) {
    print "Remove  ";
  } else {   
    print "Install ";
  }

  if ($useColours) {   
    if (!$enabled) {
      print Term::ANSIColor::color("reset");
    } else {
      print Term::ANSIColor::color("bold white");
    }  
  };

  # Print the text of the menu option
  print $text;

  # Reset the colours
  if ($useColours) {  
    print Term::ANSIColor::color("reset");
  };

  print "\n";

}

sub heading {

  my $maxwidth  = 50;
  my $fillerChar = "*";

  # Get the Title from the sub arguments
  my ($title) = @_;;

  # Determine number of Asterixes either side
  my $tlength = length($title);
  my $totFillers = $maxwidth - $tlength - 4;
  if ($totFillers < 0) { print "Error: Title too long... exiting";exit -1; };
  my $fillers = int($totFillers / 2);

  # Give me some space
  print "\n";

  # If we are using colours, Set up the colour
  if ($useColours) {
    print Term::ANSIColor::color("bold white");
    print Term::ANSIColor::color("on_blue");
  }

  # Print first asterixes
  for (my $i = 0; $i < $fillers; $i++) { print $fillerChar; }

  # print Heading with space either side
  print " $title ";

  # Print last asterixes
  for (my $i = 0; $i < $fillers; $i++) { print $fillerChar; }
  # Print an extra one if there was an odd number
  if (($totFillers % 2) > 0) { print $fillerChar; }

  # If we are using colours, reset them
  if($useColours) {
    print Term::ANSIColor::color("reset");
  }

  # Print new line
  print "\n\n";

}


sub mycls {

  system("clear");
  
}


sub confirmAnyKey {

  print "\nPress enter to continue ...";
  my $tmp = <STDIN>;

}

sub confirmContinue {

  my $opt       = "";
  my $invalid   = 0;
  my $noanswer  = 1;

  while ($noanswer) {

    print("\nInvalid option: $opt, please choose y/n/q\n\n") if $invalid;

    print "\nContinue? y/n/q: ";
    $opt = <STDIN>;
    chomp($opt);

		print "\n";

    exit 0    if ($opt =~ m/^q/i);
    return 1  if ($opt =~ m/^y/i || $opt eq "");
    return 0  if ($opt =~ m/^n/i);

    $invalid = 1;

  }

}

# END TERMINAL HELPER FUNCTIONS

main();
