#!/bin/perl


use strict;
use Term::ANSIColor;

package GitFiltersForNSF;

# Program behaviour variables
our $useColours = 1;
our $verbose    = 0;
our $subMenu		= "main";

our $productNameShort   = "dora";
our $productNameLong    = "Domino ODP Repository Assistant";

# Directory and File Locations
our $homeDir            = $ENV{"HOME"};
our $tmpDir  						= File::Spec->tmpdir();
our $scriptDir          = "$homeDir/bin";
our $xslSourceDir       = "$homeDir/dora";
our $nsfDir							= "nsf";

# XSL DXL Filter file names
our $xslFilterFilename  				= "DXLFilter.xsl";
our $xslPrettyFilename  				= "DXLPretty.xsl";
our $xslDeflateFilename 				= "DXLDeflate.xsl";
our $xslVersionerFilename				= "AppVersioner.xsl";
our $xslVersionCleanerFilename	= "AppVersionClean.xsl";

# XSL Stylesheets, make sure first one is the filter
our @xslSourceFilenames = (
  $xslFilterFilename,
  $xslPrettyFilename,
  $xslDeflateFilename,
	$xslVersionerFilename,
	$xslVersionCleanerFilename
);

our $xslTargetDir       = "xsl";
our $xslFilter          = "$xslTargetDir/$xslFilterFilename";
our $xslVersioner				= "$xslTargetDir/$xslVersionerFilename";
our $xslVersionCleaner	= "$xslTargetDir/$xslVersionCleanerFilename";

# Details for the Version Custom Control
our $ccVersionName 		= "ccAppVersion.xsp";
our $ccVersionDir			= "$nsfDir/CustomControls";
our $ccVersion				= "$ccVersionDir/$ccVersionName";
our $ccVersionCfg 		= "$ccVersion-config";  

# Vars for Hooks setup
our $hookSourceDir						= "$homeDir/dora";
our $hookTargetDir						= ".git/hooks";
our $hookPostCommitFilename		= "post-commit";
our $hookPostCheckoutFilename	= "post-checkout";

our @hookSourceFilenames = (
	$hookPostCommitFilename,
	$hookPostCheckoutFilename
);

# These vars used for installing CC Default Template
our $ccSourceDir		= "$homeDir/dora";
our $ccTargetDir		= $ccVersionDir;

our @ccSourceFilenames = (
	'ccAppVersion.xsp',
	'ccAppVersion.xsp-config'
);

our $attrFile     = ".gitattributes";
our $ignoreFile   = ".gitignore";

#Filter values
our $cleanFilter  					= "xsltproc $xslFilter -";
our $smudgeFilter 					= "cat";
our $appVersionCleanFilter	= "xsltproc $xslVersionCleaner - ";
our $appVersionSmudgeFilter	= "cat";

# Markers to be used in Config files
our $cfgStartMark   = "# GitNSF Start";
our $cfgFinishMark  = "# GitNSF Finish";

# Variables for Checking repo setup
our $gitDir         = "";
our $gitRepoDir     = "";

our $chkIgnore   = 0;
our $chkAttr     = 0;
our $chkFilter   = 0;
our $chkXSL      = 0;
our $chkHooks		 = 0;

# Entries for Git Ignore File
our @ignoreEntries = (
  'nsf/.classpath',
  'nsf/.project',
  'nsf/plugin.xml',
  'nsf/.settings',
	'nsf/CustomControls/ccAppVersion.xsp*'
);

# Entries for Git Attributes File
our @attrEntries = (
  '*.aa',
  '*.column',
  '*.dcr',
  '*.fa',
  '*.field',
  '*.folder',
  '*.form',
  '*.frameset',
  '*.ija',
  '*.ja',
  '*.javalib',
  '*.lsa',
  '*.lsdb',
  '*.metadata',
  '*.navigator',
  '*.outline',
  '*.page',
  '*.subform',
  '*.view',
  'AboutDocument',
  'database.properties',
  'IconNote',
  'Shared?Actions',
  'UsingDocument',
	$ccVersionName 
);


use File::Basename;
my $setupScriptDirname = dirname(__FILE__);

