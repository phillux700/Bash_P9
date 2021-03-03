#!/bin/bash

# Script de réinitialisation du post de test pour la démo du projet 9

reset() {
	rm -rf /var/www/wordpress/*
	mysql -u philippe -e 'DROP DATABASE db_wordpress' 
	mysql -u philippe -e 'CREATE DATABASE db_wordpress' 
}

reset
