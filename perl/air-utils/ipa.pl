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

if ($rh_config->{'listen'}){
    $rh_config->{target} = "ipa-debug-interpreter -listen " . $rh_config->{'listen'};
}

my $cmd =  $rh_config->{adt} . " -package " . " -target " . $rh_config->{target}. ' -provisioning-profile ' . $rh_config->{'provisioning-profile'}. ' -storetype pkcs12 ' . ' -keystore ' . $rh_config->{p12} . ' -storepass ' . $rh_config->{password} . ' ' . $rh_config->{ipa} . ' ' . $rh_config->{files};

print $cmd ."\n";




system("del " . $rh_config->{ipa});
if ($rh_config->{path}){
    my $path = $rh_config->{path};
    $rh_config->{path} =~ s{\"}{}gis;
    chdir($rh_config->{path});
} else {
    
}

print system($cmd) . "\n";

__END__
"C:\Program Files\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\bin\adt"  -package -target ipa-test-interpreter -provisioning-profile luodx.mobileprovision -storetype pkcs12 -keystore luodx.p12 -storepass 1234 Main.ipa testmobileane4-app.xml testmobileane4.swf -extdir ext