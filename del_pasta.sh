#!/bin/bash

arquivo="/home/ls/del_pasta"
#cat $arquivo

while read -r linha; do
	chmod 777 -R $linha
	rm -rf $linha
	echo "O caminho $linha foi apagado com sucesso"
done < "$arquivo"
