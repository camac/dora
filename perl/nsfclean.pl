#!/bin/perl

# <noteinfo noteid='382' unid='B6019B64DB57E233CA257B1D001448FB' sequence='19'>
# <created><datetime dst='true'>20130225T144134,03+11</datetime></created>
# <modified><datetime dst='true'>20130404T105017,77+11</datetime></modified>
# <revised><datetime dst='true'>20130404T105017,76+11</datetime></revised>
# <lastaccessed><datetime dst='true'>20130404T105017,77+11</datetime></lastaccessed>
# <addedtofile><datetime dst='true'>20130225T144134,04+11</datetime></addedtofile></noteinfo>
# <updatedby><name>CN=Cameron Gregor/O=JORD Engineers</name>
# <name>CN=Some Other Guy/O=JORD Engineers</name></updatedby>
# <wassignedby><name>CN=Cameron Gregor/O=JORD Engineers</name></wassignedby>

my $inNoteInfo = 0;

while (<>) {

    # Test to see if the current line is the start of the Note info
    # If so we replace the line by <noteinfo>
    # Note: this code could do with some improvement. It currently is only a weak test where the line starts with <noteinfo. 
    #       It does not cover the case where the closing tag is on the same line

    # Watch for the start of noteinfo
    if (s:^<noteinfo.*:<noteinfo>:) {
      print $_;
      $inNoteInfo = 1;
    }

    # watch for start of updated by
    if (m%^.*<updatedby(?:(?!updatedby).)+$%) {
      print "udpatedby start:\n";
    }

    if (m:(?!<updatedby>).*</updatedby>:) {
      print "udpdateby finish:\n";
    }


    if ($inNoteInfo) {

      #If this line is the closing tag for noteinfo, replace the line with the closing tag only
      if (s:.*</noteinfo>.*$:</noteinfo>:) {
        $inNoteInfo = 0;
        print $_;
      } 
    
    } else {

      # If we are not in the NoteInfo section, look to replace the other attributes/elements that we
      # don't want in the Repository

      # Replace Replica ID with nothing
      $_ =~ s:\s+replicaid='[A-Z0-9]+'::;

      # Replace the Version attribute of the note element, if the line matches '<note '
      if (m:^<note\s:) {
        $_ =~ s:\s+version='[\.\d]+'::;
      }

      # Remove the Updated by line
      $_ =~ s:<updatedby><name>.*</name></updatedby>::;

      # Remove the wassignedby line
      $_ =~ s:<wassignedby><name>.*</name></wassignedby>::;

      if ($_ ne "\n" && $_ ne "") {
        print $_; 
      }
    }

}

if ($inNoteInfo) {
  exit 1;
}

