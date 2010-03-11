#!/usr/bin/perl

# { $Id$}
# copyright by Jörg Vogt
# <joerg.vogt@online.de>


use Date::Format;
use Date::Manip;

use Net::HTTP;
use Time::HiRes qw (usleep ualarm gettimeofday tv_interval);

$Server="localhost";
$Port="10080";
$ServerDigitalPortAPI_Str="/digital/ReadInputValues.html?";
$logfile="./digital.output";

sub GetDPort {
#
#
#
       my $DPort=$_[0];
       my $s = Net::HTTP->new(Host => "$Server:$Port") || die $@;
       $s->write_request(GET => "$ServerDigitalPortAPI_Str$DPort", 'User-Agent' => "Mozilla/5.0");
       my($code, $mess, %h) = $s->read_response_headers;
       my $buf;
       my $n = $s->read_entity_body($buf, 1024);
       die "read failed: $!" unless defined $n;
       last unless $n;
       my $output = substr ($buf,13,48);
       return $output;

};

#####################################################################
# MAIN
#####################################################################
                                                                               
$FirstRun=1; $old_output="err";
while ($i==0) { 
    $output ="";
    #for ($I1=1;$I1<=3;$I1++) { $output = "$output".GetDPort ($I1)};
    $output = GetDPort ("1,2,3");
    if ($FirstRun) { $old_output=$output; $FirstRun=0;}
    if ( $old_output ne $output )
      {
        ($sec, $usec) = gettimeofday();
        $msec=sprintf "%3d",$usec/1000;
        $date=time2str("%d/%m/%Y  %T", $sec);;
        open (out,">>$logfile");
        print out "$date $msec -> ";
        print out $output;
        print out "\n";
        close out;
      };
    usleep (110_000);
    $old_output=$output;
 };

