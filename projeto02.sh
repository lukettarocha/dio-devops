#!/bin/bash

nomeArq='site-dio'
apacheDir='/var/www/html'

echo "============================ ATUALIZANDO O SERVIDOR ============================"
apt-get update $$ apt-get upgrade -y

apt install apache2 -y
apt install unzip -y

cd /tmp

echo "============================ BAIXANDO O REPOSITÓRIO  ============================"
wget https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip -O $nomeArq.zip

echo "============================ DESCOMPACTANDO O REPOSITÓRIO  ============================"
unzip "$nomeArq.zip" -d $nomeArq

echo "============================ COPIANDO PARA A PASTA PADRÃO DO APACHE ============================"
cd $nomeArq
nomeArq=`ls`
cp -r $nomeArq/* $apacheDir
cp -r $nomeArq $apacheDir

systemcl restart apache2
