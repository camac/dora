#!/bin/perl
#
## Steps to success
#
# Read STDIN to a variable

my $binDir  = "c:/Users/cgregor/bin"; # This is the folder location of your xsltproc binaries
my $xslFile = "d:/DominoGit/dorabadxml/xsl/DXLClean.xsl"; # This is the filelocation of the xsl filter to be used TODO make program argument

my $contents;

while (<>) {
  $contents .= $_; 
}
open(LINT, "| $binDir/xmllint --noout --nowarning - 2>/dev/null") || die "Could not execute the xmllint program\n";

print LINT $contents;

if (close(LINT)) {

#  print "Went through the linter ok\n";

  open(XSLTPROC, "| $binDir/xsltproc $xslFile -") || die "Could not execute the xsltproc program\n";

  print XSLTPROC $contents;

  close(XSLTPROC);

} else {

#  print "Linter wasn't happy\n";
  print $contents;

}

# Check error code of STDIN through xmllint
#
# if ok, run through xlstproc
#
# if not ok, just print contents out
