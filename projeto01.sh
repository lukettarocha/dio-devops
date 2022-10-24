#!/bin/bash

pastas=('publico'
        'adm'
        'ven'
        'sec')

grupos=('GRP_ADM'
        'GRP_VEN'
        'GRP_SEC')

usuarios=('carlos'
          'maria'
          'joao'
          'debora'
          'sebastiana'
          'roberto'
          'josefina'
          'amanda'
          'rogerio')


for ((cont=0; cont<${#grupos[@]}; cont++));
do
        groupadd ${grupos[$cont]}
        echo "O grupo ${grupos[$cont]} foi criado com sucesso."
done

for ((cont=0; cont<${#usuarios[@]}; cont++));
do
        if [[ $cont -lt  3 ]]
        then
                useradd ${usuarios[$cont]} -m -s /bin/bash -G GRP_ADM -p [$(openssl passwd -crypt senha123)]
                echo -e "Usuário ${usuarios[$cont]} criado com sucesso."
        elif [[ $cont -ge 3 && $cont -lt 6 ]]
        then
                useradd ${usuarios[$cont]} -m -s /bin/bash -G GRP_VEN -p [$(openssl passwd -crypt senha123)]
                echo -e "Usuário ${usuarios[$cont]} criado com sucesso."
        elif [[ $cont -ge 6 ]]
        then
                useradd ${usuarios[$cont]} -m -s /bin/bash -G GRP_SEC -p [$(openssl passwd -crypt senha123)]
                echo -e "Usuário ${usuarios[$cont]} criado com sucesso."
        fi
done

for ((cont=0; cont<${#pastas[@]}; cont++));
do
        mkdir /${pastas[$cont]}
        echo "O diretório /${pastas[$cont]} foi criado com sucesso"
        if [[ ${pastas[$cont]} = "publico" ]]
        then
                chmod 777 /publico
        elif [[ ${pastas[$cont]} = "ven"  ]]
        then
                chown root:GRP_VEN /ven
                chmod 770 /ven
        elif [[ ${pastas[$cont]} = "adm" ]]
        then
                chown root:GRP_ADM /adm
                chmod 770 /adm
        elif [[ ${pastas[$cont]} = "sec" ]]
        then
                chown root:GRP_SEC /sec
                chmod 770 /sec
        fi
done
