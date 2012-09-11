use strict;
use FindBin qw/$Bin/;
 use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

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



#extract from zip
my $tmp_dir = $rh_config->{ane_path} . "/tmp_ane" . time();
my $iphone_arm_dir = $tmp_dir . '/iPhone-ARM';
mk_dir($tmp_dir);
mk_dir($iphone_arm_dir);

copy_file($rh_config->{ane_path} . "/" . $rh_config->{ane_swc}, $tmp_dir);

#my $extractor = Archive::Extract->new( archive => $tmp_dir 'file.zip' );
my $swc_path = $tmp_dir . '/' . $rh_config->{ane_swc};
my $somezip = Archive::Zip->new();
unless ( $somezip->read( os_path($swc_path) ) == AZ_OK ) {
   die 'read error';
}
my @members = $somezip->members();

my @memberNames = $somezip->memberNames();
#unzip files from *.swc, copy to => iphone_arm_dir/
for my $name(@memberNames) {
    save_file($iphone_arm_dir.'/' . $name, $somezip->contents($name));
}

#copy xxx.a -> iphone_arm_dir/
copy_file($rh_config->{ane_path} . "/" .$rh_config->{native_lib}, $iphone_arm_dir.'/');


#write extension.xml
my $ane_id = $rh_config->{ane_id};
my $native_lib = $rh_config->{native_lib};
my $extension_xml = qq#<extension xmlns="http://ns.adobe.com/air/extension/3.3">
        <id>$ane_id</id>
        <versionNumber>1</versionNumber>
        <platforms>
                <platform name="iPhone-ARM">
                        <applicationDeployment>
                                <nativeLibrary>$native_lib</nativeLibrary>
                                <initializer>ExtInitializer</initializer>
                                <finalizer>ExtFinalizer</finalizer>
                        </applicationDeployment>
                </platform>
        </platforms>
</extension>
#;
save_file($tmp_dir.'/extension.xml', $extension_xml);

#start adt-> make ane
my $ane_file_name = $rh_config->{ane};
#$ane_file_name =~ s{\.a}{.ane};

my $cmd =  $rh_config->{adt} . " -package " . ' -storetype pkcs12 ' . ' -keystore ' . $rh_config->{ane_p12} . ' -storepass ' . $rh_config->{ane_password} . ' -target ane ' . $ane_file_name . '  extension.xml -swc ' . $rh_config->{ane_swc} . ' -platform iPhone-ARM -C iPhone-ARM . ';

print $cmd . "\n";

system("del " . $ane_file_name);
chdir(os_path($tmp_dir));
print "change workingdir->" . os_path($tmp_dir). "\n";
system($cmd);

print "done...\n";

chdir($Bin);

system("rd /s /Q ". os_path($tmp_dir));

sub save_file {
    my $path = shift;
    my $content = shift;
    $path = os_path($path);
    open(F, '>', $path);
    binmode F;
    print F $content;
    close F;
}
sub os_path {
    my $path = shift;
    $path =~ s{\"}{}igs;
    $path =~ s{\/}{\\}gis;
    return $path;
}

sub copy_file {
    my $source = shift;
    my $target = shift;
    #windows 平台复制
    my $cmd =   $source. " " . $target;
    $cmd = os_path($cmd);
    $cmd = 'copy /Y ' .$cmd;
    print $cmd ."\n";
    system($cmd);
}

sub mk_dir {
    my $dir = shift;
    #windows 平台复制
    $dir = os_path($dir);
    print $dir ."\n";
    mkdir($dir);

}


__END__

"C:\Program Files\Adobe\Adobe Flash Builder 4.6\sdks\4.6.0\bin\adt"  -package -storetype pkcs12 -keystore luodx_new.p12 -storepass 1234 -target ane com.luodx.ANELib1.ane extension.xml -swc testane2.swc -platform iPhone-ARM -C iPhone-ARM . 

<extension xmlns="http://ns.adobe.com/air/extension/3.3">
        <id>com.luodx.ANELib1</id>
        <versionNumber>1</versionNumber>
        <platforms>
                <platform name="iPhone-ARM">
                        <applicationDeployment>
                                <nativeLibrary>libtestane.a</nativeLibrary>
                                <initializer>ExtInitializer</initializer>
                                <finalizer>ExtFinalizer</finalizer>
                        </applicationDeployment>
                </platform>
        </platforms>
</extension>