sub setupNewNSFFolder {
  
  # Ask for the Application name
  heading("Setup New NSF Git Folder");

  print "This step will create a new folder for an NSF\n\n";
  print "What is the name of the Folder?\n\n";

  my $opt = <>;
  chomp($opt);

  if ($opt =~ /[a-zA-Z]/) {

    # Make the new Directory
    mkdir($opt);

    # Set up the NSF Folder
    mkdir("$opt/nsf");
    mkdir("$opt/xsl");

    # TODO Initialise the GitIgnore file

    # Initialise a Git Repository
    chdir($opt);
    my @args = ('init');
    system('git',@args);

  }
  
  chdir($opt);

}

sub checkInGitRepo {

  # make sure in we are in a Git Repo
  if ($verbose) { print "\nChecking if we are in a git repository: "};

  $gitDir     	= "";
  $gitRepoDir  	= "";

  my @args = ('rev-parse','--git-dir');
  system('git',@args);

  if ($? == -1) {
    if ($verbose) { print 'git rev-parse failed, please run this operation from a Git Repository\n'; }
    return 0;
  } else {

    # Must shift the result to get the error code
    my $result = $? >> 8;

    if ($result != 0) {
      printf "\nNot in a Git Repo command exited with value %d\n", $result;
      return 0;
    } else {

      $gitDir      = `git rev-parse --git-dir`;
      $gitRepoDir  = `git rev-parse --show-toplevel`;

      return 1;

    }

  }  

}

sub installFilter {

  heading("Add NSF Filter to Git Config");

  print "This step will add a new filter to the local .gitconfig file\n";
  print "It does this by adding two entries filter.nsf.clean and filter.nsf.smudge\n";
  print "These entries point to the location of 2 corresponding perl scripts in the GitFiltersForNSF directory\n\n"; 

  #TODO check the return status of these system commands
  return 0 if !confirmContinue();

  my @args = ('config','--local','filter.nsf.clean',$cleanFilter);
  system('git',@args);

  @args = ('config','--local','filter.nsf.smudge',$smudgeFilter);
  system('git',@args);

  @args = ('config','--local','filter.nsf.required','true');
  system('git',@args);

	@args = ('config','--local','filter.appversion.clean',$appVersionCleanFilter);
	system('git',@args);

	@args = ('config','--local','filter.appversion.smudge',$appVersionSmudgeFilter);
	system('git',@args);

	@args = ('config','--local','filter.appversion.required','true');
	system('git',@args);

  print "\nAdded git filters\n";

}

sub uninstallFilter {

  my ($silent) = @_;

  if (!$silent) {
    heading("Uninstall NSF Filter from Git Config");
    print "Uninstall Filter\n";
    return 0 if !confirmContinue();
  }
  
	# Remove the normal nsf filter
  my @args = ('config','--local','--unset','filter.nsf.clean');
  system('git',@args);

  @args = ('config','--local','--unset','filter.nsf.smudge');
  system('git',@args);

  @args = ('config','--local','--unset','filter.nsf.required');
  system('git',@args);

	# Removed the App Version filter
  my @args = ('config','--local','--unset','filter.appversion.clean');
  system('git',@args);

  @args = ('config','--local','--unset','filter.appversion.smudge');
  system('git',@args);

  @args = ('config','--local','--unset','filter.appversion.required');
  system('git',@args);

  print "\nRemoved Git Filters\n";

}

