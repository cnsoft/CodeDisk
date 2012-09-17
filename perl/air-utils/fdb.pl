use strict;
use FindBin qw/$Bin/;
#read configs
my $config = $ARGV[0] ||$Bin .  "/adt.ini";
open(F, '<',  $config);
my $config_content = join "", <F>;
close F;

my $rh_config = {};
while ($config_content =~ m{(.*)=(.*)}g){
    my $k = $1;
    if ($k =~ m{^#}){
        next;
    }
    $rh_config->{$1} = $2;
}

#get devices
my $cmd = $rh_config->{idb}. ' -devices';
my $devices_str =`$cmd`;
my $handler = 3;
if ($devices_str =~ m{\s+(\d+)\s+}) {
    $handler = $1;
    print "handler:" . $handler . "\n";
}
#forward
my $pid = fork;
if ($pid == 0) {
   # child gets PID 0
   my $cmd = $rh_config->{idb}. ' -forward ' . $rh_config->{'listen'}. ' ' . $rh_config->{'listen'} . ' ' . $handler ;
   print "fork:" . $cmd . "\n";
   system($cmd);
   
    #exec(@_) || die "Can't exec $_[0]";
} else {
    sleep(2);
    my $cmd = $rh_config->{fdb} . " -p " . $rh_config->{'listen'};
    print $cmd . "\n";
    system($cmd);
}


