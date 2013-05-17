#!/bin/perl

use strict;

package GitFiltersForNSF;

our $scriptDir = '~/GitFiltersForNSF/';

introduction();
checkInGitRepo();
specifyScriptDir();
addFiltersToGitConfig();
setSigner();
updateGitAttributes();
finish();


sub specifyScriptDir {

  # Check the location of the GitFiltersForNSF folder
  print "********** Script Location ************\n\n";
  print "Where have you put the GitFiltersForNSF scripts: \n\n";
  print "1. In the default directory under my HOME path accessibly by " . $scriptDir . "\n";
  print "2. I have placed them in a directory that is on the PATH environment variable\n";
  #print "3. I have placed them in a directory that will not be on the PATH environment variable\n";

  print "\nEnter Choice: ";

  my $opt = <>; 
  chomp($opt);

  exit 0 if $opt =~ m/^q/i;

    if ($opt eq "3") {

      print "Sorry this option is not supported yet!\n";
      exit 0;

    } elsif ($opt eq "2") {
      print "You chose 2\n";
      $scriptDir = "";
    } elsif ($opt eq "1" || $opt eq "") {
      print "You chose 1\n";
    } else {
      print "\nInvalid menu option\n";
      exit 0;
    }

}

sub checkInGitRepo {

  # make sure in we are in a Git Repo
  my @args = ('rev-parse','--git-dir');
  print "\nChecking if we are in a git repository: ";
  system('git',@args);
  print "\n";

  if ($? == -1) {
    print 'git rev-parse failed, please check Git is installed\n';
  } else {

    my $result = $? >> 8;

    if ($result != 0) {
      printf "\nNot in a Git Repo command exited with value %d\n", $result;
      exit -1;
    }

  }

}

sub addFiltersToGitConfig {

  print "\n*********** Add NSF Filter to Git Config ************\n\n";

  print "This step will add a new filter to the local .gitconfig file\n";
  print "It does this by adding two entries filter.nsf.clean and filter.nsf.smudge\n";
  print "These entries point to the location of 2 corresponding perl scripts in the GitFiltersForNSF directory\n\n"; 

  print "1. Add the nsf filter to local .gitconfig\n";
  print "2. Remove nsf filter from local .gitconfig\n";
  print "3. Skip this step\n";

  print "\nEnter Choice: ";

  my $setUpGitConfig = <STDIN>;
  chomp($setUpGitConfig);

  my @args = ();

  exit 0 if $setUpGitConfig =~ /^q/i;

  if ($setUpGitConfig eq "1" || $setUpGitConfig eq "") {

    my $cleanScript   = $scriptDir . 'nsfclean.pl';
    my $smudgeScript  = $scriptDir . 'nsfsmudge.pl';

    #TODO check the return status of these system commands

    @args = ('config','--local','filter.nsf.clean',$cleanScript);
    system('git',@args);

    @args = ('config','--local','filter.nsf.smudge',$smudgeScript);
    system('git',@args);

    @args = ('config','--local','filter.nsf.required','true');
    system('git',@args);

    print "\nAdded git filters\n";

  } elsif ($setUpGitConfig eq "2") {

    #TODO Check the return status of these system commands

    @args = ('config','--local','--unset','filter.nsf.clean');
    system('git',@args);

    @args = ('config','--local','--unset','filter.nsf.smudge');
    system('git',@args);

    print "\nRemoved Git Filters\n";

  }

}

sub setSigner {
  
  # Ask for behaviour to do with wassignedby Tag
  print "\n*********** Design Element Signer ***************\n\n";

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

sub updateGitAttributes {

  print "\n********* Associate File Extensions with Filter *************\n\n";

  print "This step will update the .gitattributes of the current repository.\n";
  print "It will associate certain files with the nsf filter that was configure in the .gitconfig file.\n\n";

  print "1. Add All Associations\n";
  print "2. Remove all associations\n";
  print "3. Skip this step\n";

  print "\nEnter Choice: ";

  my @exts = ('view','form','page','fa','ja','lsa','folder','column','field','outline','subform');
  my @file = ('AboutDocument','UsingDocument','IconNote');

  my $addAssoc = <>;
  chomp($addAssoc);

  exit 0 if $addAssoc =~ /^q/i;

  if ($addAssoc eq "1" || $addAssoc eq "") {

    # Add to gitattributes file
    open (GITATTR, '>>.gitattributes');

    foreach (@exts) {
      print GITATTR "*.$_ filter=nsf\n";
    }

    foreach (@file) {
      print GITATTR "$_ filter=nsf\n";
    }

    close (GITATTR);

  } elsif ($addAssoc eq "2") {

    #TODO Remove associations from the .gitattributes file

    print "\n\nNothing Done Here still need to code this\n\n";

  }

}

sub introduction {

  print "\n===================================\n";
  print " Git Filters for NSF setup script\n";
  print "-----------------------------------\n\n";

  print "This script will set up the Git Filters for NSF for the current Git Repository\n";
  print "The script will do the following:\n\n";

  print " * Add the 'nsf' clean and smudge filters to the local Git config file .gitconfig\n";
  print " * Associate the 'nsf' filter with form view page files etc. in .gitattributes\n";
  print " * Add your default signer as another variable in .gitconfig 'nsf.signer'\n";

  print "\nOption 1 is the default choice for all questions. Enter q to quit at any point.\n\n";

  print "Press Enter to begin: ";

  my $opt = <>;

  exit 0 if $opt =~ m/^q/i;
}

sub finish {

  print "\n\n\n******** Setup Complete **********\n\n";
  print "Details of action performed\n\n";


  print "You can check the result of the setup using the following commands:\n\n";
  print "Check the git config:\n";
  print "git config --list | grep nsf\n\n";

  print "Check the git attributes file for the file associations\n";
  print "grep nsf .gitattributes\n\n";



}
