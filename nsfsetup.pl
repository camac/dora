#!/bin/perl

$filtersDir = '~/GitNSFFilters';

introduction();

# make sure in we are in a Git Repo
@args = ('rev-parse','--git-dir');
print "\nChecking if we are in a git repository: ";
system('git',@args);
print "\n";

if ($? == -1) {
  print 'git rev-parse failed, please check Git is installed\n';
} else {


  $result = $? >> 8;

  if ($result != 0) {
    printf "\nNot in a Git Repo command exited with value %d\n", $result;
    exit -1;
  }

}

# Add to git config
print "Set up the Filter in git config? (y/n/q): ";
$setUpGitConfig = <STDIN>;
exit 0 if $setUpGitConfig =~ /^q/i;

if ($setUpGitConfig =~ m/^y/i) {

  @args = ('config','--local','filter.nsf.clean','nsfclean.pl');
  system('git',@args);

  @args = ('config','--local','filter.nsf.smudge','nsfsmudge.pl');
  system('git',@args);


} elsif ($setUpGitConfig =~ m/^n/i) {

  @args = ('config','--local','--unset','filter.nsf.clean');
  system('git',@args);

  @args = ('config','--local','--unset','filter.nsf.smudge');
  system('git',@args);
}

#git config filter.nsf.clean nsfclean.pl
#git config filter.nsf.smudge nsfsmudge.pl

# Ask for behaviour to do with wassignedby Tag
print "\n=======================\n";
print " Design Element Signer\n";
print "=======================\n";

print "Would you like to set the <wassignedby> field to a particular user on checkout? (y/n/q): ";

$useSigner = <STDIN>;

exit 0 if $useSigner =~ /^q/i;

if ($useSigner =~ m/^y/i) {

  print "\nThe NotesName will be saved in the local Git Config under the section nsf and variable signer (nsf.signer) \n";

  print "Please type the Common Name : ";
  $signerCN = <STDIN>;
  chomp($signerCN);
  $signerCN =~ s/^\s*(.*?)\s*$/$1/;

  print "Please type the Organisation: ";
  $signerOrg = <STDIN>;
  chomp($signerOrg);
  $signerOrg =~ s/^\s*(.*?)\s*$/$1/;

  $signer = "CN=" . $signerCN . "/O=" . $signerOrg;

  print "Signer will be set as a local git config variable nsf.signer as:\n";
  print "\"$signer\"" . "\n";
  print "Please confirm if ok (y/n): ";
  $confirm = <STDIN>;

  if ($confirm =~ m/^y/i) {
    $result = `git config --local nsf.signer "$signer"`;
  }

} elsif ($useSigner =~ m/^n/i) {

  @args = ('config','--local','--unset','nsf.signer');
  system('git',@args);

  if ($? == -1) {
    print 'git config command failed, please check Git is installed\n';
  } else {
  
    printf "command exited with value %d", $? >> 8;
  
    $result = $? >> 8;

    if ($result != 0 && $result != 5) {
      print "\nCould not unset the signer\n";
      exit -1;
    }

  }


}

print "\n======================\n";
print "Add Filters to Git Attributes file\n";
print "----------------------\n";
print "\nDo you want to associate the nsf filter with elements? (y/n/q): ";

$addAssoc = <>;

exit 0 if $useSigner =~ /^q/i;

if ($addAssoc =~ m/^y/i) {

  #TODO Test for existing of gitattributes file, touch if not there

  # Add to gitattributes file
  open (GITATTR, '>>.gitattributes');
  print GITATTR "*.view filter=nsf\n";
  print GITATTR "*.form filter=nsf\n";
  print GITATTR "*.page filter=nsf\n";
  close (GITATTR);

} elsif (m/^n/i) {

}

sub introduction {

  print "\n===============================\n";
  print " Git Filters for NSF\n";
  print "-------------------------------\n\n";

  print "This script will set up the Git Filters for NSF for the current Git Repository\n";


}