sub checkFilter {

	# Check NSF Filter
  my $currClean     = `git config --local --get filter.nsf.clean`;
  my $currSmudge    = `git config --local --get filter.nsf.smudge`;
  my $currRequired  = `git config --local --get filter.nsf.required`;

  chomp($currClean, $currSmudge, $currRequired);

  return 0 if ($currClean ne $cleanFilter);
  return 0 if ($currSmudge ne $smudgeFilter);
  return 0 if ($currRequired ne "true");

	# Check NSF Filter
  my $currClean     = `git config --local --get filter.appversion.clean`;
  my $currSmudge    = `git config --local --get filter.appversion.smudge`;
  my $currRequired  = `git config --local --get filter.appversion.required`;

  chomp($currClean, $currSmudge, $currRequired);

  return 0 if ($currClean ne $appVersionCleanFilter);
  return 0 if ($currSmudge ne $appVersionSmudgeFilter);
  return 0 if ($currRequired ne "true");

  return 1;
  
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
  
  my ($silent) = @_;
	my $xslSource = '';
	my $xslTarget	= '';
	my $xslExist  = 0;

  heading("Install XSL Stylesheets to this Repository");

  print "This step will install the XSL Stylesheets from:\n\n";
  colorSet("bold white");
  print "$xslSourceDir\n\n";
  colorReset();
  print "Into the:\n\n";
  colorSet("bold white");
  print "$xslTargetDir/\n\n";
  colorReset();
  print "directory in the current repository. The directory will be created if it does not exist.\n";

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

    if (-e $xslSource) {

      my $xslTarget = getXSLTarget($_);

      # Copy the xsl file to the Target Directory
      use File::Copy;

      copy($xslSource, $xslTarget) or die "Failed Copying: $!\n";
	    printFileResult($xslTarget, "Installed", 1);

    } else {
      printf("ERROR: $xslSource could not be found, is $productNameShort properly?");
    }

  }

}

