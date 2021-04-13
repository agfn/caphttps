#!/bin/bash

# certificate in DER format
cer=${1}
if [[ ! -f $cer ]]; then
	echo "$cer" not found
	exit
fi

# prepare certificate
pem_file=`date +"%s"`
openssl x509 -in $cer -inform der -out /tmp/$pem_file
		
# using default adb  
if [[ ! $ADB ]]; then ADB=adb; fi

CMD="$ADB shell"

# check has /data/local/tmp/cacerts/ path
if [[ ! `$CMD ls /data/local/tmp/cacerts/` ]]; then
	echo /data/local/tmp/cacerts not prepared
	$CMD cp -r /system/etc/security/cacerts/ /data/local/tmp/	
fi

cer_name=`openssl x509 -in $cer -inform der -subject_hash_old -noout`

echo send certificate to remote device
$ADB push /tmp/$pem_file /data/local/tmp/cacerts/$cer_name.0

$CMD chmod 644 /data/local/tmp/cacerts/$cer_name.0

rm /tmp/$pem_file

# check if cacerts mounted
if [[ ! "`$CMD mount | grep /system/etc/security/cacerts`" ]]; then
	echo cacerts not mounted, try to mount
	$CMD mount -o bind /data/local/tmp/cacerts/ /system/etc/security/cacerts
fi

echo all prepared, restart android framework
$CMD "stop && start"


