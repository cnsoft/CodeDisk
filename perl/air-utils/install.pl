use strict;
use FindBin qw/$Bin/;
#read configs
my $config = $ARGV[0] ||$Bin .  "/adt.ini";
open(F, '<',  $config);
my $config_content = join "", <F>;
close F;
my $rh_config = {};
read_config();
sub read_config {
    while ($config_content =~ m{(.*)=(.*)}g){
        my $k = $1;
        my $v  = $2;
        if ($k =~ m{^#}){
            next;
        }
        if ($rh_config->{DIR} && $rh_config->{PROJECT}){
            my $dir = $rh_config->{DIR};
            my $project = $rh_config->{PROJECT};
            $v =~ s{\$DIR}{$dir}g;
            $v =~ s{\$PROJECT}{$project}g;
        }
        $rh_config->{$1} = $v;
    }

    if ($rh_config->{'listen'}){
        $rh_config->{target} =  $rh_config->{target} .' -listen ' . $rh_config->{'listen'};
    }
}


    my $device_cmd = $rh_config->{idb}. ' -devices';
    my $devices_str =`$device_cmd`;
    my $handler = 3;
    if ($devices_str =~ m{\s+(\d+)\s+}) {
        $handler = $1;
        print "handler:" . $handler . "\n";
    }

    my $uninstall_cmd = $rh_config->{install_adt} .' -uninstallApp -platform ios -appid ' .$rh_config->{app_id} .' -device ' .$handler ; 
    my $install_cmd =  $rh_config->{install_adt} .' -installApp -platform ios -package ' .$rh_config->{ipa} .' -device ' .$handler ;  
    print $uninstall_cmd ."\n";
    system($uninstall_cmd);
    print $install_cmd ."\n";
    system($install_cmd);


__END__
"C:\Program Files\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\bin\adt"  -package -target ipa-test-interpreter -provisioning-profile luodx.mobileprovision -storetype pkcs12 -keystore luodx.p12 -storepass 1234 Main.ipa testmobileane4-app.xml testmobileane4.swf -extdir ext