sub uninstallXSL {
  
  my ($silent) = @_;
	my $xslSource = '';
	my $xslTarget	= '';
	my @xslExist = ();

  if (!$silent) {
    heading("Uninstall the XSL Stylesheets");
    print "Uninstall XSL File\n";
    return 0 if !confirmContinue();
  }

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
				printFileResult($xslTarget,"Removed",-1);
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

sub setSigner {
  
  # Ask for behaviour to do with wassignedby Tag
  heading("Design Element Signer");

  print "This step will configure the nsf filter to replace the <wassignedby> Note item\n";
  print "Please note this could be a bad idea from a security point of view.\n";
  print "If you pull changes from other contributors, the changes will appear as already signed by the ID you specify here\n\n";
  print "1. No Action. Leave in current configuration\n";
  print "2. Set up the default signer\n";
  print "3. Remove the default signer\n";
  print "\nEnter Choice: ";


  our $useSigner = <>;
  chomp($useSigner);

  exit 0 if $useSigner =~ /^q/i;

  if ($useSigner eq "2") {

    print "\nThe NotesName will be saved in format 'CN=<Common Name>/O=<Organisation>' in the local .gitconfig under the entry 'nsf.signer'\n";

    print "\nPlease type the Common Name : ";
    my $signerCN = <STDIN>;
    chomp($signerCN);
    $signerCN =~ s/^\s*(.*?)\s*$/$1/;

    print "Please type the Organisation: ";
    my $signerOrg = <STDIN>;
    chomp($signerOrg);
    $signerOrg =~ s/^\s*(.*?)\s*$/$1/;

    my $signer = "CN=" . $signerCN . "/O=" . $signerOrg;

    print "Signer will be set as a local git config variable nsf.signer as:\n";
    print "\"$signer\"" . "\n";
    print "\nPlease confirm if ok (y/n): ";
    my $confirm = <STDIN>;

    if ($confirm =~ m/^y/i) {

      #TODO test for return value

      my @args = ('config','--local','nsf.signer',"\"$signer\"");
      system('git', @args);

      if ($? == -1) {  

        print 'git config command failed, please check Git is installed\n';    

      } else {

        my $result = $? >> 8;

        if ($result == 0) {
          print "\nnsf.signer successfully Added\n";
        } elsif ($result == 3) {
          print "\nThe .gitconfig file is invalid\n";
        } else {
          print "\nFAIL: git config returned error code " . $result;
        }

      }

    }

  } elsif ($useSigner eq "3") {

    my @args = ('config','--local','--unset-all','nsf.signer');
    system('git',@args);

    if ($? == -1) {
      print 'git config command failed, please check Git is installed\n';
    } else {
  
  
      my $result = $? >> 8;

      if ($result == 0) {
        print "\nnsf.signer was successfully removed from local .gitconfig\n";
      } elsif($result == 5) {
        print "\nnsf.signer did not exist in .gitconfig anyway\n";
      } else {        
        printf "FAIL: git config exited with return value %d", $? >> 8;
      }

    }

  }

}

sub installAttr {


  heading("Associate File Extensions with Filter");

  print "This step will update the .gitattributes of the current repository.\n";
  print "WARNING: This function will sort and deduplicate your .gitattributes file.\n";
  print "If you have comments or keep your .gitattributes in a particular order, this will destroy that order\n";
  print "It will associate certain files with the nsf filter that was configure in the .gitconfig file.\n\n";

  return 0 if !confirmContinue();

  #Uninstall Previous Entries
  uninstallAttr(1);

  # Open the Attributes file for Appending
  open (GITATTR, ">>$attrFile") or die "Can't Open $attrFile file for appending: $!";

  # print our section start marker
  print GITATTR "\n$cfgStartMark\n\n";

  # Add all the entries
  foreach (@attrEntries) {

		my $filter 	= ($_ eq $ccVersionName) ? "appversion" : "nsf";
    my $pattern = "$_ filter=$filter text eol=lf\n";
    print GITATTR $pattern;

  }

  # print our Section finish marker
  print GITATTR "\n$cfgFinishMark\n\n";

  # close the file
  close (GITATTR);

  print "\nGit Attributes entries are now installed\n\n";

}

sub uninstallAttr {

  my ($silent) = @_;

  if (!$silent) {
    heading("Uninstall Git Attributes entries");
    print "Uninstall Attributes\n";
    return 0 if !confirmContinue();
  }

  # tell sed to remove all lines between our Section start/finish markers in the attributes file
  my @sedargs = ('-i', "/$cfgStartMark/,/$cfgFinishMark/d", $attrFile);  
  system('sed', @sedargs);
  
}

sub checkAttr {

  open (GITATTR, "<$attrFile");
  my @fileLines = <GITATTR>;
  close GITATTR;

  foreach (@attrEntries) {

		my $filter = ($_ eq $ccVersionName) ? "appversion" : "nsf";
	
    my $pattern = "$_ filter=$filter text eol=lf";

    my @matchedLines = grep /\Q$pattern\E/,@fileLines;

    if (!@matchedLines) {
      return 0;
    }
    
  }

  return 1;

}

sub installIgnore {

  heading("Initialise Git Ignore File");

  print "This step will update the .gitignore file in the root of the current repository.\n";
  print "It will ignore some files.\n\n";

  return 0 if !confirmContinue();

  # Remove previously installed entries
  uninstallIgnore(1);

    # Add to gitattributes file
    open (GITATTR, ">>$ignoreFile");

    print GITATTR "\n$cfgStartMark\n\n";

    foreach (@ignoreEntries) {
      print GITATTR "$_\n";
    }

    print GITATTR "\n$cfgFinishMark\n\n";

    close (GITATTR);

    print "\nGit Ignore entries are now installed\n\n";

}

sub uninstallIgnore {

  my ($silent) = @_;

  if (!$silent) {
    heading("Uninstall the gitignore entries");
    print "Uninstall the gitgnore entries\n";
    return 0 if !confirmContinue();
  }

  my @sedargs = ('-i', "/$cfgStartMark/,/$cfgFinishMark/d", $ignoreFile);
  system('sed', @sedargs);

}

sub checkIgnore {

  open (GITIGNORE, "<$ignoreFile");

  my @ignoreFileLines = <GITIGNORE>;

  close GITIGNORE;

  foreach (@ignoreEntries) {

    my $pattern = "$_";
    my @ignoreMatches = grep /\Q$pattern\E/,@ignoreFileLines;

    if (!@ignoreMatches) {
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

	# Return the Target Source Path of the XSL Stylesheet
	return "$hookTargetDir/$file";

} 

sub getCCTarget {

	# get input parameter
	my ($srcFile) = @_;

	# get full path of Source Binary
	my $ccSource = "$ccSourceDir/$srcFile";

	# Determine the FileName of the Stylesheet
	my ($volume, $directories, $file) = File::Spec->splitpath($ccSource);

	# Return the Target Source Path of the XSL Stylesheet
	return "$ccTargetDir/$file";

} 

sub installHooks {
  
  my ($silent) = @_;
	my $hookSource 	= '';
	my $hookTarget	= '';
	my $hookExist  	= 0;

  heading("Install Hooks to this Repository");

  print "This step will install the Hooks from:\n\n";
  colorSet("bold white");
  print "$hookSourceDir\n\n";
  colorReset();
  print "Into the:\n\n";
  colorSet("bold white");
  print "$hookTargetDir/\n\n";
  colorReset();
  print "directory in the current repository.\n";

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

  return 0 unless confirmContinue();
  
  # Check if the Home Bin directory exists
  if (!-d $hookTargetDir) {
		die "Error: $hookTargetDir does not exist!";	
  }
  
  foreach(@hookSourceFilenames) {

    my $hookSource = "$hookSourceDir/$_";

    if (-e $hookSource) {

      my $hookTarget = getHookTarget($_);

      # Copy the hook file to the Target Directory
      use File::Copy;

      copy($hookSource, $hookTarget) or die "Failed Copying: $!\n";
	    printFileResult($hookTarget, "Installed", 1);

    } else {
			printFileResult($hookTarget, "File not found", -1);
    }

  }

}

sub installDefCCVersion {

	heading("Install Default App Version Custom Control");

	print "This step will install the Default Custom Control for displaying the current\n";
	print "app version and branch name. You can customise the custom control to your liking\n";
	print "after installation\n";
	print "The default Custom control (and it's .xsp-config file) will be installed to \n\n";
	
	colorSet("bold white");
	print "$ccVersion\n";
	print "$ccVersionCfg\n\n";
	colorReset();

	print "If the ";
	colorSet("bold white");
	print $ccVersionDir;
	colorReset();
	print " does not exist it will be attempted to be created\n";

	if (-e $ccVersion) {
		colorSet("yellow");
		print "\nYou already have a file named $ccVersion in your repo. If you continue this will overwrite that file.\n";
		colorReset();
	}

	return 0 unless confirmContinue();

  # Check if the Custom Control directory exists
  if (!-d $ccTargetDir) {

		if (!mkdir $ccTargetDir) {
			die "Error: $ccTargetDir does not exist!";
		}

  }
  
  foreach(@ccSourceFilenames) {

    my $ccSource = "$ccSourceDir/$_";

    if (-e $ccSource) {

      my $ccTarget = getCCTarget($_);

      # Copy the cc file to the Target Directory
      use File::Copy;

      copy($ccSource, $ccTarget) or die "Failed Copying: $!\n";
	    printFileResult($ccTarget, "Installed", 1);

    } else {
			printFileResult($ccSource, "File not found", -1);
    }

  }

}

sub uninstallHooks {
 
  my ($silent) = @_;
	my $hookSource = '';
	my $hookTarget	= '';
	my @hookExist = ();

  if (!$silent) {
    heading("Uninstall the Hooks");
    print "Uninstall Hooks\n";
    return 0 if !confirmContinue();
  }

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
				printFileResult($hookTarget,"Removed",-1);
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

sub installEverything {

  installFilter();
  installXSL();
  installIgnore();
  installAttr();
	installHooks();
	installDefCCVersion();

}

sub uninstallEverything {
  
  uninstallFilter();
  uninstallXSL();
  uninstallIgnore();
  uninstallAttr();
	uninstallHooks();

}

sub showFilterImpurities {

  my ($testFile) = @_;

  # Fail if the Test File does not exist
  die "$testFile not found: $!" unless (-e $testFile);

  # Get the location of the XSL Stylesheets
  my $xslPrettyTarget = getXSLTarget($xslPrettyFilename);
  my $xslFilterTarget = getXSLTarget($xslFilterFilename);
  
  # Fail if one of the XSL Stylesheets do not exist
  die "XSL Stylesheet not found: $!" unless (-e $xslPrettyTarget & -e $xslFilterTarget);

  # Store the XSLT results into the git repo as blobs so they can be diff'd
  # Keep the SHA1 hash references for use in git diff
  my $blobNormal    = `xsltproc.exe $xslPrettyTarget $testFile | git hash-object -w --stdin`;
  my $blobFiltered  = `xsltproc.exe $xslFilterTarget $testFile | git hash-object -w --stdin`;
  
  # Remove Line endings
  chomp($blobNormal);
  chomp($blobFiltered);

  print "Normal Blob  : $blobNormal\nFiltered Blob: $blobFiltered\n" if ($verbose);
  
  # Run the git diff command on the 2 blobs
  my @args = ('diff',$blobNormal,$blobFiltered);
  system('git',@args);

}

sub showFilterResult {

  my ($testFile) = @_;

  # Fail if the Test File does not exist
  die "$testFile not found: $!" unless (-e $testFile);

  # Get the location of the XSL Stylesheets
  my $xslFilterTarget = getXSLTarget($xslFilterFilename);
  
  # Fail if one of the XSL Stylesheets do not exist
  die "XSL Stylesheet not found: $!" unless (-e $xslFilterTarget);

  # Run the git diff command on the 2 blobs
  my @args = ($xslFilterTarget,$testFile);
  system('xsltproc.exe',@args);

}

sub deflateFile {
  
  my ($testFile) = @_;

  # Fail if the Test File does not exist
  die "$testFile not found: $!" unless (-e $testFile);

  # Get the location of the XSL Stylesheets
  my $xslDeflateTarget = getXSLTarget($xslDeflateFilename);
  
  # Fail if one of the XSL Stylesheets do not exist
  die "XSL Stylesheet not found: $!" unless (-e $xslDeflateTarget);
 
  print "$tmpDir\n";

  my $tmpFile = "$tmpDir/dxldeflate.tmp";

  # Run the git diff command on the 2 blobs
  my @args = ('-o', $tmpFile, $xslDeflateTarget,$testFile);
  system('xsltproc.exe',@args);

  if ($? == -1) {
    print "xsltproc.exe could not be run\n";
  } else {

    my $exitCode = $? >> 8;

    print "exit code: $exitCode\n"

  }

  use File::Copy;
  
  copy($tmpFile, $testFile) or die "Failed to replace file: $!\n";
  printFileResult($testFile, "Deflated", 1);

  unlink($tmpFile) or warn "Could not remove temp file: $!\n";

}

# Updates the version number and Branch in the ccAppVersion custom control
# assumes that it is already set up
sub refreshAppVersion {

	# Fail if we can't find the Custom Control to update
	die "Could not find $ccVersion" 									unless (-e $ccVersion);
	die "Could not find Temp Dir $tmpDir" 						unless (-d $tmpDir);
	die "Could not find Versioner XSL $xslVersioner" 	unless (-e $xslVersioner);

	my $appVersion 	= `git describe 2>/dev/null`;
	my $currBranch	= `git rev-parse --abbrev-ref HEAD 2>/dev/null`;

	chomp $appVersion;
	chomp $currBranch;

	my $tmpFile = "$tmpDir/doraVersioner.tmp";

	my @args = (
		"-o",
		$tmpFile,
		"--stringparam",
		"sourceVersion",
		$appVersion,
		"--stringparam",
		"sourceBranch",
		$currBranch,
		$xslVersioner,
		$ccVersion
	);

	system('xsltproc.exe',@args);
	
	if ($? == -1) {
		die "xsltproc.exe could not be run\n";
	} else {
		handleXSLTExit($?);
	}

	use File::Copy;
	copy($tmpFile, $ccVersion) or warn "Failed to copy file: $!\n";
	unlink($tmpFile) or warn "Could not remove temp file: $!\n";

}

sub handleXSLTExit {

	my ($exitVal) = @_;

	my $exitCode = $exitVal >> 8;

	if ($exitCode == 0) {
		return $exitCode;
	} elsif ($exitCode == 1) {
		print "no argument\n";
	} elsif ($exitCode == 2) {
		print "too many arguments\n";
	} elsif ($exitCode == 3) {
		print "unknown option\n";
	} elsif ($exitCode == 4) {
		print "failed to parse the stylesheet\n";
	} elsif ($exitCode == 5) {
		print "error in the stylesheet\n";
	} elsif ($exitCode == 6) {
		print "error in one of the documents\n";
	} elsif ($exitCode == 7) {
		print "unsupported xsl:output method\n";
	} elsif ($exitCode == 8) {
		print "string parameter contains both quote and double-quotes\n";
	} elsif ($exitCode == 9) {
		print "internal processing error\n";
	} elsif ($exitCode == 10) {
		print "processing was stopped by a terminating message\n";
	} elsif ($exitCode == 11) {
		print "Could not write the result to the output file\n";
	}
	return $exitCode;

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

sub printFileResult {

  my ($filename, $resultdesc, $indicator) = @_;

  printf("%-40s ...", $filename);

  colorSet("bold green")  if ($indicator == 1);
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

    exit 0    if ($opt =~ m/^q/i);
    return 1  if ($opt =~ m/^y/i || $opt eq "");
    return 0  if ($opt =~ m/^n/i);

    $invalid = 1;

  }

}


# END TERMINAL HELPER FUNCTIONS

sub trackDbProps {

  my ($track) = @_;

  my $flag = ($track) ? "--no-assume-unchanged" : "--assume-unchanged";

  my @args = (
    'update-index', 
    $flag, 
    'nsf/AppProperties/database.properties', 
    'nsf/Resources/IconNote', 
    'nsf/AppProperties/xspdesign.properties'
  );

  system('git', @args);

}

sub finish {

  heading("Setup Complete");
  print "Details of action performed\n\n";

  print "You can check the result of the setup using the following commands:\n\n";
  print "Check the git config:\n";
  print "git config --list | grep nsf\n\n";

  print "Check the git attributes file for the file associations\n";
  print "grep nsf .gitattributes\n\n";

}

sub processArgs {

  my $numArgs = $#ARGV + 1;

  foreach my $argnum (0 .. $#ARGV) {

    if ($ARGV[$argnum] eq '--no-color') {

      $useColours = 0;

    } elsif ($ARGV[$argnum] eq '--test-filter' | $ARGV[$argnum] eq '-t') {

      my $testFile = $ARGV[$argnum + 1];

      die "Please specify a file." unless ($testFile);

      if (!-e $testFile) {
        die "$testFile does not exist";
      }

      showFilterResult($testFile);
      exit 0;

    } elsif ($ARGV[$argnum] eq '--show-impurities' | $ARGV[$argnum] eq '-im') {

      my $testFile = $ARGV[$argnum + 1];

      die "Please specify a file." unless ($testFile);

      if (!-e $testFile) {
        die "$testFile does not exist";
      }

      showFilterImpurities($testFile);
      exit 0;

    } elsif ($ARGV[$argnum] eq '--deflate-file' | $ARGV[$argnum] eq '-df') {

      my $testFile = $ARGV[$argnum + 1];

      die "Please specify a file." unless ($testFile);

      if (!-e $testFile) {
        die "$testFile does not exist";
      }

      deflateFile($testFile);

      exit 0;

    } elsif ($ARGV[$argnum] eq '--update-attributes') {

      updateGitAttributes();
      exit 0;

    } elsif ($ARGV[$argnum] eq '--update-ignore') {

      updateGitIgnore();
      exit 0;

    } elsif ($ARGV[$argnum] eq '--dbprops-on') {

      trackDbProps(1);
      exit 0;

    } elsif ($ARGV[$argnum] eq '--dbprops-off') {

      trackDbProps(0);
      exit 0;

    } elsif ($ARGV[$argnum] eq '-v') {
      
      $verbose = 1;

		} elsif ($ARGV[$argnum] eq '--refresh-app-version') {
			
			refreshAppVersion();
			exit 0;
			
    } else {

      die "Invalid Argument: $ARGV[$argnum]";

    }

  }

}

sub checkRepoSetup {

  if(checkInGitRepo()) {

    # Check the Filter is installed
    $chkFilter  = checkFilter();
    #check Git Attributes
    $chkAttr    = checkAttr(); 
    #check Git Ignore
    $chkIgnore  = checkIgnore(); 
    #check XSL File
    $chkXSL     = checkXSL();
		#check Hooks
		$chkHooks		= checkHooks();
  } else {
    $chkFilter  = 0;
    $chkAttr    = 0;
    $chkIgnore  = 0;
    $chkXSL     = 0;
		$chkHooks		= 0;
  }

}



sub menu {


  while (1) {

    checkRepoSetup();

 		mycls();

		heading($productNameLong);

	  if ($gitDir eq "") {
			menuNonGitRepo();
	  } else {
			menuGitRepo();
  	}

	  print "\n";
	  menuOption("q", "quit");
	  print "\n";

	  print "Enter Choice: ";
	  my $opt = <>;
	  chomp($opt);

	  exit 0 if $opt =~ m/^q/i;

		my $skipConfirmAnyKey = 0;

		if ($gitDir eq "") {
		
			if($opt eq "1") {
				mycls();
    		setupNewNSFFolder();
	  	}

		} elsif ($subMenu eq "main") {

			$subMenu = "install" 		if ($opt eq "1");
			$subMenu = "uninstall" 	if ($opt eq "2");

			$skipConfirmAnyKey = 1;

		} elsif ($subMenu eq "install") {
		
			if ($opt eq "1") {
    		mycls();
		    installEverything();
				$subMenu = "main";
			} elsif ($opt eq "2") {
    		mycls();
    		installFilter();
	  	} elsif($opt eq  "3") {
  	  	mycls();
    		installXSL();
	  	} elsif($opt eq  "4") {
  	  	mycls();
    		installIgnore();
	  	} elsif($opt eq  "5") {
  	  	mycls();
    		installAttr();
	  	} elsif($opt eq  "6") {
  	  	mycls();
    		installHooks();
				installDefCCVersion();
	  	} elsif($opt =~ m/^b/i) {
				$subMenu = "main";
				$skipConfirmAnyKey = 1;
			}
 
		} elsif ($subMenu eq "uninstall") {
  	
			if ($opt eq "1") {
    		mycls();
	    	uninstallEverything();    
				$subMenu = "main";
  		} elsif($opt eq  "2") {
    		mycls();
	    	uninstallFilter();
  		} elsif($opt eq  "3") {
    		mycls();
    		uninstallXSL();
	  	} elsif($opt eq  "4") {
  	  	mycls();
	    	uninstallIgnore();
  		} elsif($opt eq "5") {
   			mycls();
    		uninstallAttr();
	  	} elsif($opt eq "6") {
  	  	mycls();
    		uninstallHooks(); 
	  	} elsif($opt =~ m/^b/i) {
				$subMenu = "main";
				$skipConfirmAnyKey = 1;
			}
		}

   	confirmAnyKey() unless $skipConfirmAnyKey;

	}

}

sub menuNonGitRepo{

  menuOption("1", "Prepare a new Git repository for an NSF On-Disk Project...");
}

sub menuGitRepo {
	
		printGitRepoInstallSummary();

		menuGitMain() if $subMenu eq "main";
		menuGitInstall() if $subMenu eq "install";
		menuGitUninstall() if $subMenu eq "uninstall";
		
}

sub printGitRepoInstallSummary {

    print "------------------------------\n\n";
    printf("%-25s : ","Setup status for repo");
    colorSet("bold");
    print "$gitRepoDir\n";
    colorReset();

    printInstallStatus("DXL Filter",              $chkFilter);
    printInstallStatus("XSL Stylesheets",         $chkXSL);
    printInstallStatus(".gitignore entries",      $chkIgnore);
    printInstallStatus(".gitattributes entries",  $chkAttr);
		printInstallStatus("App Version Sync",				$chkHooks);

    print "\n------------------------------\n\n";

}

sub menuGitMain {
  menuOption("1", "Install   Something...");
  menuOption("2", "Uninstall Something...");
}

sub menuGitInstall {
  menuOption("1", "Install Everything for this Repository");
  print "-----\n";
  menuOption("2", "Install DXL Metadata Filter");
  menuOption("3", "Install XSL Stylesheets");
  menuOption("4", "Install .gitignore entries");
  menuOption("5", "Install .gitattributes entries");
	menuOption("6",	"Install App Version Sync");
  print "-----\n";
	menuOption("b", "Back to main menu");
 
}

sub menuGitUninstall {
  menuOption("1", "Uninstall Everything from this Repository");
  print "-----\n";
  menuOption("2", "Uninstall DXL Metadata Filter from .git/config");
  menuOption("3", "Uninstall XSL Stylesheets");
  menuOption("4", "Uninstall .gitignore entries");
  menuOption("5", "Uninstall .gitattributes entries");
	menuOption("6",	"Uninstall App Version Sync");
	print "-----\n";
	menuOption("b", "Back to main menu");
 
}

sub main {

  processArgs();

  menu();

  finish();

}

main();
