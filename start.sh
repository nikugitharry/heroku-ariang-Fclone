#!/bin/bash

export PATH="$(cat PATH)"

if [[ -n $RCLONE_DESTINATION ]]; then
	echo "Rclone config detected"
	echo -e "$RCLONE_CONFIG" > rclone.conf
	echo -e "$UNPACK_PASSWORDS" > /app/passwds.txt
	echo "on-download-complete=./on-complete.sh" >> aria2c.conf
	echo "on-download-stop=./on-stop.sh" >> aria2c.conf
	chmod +x on-complete.sh
	chmod +x on-stop.sh
	chmod +x unpack.sh
	chmod +x complete.sh
fi

wget --no-check-certificate -q $SA_ZIP_URL -O accounts.zip
unzip -qq accounts.zip -d /app/
rm -rf accounts.zip

echo "
[Google]
type = drive
scope = drive
service_account_file = /app/accounts/$SA_INIT_FILE
service_account_file_path = /app/accounts/
" >> rclone.conf

echo -e "$SHELL_ON_COMPLETE" >> complete.sh


echo "rpc-secret=$ARIA2C_SECRET" >> aria2c.conf
aria2c -q --conf-path=aria2c.conf&
yarn start
