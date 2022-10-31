#!/bin/bash

#####################################################################
###    VARIÁVEIS COM INFORMAÇÕES DO SERVIDOR DE DOMÍNIO LOCAL     ###
#####################################################################
read -p "DIGITE O IP DO SERVIDOR DE DOMÍNIO: " VAR_IP_DC_LOCAL
read -p "DIGITE O DOMINIO LOCAL: " VAR_DOMINIO
read -p "DIGITE O APENAS O HOSTNAME DO SERVIDOR DE DOMÍNIO: " VAR_HOSTNAME_DC

################################################################
### CRIAR DIRETORIOS PARA STORAGE E FONTE DO SISTEMA MLAUDOS ###
################################################################
echo -e "\n "$vermelho" CRIANDO DIRETÓRIOS DE STORAGE E FONTE SISTEMA MLAUDOS "$branco" \n";
#atualizar biblioteca para sistema 64bits
mkdir -vp /STORAGE/

#####################################################################
### ADICIONAR SERVIDORES DE ARQUIVO E DOMINIO AO ARQUIVO DE HOSTS ###
#####################################################################
echo "${VAR_IP_DC_LOCAL}     ${VAR_HOSTNAME_DC}"."${VAR_DOMINIO_CLIENTE}      ${VAR_HOSTNAME_DC}" >> /etc/hosts

#####################################################################
###                  MONTAR PARTIÇÃO FÍSICA ext4                  ###
#####################################################################
echo -e "\n "$vermelho" MONTANDO DISCO STORAGE PACS dcm4chee "$branco" \n";
mount /dev/sdb1 /STORAGE

#######################################################################
###   PREPARAR ARQUIVOS PARA INICIALIZAÇÃO AUTOMÁTICA DOS SERVIÇOS  ###
#######################################################################
echo -e "\n "$vermelho" CONFIGURANDO INICIALIZAÇÃO AUTOMATICA DO DCM "$branco" \n";
cp -vfr /usr/local/src/dcmsetup/rundcm4chee.sh /etc/init.d/rundcm4chee.sh
chmod +x /etc/init.d/rundcm4chee.sh

mkdir -vp  /opt/jboss/log/ && touch  /opt/jboss/log/jboss.log
chmod -R 777 /opt/jboss/

##########################################################################
###  REESCREVER RC.LOCAL COM OS COMANDOS DE INICIALIZAÇÃO NECESSÁRIOS  ###
##########################################################################
cat > /etc/rc.local << EOF
#!/bin/sh -e

export JAVA_HOME=/usr/java/jdk1.7.0_80/
export PATH=$PATH:/usr/java/jre1.7.0_80/bin
/etc/init.d/rundcm4chee.sh start
exit 0
EOF

###################################################################################
### COPIAR ARQUIVO DE COMPACTAÇÃO E SETAR CRONTAB PARA RODAR A CADA 2 MINUTOS ###
###################################################################################
cp -vfr /usr/local/src/dcmsetup/ZIPAR.sh /usr/local/bin/ZIPAR.sh
chmod +x  /usr/local/bin/ZIPAR.sh
sed -i "s/VAR_NOME_CLIENTE/${VAR_NOME_CLIENTE}/g" "/usr/local/bin/ZIPAR.sh"
crontab -l; (echo "*/5 * * * * /usr/local/bin/ZIPAR.sh 2>&1") | crontab -

echo -e "\n "$vermelho" INSTALAÇÃO DCM4CHEE CONCLUÍDA COM SUCESSO "$branco" \n";
echo -e "\n "$vermelho" NECESSÁRIO CONFIGURAR "$amarelo" JMX-CONSOLE "$vermelho" PARA CONCLUIR A INSTALAÇÃO "$branco" \n";
echo -e "\n "$amarelo" REINICIANDO SERVIDOR "$branco" \n";
sleep 5

init 6
