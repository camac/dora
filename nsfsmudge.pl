#!/bin/perl

@args = ('config','--get','nsf.signer');
system('git',@args);

if ($? == -1) {
  
} else {

  $result = $? >> 8;

  if ($result != 0) {
    #exit 1;
  }

}

$signer = 'git config --get nsf.signer';

while (<>) {

  
     # Test to see if the current line is the start of the Note info
    # If so we replace the line by <noteinf>
    # Note: this code could do with some improvement. It currently is only a weak test where the line starts with <noteinfo. 
    #       It does not cover the case where the closing tag is on the same line
    if (s:^<noteinfo.*:<noteinfo>:) {
      print $_;
      $inNoteInfo = 1;
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

    #Replace the Signer with your signer
    $_ =~ s:<wassignedby><name>(.*)</name></wassignedby>:<wassignedby><name>$signer</name></wassignedby>/:;

    print $_;

}
