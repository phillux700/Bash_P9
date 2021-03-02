#!/bin/bash

# Script de rotation des fichiers de sauvegarde

cd /home/philippe/backups
find . -cmin +300 rm -rf {} \;
