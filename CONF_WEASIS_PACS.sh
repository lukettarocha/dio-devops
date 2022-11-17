#!/bin/bash

#BAIXANDO OS ARQUIVOS DO WEASUS

wget --no-check-certificate https://sourceforge.net/projects/dcm4che/files/Weasis/weasis-pacs-connector/6.1.5/dcm4chee-web-weasis.jar/download -O /opt/pacs/dcm4chee/server/default/deploy/dcm4chee-web-weasis.jar && wget --no-check-certificate https://sourceforge.net/projects/dcm4che/files/Weasis/weasis-pacs-connector/6.1.5/weasis-pacs-connector.war/download -O /opt/pacs/dcm4chee/server/default/deploy/weasis-pacs-connector.war && wget --no-check-certificate https://sourceforge.net/projects/dcm4che/files/Weasis/3.8.1/weasis.war/download -O /opt/pacs/dcm4chee/server/default/deploy/weasis.war

sleep 5

#INSTALAR A LIB DO SERLET 2.5 - JAVA
apt-get install -y libservlet2.5-java

sleep 2

#BAIXAR OS ARQUIVOS DE CONFIGURAÇÃO E COLOCAR NA PASTA DO JBOSS
wget --no-check-certificate https://raw.githubusercontent.com/nroduit/weasis-pacs-connector/6.x/src/main/resources/weasis-connector-default.properties -O /opt/pacs/jboss/server/default/conf/weasis-connector-default.properties && wget --no-check-certificate https://raw.githubusercontent.com/nroduit/weasis-pacs-connector/6.x/src/main/resources/dicom-dcm4chee.properties -O /opt/pacs/jboss/server/default/conf/dicom-dcm4chee.properties

sleep 5

#EDITANDO OS ARQUIVOS DE CONFIGURAÇÃO NA PASTA DO WEASIS CONNECTOR

#PARTE 1: CRIANDO A PASTA PARA EXTRAIR O ARQUIVO.WAR
cd /opt/pacs/dcm4chee/server/default/deploy/
chmod 777 weasis-pacs-connector.war
mv weasis-pacs-connector.war weasis-pacs-connector.war.legacy
mkdir weasis-pacs-connector.war
chmod 777 weasis-pacs-connector.war
cd weasis-pacs-connector.war
mv weasis-pacs-connector.war.legacy weasis-pacs-connector.war
jar -xvf weasis-pacs-connector.war
rm -rf weasis-pacs-connector.war

#PARTE 2: EDITANDO O ARQUIVO DE CONFIGURAÇÃO

sed -i '11s/DCM4CHEE/$VAR_AETITLE/' /opt/pacs/dcm4chee/server/default/deploy/weasis-pacs-connector.war/WEB-INF/classes/dicom-dcm4chee.properties
sed -i '13s/11112/$VAR_PORTA/' /opt/pacs/dcm4chee/server/default/deploy/weasis-pacs-connector.war/WEB-INF/classes/dicom-dcm4chee.properties








#EDITAR ARQUIVO DE CONFIGURAÇÃO DO dicom-dcm4chee.properties JBOSS CONF
#vim /opt/pacs/jboss/server/default/conf/dicom-dcm4chee-properties
#ALTERAR O AE-TITLE E A PORTA DE COMUNICAÇÃO DO LOCAL SERVER
s