#!/bin/bash

# script de restauration

# Dernier dossier ajouté
LAST_FILE=`cd /home/philippe/backups && ls -td -- * | head -n 1`

# FTP 
FTP_USER='philippe'
FTP_ADDRESS='192.168.2.5'
DESTINATION='/home/philippe/tmp'

# Envoi de ce dossier vers le nouveau serveur
function send() {
	cd /home/philippe/backups
	sftp $FTP_USER@$FTP_ADDRESS:$DESTINATION <<< $'put '$LAST_FILE
}

function extract() {
	ssh $FTP_USER@$FTP_ADDRESS 'cd /home/philippe/tmp;FILE=`ls`;tar -xzvf $FILE'
}

function restore() {
	ssh $FTP_USER@$FTP_ADDRESS #mysql -u philippe db_wordpress < /home/philippe/tmp/www/database/*.sql'
	ssh $FTP_USER@$FTP_ADDRESS rm -R /home/philippe/tmp/www/database'
	ssh $FTP_USER@$FTP_ADDRESS cp /home/philippe/tmp/www/* /var/www/wordpress/ -R'
}

function clean() {
	ssh $FTP_USER@$FTP_ADDRESS 'rm -R /home/philippe/tmp/*'
}

send
extract
restore
clean
