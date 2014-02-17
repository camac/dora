#!/bin/perl
#

our $homeDir    = $ENV{"HOME"};
our $binDir     = "$homeDir/bin"; # This is the folder location of your xsltproc binaries
our $xslFile    = ""; 
our $debug      = 0;

processArgs();

print $binDir   if ($debug);
print $xslFile  if ($debug);

my $contents;

while (<STDIN>) {
  $contents .= $_; 
}

open(LINT, "| $binDir/xmllint --noout --nowarning - 2>/dev/null") || die "Could not execute the xmllint program\n";

print LINT $contents;

if (close(LINT)) {

  print "Went through the linter ok\n" if ($debug);

  open(XSLTPROC, "| $binDir/xsltproc $xslFile -") || die "Could not execute the xsltproc program\n";

  print XSLTPROC $contents;

  close(XSLTPROC);

} else {

  print "Linter wasn't happy\n" if ($debug);
  print $contents;

}

sub usage {

  print "\n$projNameLong Filter Script\n\n";
  print "doraFilter.pl xslFile [--libxsltDir DIRECTORY]\n\n";
  print "  --help\n\n";
  print "            Show this help screen\n\n";
  print "  --libxsltDir [DIRECTORY]\n\n";
  print "            Location of Directory with libxslt binaries. defaults to %HOME%/bin\n\n";
  print "  --debug\n\n";
  print "            outputs debugging print statements. Warning! will end up in contents of files\n\n";
  print "  xslFile  [FILE]\n\n";
  print "            Location of xslFile to be used for filtering\n\n";

  exit 0;

}

sub processArgs {

  my $numArgs = $#ARGV + 1;
  my $skipNext = 0;

  # Check for first argument 
  usage if ($ARGV[0] eq '--help');

  $xslFile = $ARGV[0];

  die ('DORA: xslFile could not be found') unless (-e $xslFile);

  foreach my $argnum (1 .. $#ARGV) {

    if ($skipNext eq 1) {
      $skipNext = 0;
      next;
    }

    if ($ARGV[$argnum] eq '--libxsltDir') {
      $binDir = $ARGV[$argnum + 1];
      die ('DORA: libxsltDir could not be found') unless (-d $binDir);
      #TODO Strip trailing slash if there
      $skipNext = 1;
    }

    if ($ARGV[$argnum] eq '--debug') {
      $debug = 1;
    }
    
  }

}
