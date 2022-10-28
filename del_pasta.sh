#!/bin/bash

read -p "Digite o nome do serviço que deseja remover do sistema: " serviceName
find / -name *$serviceName* > /tmp/del_dir

echo "================ REMOVENDO VIA APT ================"
apt remove -f $serviceName -y

echo "================ PURGE VIA APT ================"
apt purge -f $serviceName -y

echo "================ AUTOREMOVENDO VIA APT ================"
apt autoremove -y

arquivo="/home/ls/dio-devops/del_dir"
#cat $arquivo

while read -r linha; do
	chmod 777 -R $linha
	rm -rf $linha
	echo "O caminho $linha foi apagado com sucesso"
done < "$arquivo"

rm /temp/del_dir
