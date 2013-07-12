#!/bin/perl
=begin comment

Copyright 2013 Cameron Gregor
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License

=end comment

=cut

use strict;

package Dora;

use File::Basename 'dirname';
use File::Copy 'copy';
use File::Spec;
use Term::ANSIColor;

our $projNameShort  = "dora";
our $projNameLong   = "Domino ODP Repository Assistant";

# Check if we are on a Mac OSX system
our $IsMacOSX  = ($^O eq 'darwin') ? 1 : 0;

# Program Behaviour variables
our $useColours = 1;
our $verbose    = 0;
our $subMenu		= "main";

# Figure out what directory the Install Script is in
our $thisAbs = File::Spec->rel2abs(__FILE__);
our ($thisVol, $thisDir, $thisFile) = File::Spec->splitpath($thisAbs);
our $installScriptDir     = $thisDir;
$installScriptDir =~ s:/$::; # remove trailing slash

# Figure out the Home Dir
our $homeDir              = $ENV{"HOME"};

# Helper script source location
our $setupSourceFilename  = "dora.pl";
our $setupSource          = "$installScriptDir/$setupSourceFilename";

# Helper script target location
our $setupTargetDir       = "$homeDir/bin";
our $setupTargetFilename  = "dora";
our $setupTarget          = "$setupTargetDir/$setupTargetFilename";

# Target Directory for the Binaries
our $binTargetDir					= $setupTargetDir;

# Source directory for XSL Stylesheets
our $xslSourceDir         = "$installScriptDir/xsl";
our @xslSourceFilenames   = (
  "DXLClean.xsl",
  "DXLPretty.xsl",
  "DXLSmudge.xsl",
);

# Target Directory for the XSL Stylesheets
our $xslTargetDir        = "$homeDir/dora";

# Source Directory for App Version Sync Resources 
our $avsSourceDir				= "$installScriptDir/AppVersionSync";
# Target Directory for App Version Sync Resources
our $avsTargetDir				= "$homeDir/dora";

# Install these resources for App Version Sync
our @avsSourceFilenames 	= (
	'post-commit',
	'post-checkout',
	'ccAppVersion.xsp',
	'ccAppVersion.xsp-config',
	'AppVersionUpdate.xsl',
	'AppVersionClean.xsl'
);

# Source of libxslt win32 Binaries
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
our $chkHelper 	          = 0;
our $chkXSL			          = 0;
our $chkLibxslt           = 0;
our $chkAppVersionSync		= 0;

sub installEverything {

  installHelper();
  installXSL();
	installLibxslt();
	#installAppVersionSync();

}

sub uninstallEverything {

  remindAboutRepositoryUninstall();
  return 0 if !confirmContinue();

	uninstallHelper();
	uninstallXSL();
	uninstallLibxslt();
	#uninstallAppVersionSync();

}

sub remindAboutRepositoryUninstall() {

  colorSet("white on_red");
  print " ** NOTE ** \n";
  colorReset();

  print "This uninstallation process only removes the Dora script and resources from it's installed locations.\n";
  print "It does not uninstall the Dora setup from any repositories that it has been setup in.\n";
  print "If you want to uninstall Dora from a repository, you should do that first by running:\n";
  colorSet("bold white");
  print  "\ndora.pl\n\n";
  colorReset();
  print "from within the repository first\n\n"; 

}


