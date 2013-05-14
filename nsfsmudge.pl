#!/bin/perl

@args = ('config','--get','nsf.signer');
system('git',@args);

if ($? == -1) {
  
} else {

  $result = $? >> 8;

  if ($result != 0)

}

$signer = 'git config --get nsf.signer';

while (<>) {

   
    #Replace the Signer with your signer
    $_ =~ s:<wassignedby><name>(.*)</name></wassignedby>:<wassignedby><name>$signer</name></wassignedby>/:;

    print $_;

}
