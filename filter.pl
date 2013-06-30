#!/bin/perl


our $filterName = "";
our $fileName		= "";

# usage dora filter <filtername> [- | <filename>]

processArgs();

#retrieve the filter from the database to tmp file

exit 0;

sub runFilter {

	my $tmpFile = 'tempfile.xsl';

	if (!-e $filterName) {
		$output = `git cat-file blob $filterName > $tmpFile`;
	}

	#if (!-e $xslFilter) {
	#	exit -1;
	#}

	# Try Running XSLTProc
	my @args = ($tmpFile, '-');
	system('xsltproc', @args);

	# After running and checking exit codes, maybe cat it?
	warn("Source file is not well-formed XML, cat instead");


}

sub processArgs {

  my $numArgs = $#ARGV + 1;

	die "Incorrect Arguments" if $numArgs == 0;

  foreach my $argnum (0 .. $#ARGV) {

    if ($ARGV[0] eq 'filter') {

			die "Usage dora filter <filtername> <filename>\n" if $numArgs != 3;
			$filterName = $ARGV[1];
			runFilter();
			exit();

    } else {
			die "Incorrect Arguments\n";
		}

  }

}