sub installHelper {


	heading("Install the Dora Helper Script");

	print "This step will attemp to copy the main helper script ";
	colorSet("bold white");
	print $setupTargetFilename;
	colorReset();
	print " script into the following directory:\n\n";

	colorSet("bold white");
	print "$setupTargetDir\n\n";
	colorReset();

	print "The helper script is used to help set up and configure git repositories for nsf use\n";
	print "You should ensure that this directory is on your 'PATH' so that you can run this script from anywhere\n";
	print "The directory will be attempted to be created if it does not exist\n";

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

	heading("Uninstall the Helper Script");

	if (-e $setupTarget) {

		print "This step will remove the Helper script located at: \n";
		colorSet("bold white");
		print "\n$setupTarget\n";
		colorReset();

		return 0 if !confirmContinue();

		unlink $setupTarget or warn "Could not remove $setupTarget: $!\n";
		printFileResult($setupTarget, "removed", 1);

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

	heading("Install the XSL Stylesheets for Metadata Filtering");

	print "This step will install the XSL Transformation Stylesheets that are used for Metadata Filtering to:\n\n";
	colorSet("bold white");
	print "  $xslTargetDir\n\n";
	colorReset();
	print "The XSL Stylesheets are copied from this location to your repository when you set up a repository for DXL Metadata filtering\n";

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

	heading("Uninstall the XSL Files");

	foreach(@xslSourceFilenames) {
		$xslTarget = getXSLTarget($_);
		push(@xslExist, $xslTarget) if (-e $xslTarget);
	}

	if (!@xslExist) {
		print "No XSL Stylesheets are currently installed, no action taken\n";
		return 0;
	}

	print "This step will remove the following XSL Stylesheets:\n\n";

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
				printFileResult($xslTarget,"removed",1);
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

sub getAppVersionSyncTarget {

	# get input parameter
	my ($srcFile) = @_;

	# get full path of Source Binary
	my $avsSource = "$avsSourceDir/$srcFile";

	# Determine the FileName of the Stylesheet
	my ($volume, $directories, $file) = File::Spec->splitpath($avsSource);

	# Return the Target Source Path of the AppVersionSync Stylesheet
	return "$avsTargetDir/$file";

} 


sub installAppVersionSync {

	my $avsSource 	= '';
	my $avsTarget	= '';
	my $avsExist  	= 0;

	heading("Install the App Version Sync Files");

	print "This step will install the necessary files for setting up the App Version Sync to:\n\n";
	colorSet("bold white");
	print "  $avsTargetDir\n\n";
	colorReset();
	print "The App Version sync system keeps a custom control updated with the current Version number as determined\n";
	print "by `git describe` and the current branch. The files to be copied include 2 git hooks, a default template\n";
	print "for the Custom Control (and its xsp-config file) and the, necessary XSL Transform stylesheets used to\n";
	print "make modifications to the Custom Control.\n ";

  # Show the user that hook files will be overwritten
 	foreach (@avsSourceFilenames) {

	  $avsTarget = getAppVersionSyncTarget($_);

		if (-e $avsTarget) {
	
			colorSet("bold yellow");
			if (!$avsExist) {
				print "\nThe Following AppVersionSync are already installed and will be overwritten if you continue:\n";
				$avsExist = 1;
			}
		  print "$avsTarget\n";
	  colorReset();
	
    }
  }	

	return 0 if !confirmContinue();

  # Check if the Home Bin directory exists
  if (-d $avsTargetDir) {
		printFileResult($avsTargetDir, "directory already exists", 0);
  } else {
    mkdir $avsTargetDir or die "Could not create directory$avsTargetDir: $!";
		printFileResult($avsTargetDir, "directory created", 1);
  }

  foreach(@avsSourceFilenames) {

    my $avsSource = "$avsSourceDir/$_";
    my $avsTarget = getAppVersionSyncTarget($_);

    # Copy the hook file to the Target Directory
    use File::Copy;

    copy($avsSource, $avsTarget) or die "Failed Copying: $!\n";
	  printFileResult($avsTarget, "Installed", 1);

  }

  print "\n";

}

sub uninstallAppVersionSync {

	my $avsSource = '';
	my $avsTarget	= '';
	my @avsExist = ();

	heading("Uninstall the App Version Sync files");

	foreach(@avsSourceFilenames) {
		$avsTarget = getAppVersionSyncTarget($_);
		push(@avsExist, $avsTarget) if (-e $avsTarget);
	}

	if (!@avsExist) {
		print "The App Version Sync files are not currently installed, no action taken\n";
		return 0;
	}

	print "This step will remove the following App Version Sync files\n\n";

	colorSet("bold white");
	foreach(@avsExist) {
		print "$_\n";
	}
	colorReset();
	

	if (!confirmContinue()) {
		print "aborting un-installation of App Version Sync\n";
		return 0;
	}

	# for each hook in the folder
	foreach (@avsSourceFilenames)  {
	
		$avsTarget = getAppVersionSyncTarget($_);

		if (-e $avsTarget) {

			my $noDelete = unlink $avsTarget or warn "Could not remove $avsTarget: $!\n";

			if ($noDelete == 1) {
				printFileResult($avsTarget,"removed",1);
			}

		} else {

			printFileResult($avsTarget,"not there anyway",0);

		}

	}	

}

sub checkAppVersionSync {

	foreach (@avsSourceFilenames) {

		my $avsTarget = getAppVersionSyncTarget($_);

		if (!-e $avsTarget) {
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

  if ($IsMacOSX) {

    print "The installation script has detected that this is computer is running Mac OSX\n";
    print "If this is the case, the necessary files for libxslt should be already installed\n";
    print "If this is not the case, you can re-run this install script using the ";
    colorSet("bold white");
    print "--os-windows";
    colorReset();
    print " option\n\n";

    return 0;
  }

	print ("This step will install the binaries for libxslt, they will be installed to the following directory:\n\n");

	colorSet("bold white");
	print "$binTargetDir\n\n";
	colorReset();

	print "This directory should be on your PATH so that the binaries can be executed from anywhere.\n";
	colorSet("bold white");
	print "xsltproc.exe";
	colorReset();
	print " is the program used to filter the DXL using the XSL Transformation Stylesheets\n";

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

  if ($IsMacOSX) {

    print "The installation script has detected that this is computer is running Mac OSX\n";
    print "If this is the case, the binaries for libxslt would not have been installed by $projNameShort\n";
    print "Therfore they should not need to be uninstalled. If this is not the case, you can re-run this\n";
    print "uninstall script using the ";
    colorSet("bold white");
    print "--os-windows";
    colorReset();
    print " option\n\n";

    return 0;
  }


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
				printFileResult($binTarget,"removed",1);
			} else {
        printFileResult($binTarget,'failed',-1);
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

sub usage {

  print "\n$projNameLong Installation Script\n\n";
#  print "  --dir-binaries <directory>\n\n";
#  print "            Specifies the Directory to install the binaries to\n";
#  print "            Default is ~\\bin\n\n";
#  print "  --dir-resources <directory>\n\n";
#  print "            Specifies the Directory to install the Resource Files to\n";
#  print "            Default is ~\\dora\n\n";
  print "  --help\n\n";
  print "            Show this help screen\n\n";
  print "  --install\n\n";
  print "            Install Everything\n\n";
  print "  --uninstall\n\n";
  print "            Uninstall Everything\n\n";
  print "  --os-mac\n\n";
  print "            Force the script to think it is running on Mac OSX\n\n";
  print "  --os-windows\n\n";
  print "            Force the script to think it is running on Windows\n\n";
  print "  --no-color\n\n";
  print "            Don't use color text in the terminal\n\n";
  print "  -v\n\n";
  print "            Be Verbose with output\n\n";

  exit 0;

}

sub processArgs {

  my $numArgs = $#ARGV + 1;

  # Check for first argument 
  usage if ($ARGV[0] eq '--help');

  foreach my $argnum (0 .. $#ARGV) {

#    if ($ARGV[$argnum] eq '--dir-binaries') {
# TODO allow specifying target directories via args
#    }
#
#    if ($ARGV[$argnum] eq '--dir-resources') {
#
#    }

    if ($ARGV[$argnum] eq '--no-color') {
      $useColours = 0;
    }

    if ($ARGV[$argnum] eq '--os-mac') {
      $IsMacOSX = 1;
    } 

    if ($ARGV[$argnum] eq '--os-windows') {
      $IsMacOSX = 0;
    }

    if ($ARGV[$argnum] eq '--install') {
      installEverything();
      exit 0;
    } 

    if ($ARGV[$argnum] eq '--uninstall') {
      uninstallEverything();
      exit 0;
    }

    if ($ARGV[$argnum] eq '-v') {
      $verbose = 1;
    }

  }

}

sub checkSetup {

	$chkHelper	= checkHelper();
	$chkXSL 		= checkXSL();

  if ($IsMacOSX) { 
    $chkLibxslt = 2;
  } else {
  	$chkLibxslt	= checkLibxslt();
  }

	$chkAppVersionSync		= checkAppVersionSync();

}


sub main {

	processArgs();

	my $opt = "";
	my $invalidOpt = 0;


	while (1) {

		checkSetup();

		mycls();

		heading("$projNameLong Installation");

		menuStatus();

		print "\nChoose a Menu Option\n\n";

		menuMain() 			if $subMenu eq "main";
		menuInstall() 	if $subMenu eq "install";
		menuUninstall()	if $subMenu eq "uninstall";

		print "\n";
		menuOption("q", "Quit");

		print "\nEnter Menu Option: ";

		$invalidOpt = 0;
		my $opt = <>;

		chomp($opt);

		exit 0 if $opt =~ m/^q/i;

		my $skipConfirmAnyKey = 0;

		if ($subMenu eq "main") {

			$subMenu = "install"		if 	($opt eq "1");
			$subMenu = "uninstall"	if 	($opt eq "2");
			
			$skipConfirmAnyKey = 1;

		} elsif ($subMenu eq "install") {
			
			if ($opt eq "1") {
				mycls();
				installEverything();
				$subMenu = "main";
			} elsif ($opt eq "2") {
				mycls();
				installHelper();	
			} elsif ($opt eq "3") {
				mycls();
				installXSL();
			} elsif ($opt eq "4") {
				mycls();
				installLibxslt();
			} elsif ($opt eq "5") {
				mycls();
				installAppVersionSync();
			} elsif($opt =~ m/^b/i) {
				$subMenu = "main";
				$skipConfirmAnyKey = 1;
			} else {
				$invalidOpt = 1;
			}


		} elsif ($subMenu eq "uninstall") {

			if ($opt eq "1") {
				mycls();	
				uninstallEverything();
				$subMenu = "main";
			} elsif ($opt eq "2") {
				mycls();
				uninstallHelper();
			} elsif ($opt eq "3") {
				mycls();
				uninstallXSL();
			} elsif ($opt eq "4") {
				mycls();
				uninstallLibxslt();
			} elsif ($opt eq "5") {
				mycls();
				uninstallAppVersionSync();
			} elsif ($opt =~ m/^b/i) {
				$subMenu = "main";
				$skipConfirmAnyKey = 1;
			} else {
				$invalidOpt = 1;
			}

		}

		confirmAnyKey() unless $skipConfirmAnyKey;

	}

}

sub menuStatus {

    my $osname = ($IsMacOSX) ? "Mac OSX" : "Windows";
    print "Operating System Detected: ";
    colorSet("bold white");
    print "$osname\n\n";
    colorReset();

		print "Target Directories:\n\n";

		print "  Binaries : ";
		colorSet("bold white");
		printf("%-40s\n",$binTargetDir);
		colorReset();

		print "  Resources: ";
		colorSet("bold white");
		printf("%-40s\n",$xslTargetDir);
		colorReset();

		print "\nCurrent Status:\n\n";

		printInstallStatus("  Git Helper Script", $chkHelper);
		printInstallStatus("  XSL Stylesheets",		$chkXSL);
		printInstallStatus("  libxslt binaries", 	$chkLibxslt);
		#printInstallStatus("  App Version Sync",	$chkAppVersionSync);


}

sub menuMain {
		menuOption("1", "Installation   submenu...");
		menuOption("2", "Uninstallation submenu...");
}

sub menuInstall {
		menuOption("1", "Install Everything");
		menuSeparator();
		menuOption("2", "Install Git Helper Script");
		menuOption("3", "Install XSL Stylesheets");
		menuOption("4", "Install libxslt binaries");
		#menuOption("5", "Install App Version Sync");
		menuSeparator();
		menuOption("b", "Back to main menu");
}

sub menuUninstall {
		menuOption("1", "Uninstall Everything");
		menuSeparator();
		menuOption("2", "Uninstall Git Helper Script");
		menuOption("3", "Uninstall XSL stylesheets");
		menuOption("4", "Uninstall libxslt binaries");
		#menuOption("5", "Uninstall App Version Sync");
		menuSeparator();
		menuOption("b", "Back to main menu");
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

  # Special Case for Mac OSX libxslt, binaries should already be installed
  $statusText = "Not Applicable" if ($status eq 2);

  printf("%-25s : ",$element);

  colorSet("bold blue")   if ($status eq 2);
  colorSet("bold green")  if ($status eq 1);
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

  my $maxwidth  = 70;
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

    print "\nContinue? (y)/n/q: ";
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
