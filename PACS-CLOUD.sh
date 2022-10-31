#!/bin/bash

#############
### CORES ###
#############
preto='\033[01;30m'
vermelho='\033[01;31m'
verde='\033[01;32m'
amarelo='\033[01;33m'
azul='\033[01;34m'
rosa='\033[01;35m'
ciano='\033[01;36m'
branco='\033[01;37m'

##############################
### DEFINIÃ‡ÃƒO DE VARIAVEIS ###
##############################
VAR_NOME_CLIENTE="LAB"
VAR_USER_CLIENTE="pacs.lab"
VAR_PASS_CLIENTE="Dcm@321852#"
VAR_DOMINIO_CLIENTE="lsdominio.local"
VAR_PASS_POSTGRES="321852"

####################################
### ATUALIZAR E INSTALAR PACOTES ###
####################################
echo -e "\n "$vermelho" INICIANDO A INSTALAÃ‡ÃƒO DE PACOTES "$branco" \n";
apt update
apt install vim tree mc aptitude links links2 lynx nmap net-tools dcmtk iptraf zip unzip rar unrar postgresql postgresql-contrib cifs-utils smbclient -y

###########################################################
### BAIXAR ARQUIVOS DE INSTALAÃ‡ÃƒO E CONFIGURAÃ‡ÃƒO DO DCM ###
###########################################################
echo -e "\n "$vermelho" INICIANDO DOWNLOAD DOS ARQUIVOS DE CONFIGURAÃ‡ÃƒO DO DCM4CHEE "$branco" \n";
mkdir -p /usr/local/src/dcmsetup/
wget http://186.227.194.93/S3tuPacS-DcmSRV/DCMSetup.zip -O /usr/local/src/dcmsetup/DCMSetup.zip
cd /usr/local/src/dcmsetup/ && unzip DCMSetup.zip

###############################
### SETAR SENHA DO POSTGRES ###
###############################
echo -e "\n "$vermelho" SETANDO A SENHA DO USUARIO POSTGRES "$branco" \n";
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${VAR_PASS_POSTGRES}';"

############################################################
### PREPARAR DIRETORIO PARA INSTALAÃ‡ÃƒO DO JAVA JRE E JDK ###
############################################################
echo -e "\n "$vermelho" INICIANDO INSTALAÃ‡ÃƒO DO JAVA JRE E JDK"$branco" \n";
mkdir -p /usr/java/ && cd /usr/java/
cp -vfr /usr/local/src/dcmsetup/*.tar.gz /usr/java/
#descompactar arquivos java
tar -zxvf jdk-7u80-linux-x64.tar.gz
tar -zxvf jre-7u80-linux-x64.tar.gz
tar -zxvf jai_imageio-1_1-lib-linux-amd64.tar.gz
#setar variaveis de ambiente
export JAVA_HOME=/usr/java/jdk1.7.0_80/
export PATH=$PATH:/usr/java/jre1.7.0_80/bin
#setar versÃ£o ativa do java
echo -e "\n "$vermelho" SETANDO VERSÃƒO JAVA DEFAULT PARA JRE E JDK "$branco" \n";
update-alternatives --install /usr/bin/java java /usr/java/jre1.7.0_80/bin/java 1
update-alternatives --install /usr/bin/javac javac /usr/java/jdk1.7.0_80/bin/javac 1

######################################################
### PREPARAR DIRETORIO PARA INSTALAÃ‡ÃƒO DCM E JBOSS ###
######################################################
echo -e "\n "$vermelho" PREPARANDO INSTALAÃ‡ÃƒO DO DCM "$branco" \n";
mkdir -vp /opt/pacs && cd /opt/pacs/
cp -vfr /usr/local/src/dcmsetup/*.zip /opt/pacs/
#descompactar arquivos dcm e renomear diretorios
unzip jboss-4.2.3.GA.zip
unzip dcm4chee-2.17.3-psql.zip
unzip dcm4chee-arr-3.0.12-psql.zip
mv dcm4chee-2.17.3-psql/ dcm4chee
mv dcm4chee-arr-3.0.12-psql dcm4chee-arr
mv jboss-4.2.3.GA/ jboss

###########################################################
### CRIAR BANCO DE DADOS PACSDB E ARRDB / CRIAR TABELAS ###
###########################################################
echo -e "\n "$vermelho" PREPARANDO BANCO DE DADOS E TABELAS DO DCM "$branco" \n";
su - postgres -c "createdb -U postgres pacsdb"
su - postgres -c "createdb -U postgres arrdb"

echo -e "\n "$vermelho" CRIANDO TABELAS "$amarelo" [ PACSDB ] "$branco" \n";
su - postgres -c "psql -d pacsdb -U postgres -f /opt/pacs/dcm4chee/sql/create.psql"

echo -e "\n "$vermelho" CRIANDO TABELAS "$amarelo" [ ARRDB ] "$branco" \n";
su - postgres -c "psql -d arrdb -U postgres -f /opt/pacs/dcm4chee-arr/sql/dcm4chee-arr-psql.ddl"

#######################################################
### SUBSTITUIR ARQUIVOS DE CONFIGURAÃ‡ÃƒO DO POSTGRES ###
#######################################################
echo -e "\n "$vermelho" CONFIGURANDO POSTGRES PARA LIBERAR ACESSO EXTERNO "$branco" \n";
cd /etc/postgresql/9.3/main/
cp -vfr pg_hba.conf pg_hba.conf.original
cp -vfr postgresql.conf postgresql.conf.original
cp -vfr /usr/local/src/dcmsetup/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
cp -vfr /usr/local/src/dcmsetup/postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
sleep 1
echo -e "\n "$vermelho" REINICIANDO SERVIÃ‡O DO POSTGRESQL "$branco" \n";
#reiniciar serviÃ§o postgres
echo && /etc/init.d/postgresql restart && echo

############################
### INSTALAR DCM E JBOSS ###
############################
echo -e "\n "$vermelho" INSTALANDO SERVIÃ‡O DO DCM4CHEE / JBOSS "$branco" \n";
cd /opt/pacs/dcm4chee/bin
./install_jboss.sh /opt/pacs/jboss/
./install_arr.sh /opt/pacs/dcm4chee-arr/

echo -e "\n "$vermelho" ATUALIZANDO BIBLIOTECA JAVA 64BITS "$branco" \n";
#atualizar biblioteca para sistema 64bits
cd /opt/pacs/dcm4chee/bin/native
mv -v libclib_jiio.so libclib_jiio_X86.so
cp -vfr /usr/java/jai_imageio-1_1/lib/libclib_jiio.so /opt/pacs/dcm4chee/bin/native/

#setar permissÃ£o geral do diretorio de instalaÃ§Ã£o do dcm
chmod -R 777 /opt/pacs/

################################################################
### CRIAR DIRETORIOS PARA STORAGE E FONTE DO SISTEMA MLAUDOS ###
################################################################
echo -e "\n "$vermelho" CRIANDO DIRETÃ“RIOS DE STORAGE E FONTE SISTEMA MLAUDOS "$branco" \n";
#atualizar biblioteca para sistema 64bits
mkdir -vp /STORAGE/
mkdir -vp /MLAUDOS/${VAR_NOME_CLIENTE}

#####################################################################
### ADICIONAR SERVIDORES DE ARQUIVO E DOMINIO AO ARQUIVO DE HOSTS ###
#####################################################################
echo "10.77.0.10      SRV-ADDS01.nsdominio.local      SRV-ADDS01" >> /etc/hosts
echo "10.77.3.254     ZEUS.nsdominio.local            ZEUS" >> /etc/hosts

###############################################################
### MONTAR DIRETORIOS DE STORAGE E FONTE DO SISTEMA MLAUDOS ###
###############################################################
echo -e "\n "$vermelho" MAPEANDO DIRETORIOS DE STORAGE E SISTEMA MLAUDOS "$branco" \n";
#montar diretorio storage
mount -vt cifs -o vers=2.0 //ZEUS/PACS-${VAR_NOME_CLIENTE}$ /STORAGE/ -o user=${VAR_USER_CLIENTE},domain=${VAR_DOMINIO_CLIENTE},password=${VAR_PASS_CLIENTE},file_mode=0777,dir_mode=0777
echo
#montar diretorio fonte sistema
mount -vt cifs -o vers=2.0 //ZEUS/${VAR_NOME_CLIENTE}$ /MLAUDOS/${VAR_NOME_CLIENTE} -o user=${VAR_USER_CLIENTE},domain=${VAR_DOMINIO_CLIENTE},password=${VAR_PASS_CLIENTE},file_mode=0777,dir_mode=0777
echo

####################################################################
### PREPARAR ARQUIVOS PARA INICIALIZAÃ‡ÃƒO AUTOMATICA DOS SERVIÃ‡OS ###
####################################################################
echo -e "\n "$vermelho" CONFIGURANDO INICIALIZAÃ‡ÃƒO AUTOMATICA DO DCM "$branco" \n";
cp -vfr /usr/local/src/dcmsetup/rundcm4chee.sh /etc/init.d/rundcm4chee.sh
chmod +x /etc/init.d/rundcm4chee.sh

mkdir -vp  /opt/jboss/log/ && touch  /opt/jboss/log/jboss.log
chmod -R 777 /opt/jboss/


########################################################################
### REESCREVER RC.LOCAL COM OS COMANDOS DE INICIALIZAÃ‡ÃƒO NECESSÃRIOS ###
########################################################################
cat > /etc/rc.local << EOF
#!/bin/sh -e

export JAVA_HOME=/usr/java/jdk1.7.0_80/
export PATH=$PATH:/usr/java/jre1.7.0_80/bin
#montar diretorio storage
mount -t cifs -o vers=2.0 //ZEUS/PACS-${VAR_NOME_CLIENTE}$ /STORAGE/ -o user=${VAR_USER_CLIENTE},domain=${VAR_DOMINIO_CLIENTE},password=${VAR_PASS_CLIENTE},file_mode=0777,dir_mode=0777
#montar diretorio fonte sistema
mount -t cifs -o vers=2.0 //ZEUS/${VAR_NOME_CLIENTE}$ /MLAUDOS/${VAR_NOME_CLIENTE} -o user=${VAR_USER_CLIENTE},domain=${VAR_DOMINIO_CLIENTE},password=${VAR_PASS_CLIENTE},file_mode=0777,dir_mode=0777

/etc/init.d/rundcm4chee.sh start

exit 0
EOF


#################################################################################
### COPIAR ARQUIVO DE COMPACTAÃ‡ÃƒO E SETAR CRONTAB PARA RODAR A CADA 2 MINUTOS ###
#################################################################################
cp -vfr /usr/local/src/dcmsetup/ZIPAR.sh /usr/local/bin/ZIPAR.sh
chmod +x  /usr/local/bin/ZIPAR.sh
sed -i "s/VAR_NOME_CLIENTE/${VAR_NOME_CLIENTE}/g" "/usr/local/bin/ZIPAR.sh"
crontab -l; (echo "*/5 * * * * /usr/local/bin/ZIPAR.sh 2>&1") | crontab -

echo -e "\n "$vermelho" INSTALAÃ‡ÃƒO DCM4CHEE CONCLUÃDA COM SUCESSO "$branco" \n";
echo -e "\n "$vermelho" NECESSÃRIO CONFIGURAR "$amarelo" JMX-CONSOLE "$vermelho" PARA CONCLUIR A INSTALAÃ‡AO "$branco" \n";
echo -e "\n "$amarelo" REINICIANDO SERVIDOR "$branco" \n";
sleep 5 

init 6
