#!/bin/bash

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="FUSIONLABS BRASIL LTDA"
TITLE="Ambiente de desenvolvimento LAMP + SSL"
MENU="Selecione uma das opções abaixo:"

OPTIONS=(1 " Criar uma Autoridade Certificadora - CA "
         2 " Criar um esqueleto de site vazio "
         3 " Criar um esqueleto de site CodeIgniter ")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
    1)
        echo "Autoridade Certificadora - CA"
        echo "--------------------------------------------------------------------------"
        echo ""
        read -p "DIGITE O NOME DO ARQUIVO CA (fbrCA): " ca_file
        if [ -z "$ca_file" ] 
        then
            ca_file="fbrCA"
        fi
        rm -rf ssl/tmp
        rm -rf ssl/ca
        mkdir ssl/tmp
        rm -rf /etc/apache2/ssl/$ca_file-cert.pem
        echo "CREATE CA AUTHORITY CERTIFICATE AND KEYS"
        openssl genrsa 2048 > ssl/tmp/$ca_file-key.pem
        openssl req -new -x509 -nodes -days 1460 -key ssl/tmp/$ca_file-key.pem -out ssl/tmp/$ca_file-cert.pem
        mkdir ssl/ca
        cp ssl/tmp/$ca_file-key.pem ssl/ca/$ca_file-key.pem
        cp ssl/tmp/$ca_file-cert.pem ssl/ca/$ca_file-cert.pem
        cp ssl/tmp/$ca_file-cert.pem /etc/apache2/ssl/$ca_file-cert.pem
        rm -rf ssl/tmp
        clear
        echo ""
        clear
        echo "###########################################################################"
        echo "=====> PRONTO!"
        echo "-"
        echo "O caminho e o nome da autoridade certificadora é:"
        echo ""
        echo "    chave       ssl/ca/$ca_file-key.pem"
        echo "    certificado ssl/ca/$ca_file-cert.pem"
        echo "    certificado config/ssl/$ca_file-cert.pem"
        echo "-"
        echo "A AUTORIDADE CERTIFICADORA FOI ADICIONADA AO KEYCHAIN DO MACOSX"
        echo "###########################################################################"
        echo ""
    ;;
    2)
        rm -rf ssl/tmp
        mkdir ssl/tmp
        mkdir ssl/cert
        clear
        echo "Site com template vazio"
        echo "--------------------------------------------------------------------------"
        echo ""
        read -p "DIGITE O NOME DO ARQUIVO DA AUTORIDADE CERTIFICADORA (fbrCA): " autcert
        if [ -z "$autcert" ] 
        then
            autcert="fbrCA"
        fi
        read -p "DIGITE A SIGLA DO PAÍS (BR): " pais
        if [ -z "$pais" ] 
        then
            pais="BR"
        fi
        read -p "DIGITE A SIGLA DO UF (DISTRITO FEDERAL): " uf
        if [ -z "$uf" ] 
        then
            uf="DF"
        fi
        read -p "DIGITE A CIDADE (BRASILIA): " cidade
        if [ -z "$cidade" ] 
        then
            cidade="BRASILIA"
        fi
        read -p "DIGITE O NOME DA EMPRESA (FUSIONLABS BRASIL LTDA): " empresa
        if [ -z "$empresa" ] 
        then
            empresa="FUSIONLABS BRASIL LTDA"
        fi
        read -p "DIGITE O SETOR (LABS/ENGENHARIA/FBR): " setor
        if [ -z "$setor" ] 
        then
            setor="LABS/ENGENHARIA/FBR"
        fi
        read -p "DIGITE A URL DO SITE SEM WWW (fusionlabs.com.br): " site
        while [[  -z "$site" ]]; do
            read -p "É OBRIGADO INFORMAR A URL DO SITE SEM WWW (fusionlabs.com.br): " site
        done
        read -p "DIGITE O ALIAS (www): " site_alias
        if [ -z "$site_alias" ] 
        then
            site_alias="www"
        fi 
        read -p "DIGITE O EMAIL DO ADMINISTRADOR (admin@$site): " email
        if [ -z "$email" ] 
        then
            email="admin@$site"
        fi
        
        #! O nome do certificado é a url do site
        certname=$site

        #! Exclui todas as existências do certificado, do arquivo de configuração do site e do diretório www
        rm -rf /var/www/$site
        rm -rf /etc/apache2/sites-enabled/$site.conf
        rm -rf apache2
        rm -rf /etc/apache2/ssl/$site-cert.pem
        rm -rf /etc/apache2/ssl/$site-key.pem
        rm -rf ssl/cert/$certname-cert.pem
        rm -rf ssl/cert/$certname-key.pem

        #! Prepara o arquivo de configuração
        echo "[req]" > ssl/tmp/$certname.conf
        echo "default_bits = 2048" >> ssl/tmp/$certname.conf
        echo "distinguished_name = req_distinguished_name" >> ssl/tmp/$certname.conf
        echo "prompt = no" >> ssl/tmp/$certname.conf
        echo "" >> ssl/tmp/$certname.conf
        echo "[req_distinguished_name]" >> ssl/tmp/$certname.conf
        echo "C = "$pais >> ssl/tmp/$certname.conf
        echo "ST = "$uf >> ssl/tmp/$certname.conf
        echo "L = "$cidade >> ssl/tmp/$certname.conf
        echo "O = "$empresa >> ssl/tmp/$certname.conf
        echo "OU = "$setor >> ssl/tmp/$certname.conf
        echo "CN = "$site >> ssl/tmp/$certname.conf
        echo "" >> ssl/tmp/$certname.conf
        echo "[v3_ca]" >> ssl/tmp/$certname.conf
        echo "subjectAltName = @alt_names" >> ssl/tmp/$certname.conf
        echo "" >> ssl/tmp/$certname.conf
        echo "[alt_names]" >> ssl/tmp/$certname.conf
        echo "DNS.1 = "$site >> ssl/tmp/$certname.conf
        if [ ! -z "$site_alias" ] 
        then
            echo "DNS.2 = "$site_alias.$site >> ssl/tmp/$certname.conf
        fi
        clear

        #! Cria o certificado
        openssl req -new -sha256 -nodes -newkey rsa:2048 -keyout ssl/tmp/$certname.key -out ssl/tmp/$certname.csr -config ssl/tmp/$certname.conf
        openssl x509 -req -in ssl/tmp/$certname.csr -CA ssl/ca/$autcert-cert.pem -CAkey ssl/ca/$autcert-key.pem -CAcreateserial -out ssl/tmp/$certname.crt -sha256 -days 1460 -extfile ssl/tmp/$certname.conf -extensions v3_ca
        openssl rsa -in ssl/tmp/$certname.key -text > ssl/tmp/$certname-key.pem
        openssl x509 -inform PEM -in ssl/tmp/$certname.crt > ssl/tmp/$certname-cert.pem

        #! Copia o certificado para os diretórios
        cp ssl/tmp/$certname-key.pem ssl/cert/$certname-key.pem
        cp ssl/tmp/$certname-cert.pem ssl/cert/$certname-cert.pem
        cp ssl/cert/$certname-key.pem /etc/apache2/ssl/$certname-key.pem
        cp ssl/cert/$certname-cert.pem /etc/apache2/ssl/$certname-cert.pem

        #! Cria o diretório e subdiretórios do site
        mkdir /var/www/$site
        mkdir /var/www/$site/dist
        mkdir /var/www/$site/dist/css

        #! Copia os arquivos de template
        cp skeleton/index.php /var/www/$site/index.php
        cp skeleton/favicon.ico /var/www/$site/favicon.ico
        cp skeleton/phpinfo.php /var/www/$site/phpinfo.php
        cp skeleton/test_db_pdo.php /var/www/$site/test_db_pdo.php
        cp skeleton/test_db.php /var/www/$site/test_db.php
        cp skeleton/dist/css/bulma.css.map /var/www/$site/dist/css/bulma.css.map
        cp skeleton/dist/css/bulma.min.css /var/www/$site/dist/css/bulma.min.css

        #! Cria o arquivo de configuração do site no apache2
        mkdir apache2
        echo "<virtualhost *:80>" > apache2/$site.conf
        echo "	ServerName" $site >> apache2/$site.conf
        if [ ! -z "$site_alias" ] 
        then
            echo "	ServerAlias" $site_alias.$site >> apache2/$site.conf
        fi
        echo "	ServerAdmin" $email >> apache2/$site.conf
        echo "	DocumentRoot /var/www/"$site >> apache2/$site.conf
        echo "	<directory /var/www/"$site"/>" >> apache2/$site.conf
        echo "		Options FollowSymLinks" >> apache2/$site.conf
        echo "		AllowOverride All" >> apache2/$site.conf
        echo "	</directory>" >> apache2/$site.conf
        echo "	LogLevel warn" >> apache2/$site.conf
        echo "	ErrorLog /var/log/apache2/"$site.log >> apache2/$site.conf
        if [ ! -z "$site_alias" ] 
        then
            echo "	RewriteEngine on" >> apache2/$site.conf
            echo "	RewriteCond %{SERVER_NAME}= "$site_alias.$site" [OR]" >> apache2/$site.conf
            echo "	RewriteCond %{SERVER_NAME}= "$site >> apache2/$site.conf
            echo "	RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]" >> apache2/$site.conf
        else
            echo "	RewriteEngine on" >> apache2/$site.conf
            echo "	RewriteCond %{SERVER_NAME} ="$site >> apache2/$site.conf
            echo "	RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]" >> apache2/$site.conf
        fi
        echo "</virtualhost>" >> apache2/$site.conf
        echo " " >> apache2/$site.conf
        echo "<VirtualHost _default_:443>" >> apache2/$site.conf
        echo "	ServerName" $site >> apache2/$site.conf
        if [ ! -z "$site_alias" ] 
        then
            echo "	ServerAlias" $site_alias.$site apache2/$site.conf
        fi
        echo "	ServerAdmin" $email >> apache2/$site.conf
        echo "	DocumentRoot /var/www/"$site >> apache2/$site.conf
        echo "	ErrorLog /var/log/apache2/"$site.log >> apache2/$site.conf
        echo "	SSLEngine on" >> apache2/$site.conf
        echo "	SSLCertificateFile /etc/apache2/ssl/"$certname-cert.pem >> apache2/$site.conf
        echo "	SSLCertificateKeyFile /etc/apache2/ssl/"$certname-key.pem >> apache2/$site.conf
        echo "	SSLCACertificatePath /etc/apache2/ssl/" >> apache2/$site.conf
        echo "	SSLCACertificateFile /etc/apache2/ssl/"$autcert-cert.pem >> apache2/$site.conf
        echo "	<FilesMatch \"\.(cgi|shtml|phtml|php)$\">" >> apache2/$site.conf
        echo "		SSLOptions +StdEnvVars" >> apache2/$site.conf
        echo "	</FilesMatch>" >> apache2/$site.conf
        echo "	<Directory /usr/lib/cgi-bin>" >> apache2/$site.conf
        echo "		SSLOptions +StdEnvVars" >> apache2/$site.conf
        echo "	</Directory>" >> apache2/$site.conf
        echo "</VirtualHost>" >> apache2/$site.conf
        cp apache2/$site.conf /etc/apache2/sites-enabled/$site.conf
        rm -rf apache2
        rm -rf ssl/tmp
        echo "----------------------------------------------------------------------------------"
        echo "SITE + SSL + CA - PRONTOS!"
        echo "1) Copiar a Autoridade Certificadora config/ssl/$autcert-cert.pem para KeyChain"
        echo "2) Baixar o certificado do site $site e importar no KeyChain"
        echo "3) O site está disponível na pasta www/$site"
        echo "4) Para excluir o site, é necessario remover os seguintes arquivos:"
        echo "   www/$site"
        echo "   vhosts/$site.conf"
        echo "   config/ssl/$site-cert.pem"
        echo "   config/ssl/$site-key.pem"
        echo "   config/app/ssl/cert/$site-cert.pem"
        echo "   config/app/ssl/cert/$site-key.pem"
        echo ""
        echo ""
        service apache2 reload
        ;;
    3)
        rm -rf ssl/tmp
        mkdir ssl/tmp
        mkdir ssl/cert
        clear
        echo "Site com template vazio"
        echo "--------------------------------------------------------------------------"
        echo ""
        read -p "DIGITE O NOME DO ARQUIVO DA AUTORIDADE CERTIFICADORA (fbrCA): " autcert
        if [ -z "$autcert" ] 
        then
            autcert="fbrCA"
        fi
        read -p "DIGITE A SIGLA DO PAÍS (BR): " pais
        if [ -z "$pais" ] 
        then
            pais="BR"
        fi
        read -p "DIGITE A SIGLA DO UF (DISTRITO FEDERAL): " uf
        if [ -z "$uf" ] 
        then
            uf="DF"
        fi
        read -p "DIGITE A CIDADE (BRASILIA): " cidade
        if [ -z "$cidade" ] 
        then
            cidade="BRASILIA"
        fi
        read -p "DIGITE O NOME DA EMPRESA (FUSIONLABS BRASIL LTDA): " empresa
        if [ -z "$empresa" ] 
        then
            empresa="FUSIONLABS BRASIL LTDA"
        fi
        read -p "DIGITE O SETOR (LABS/ENGENHARIA/FBR): " setor
        if [ -z "$setor" ] 
        then
            setor="LABS/ENGENHARIA/FBR"
        fi
        read -p "DIGITE A URL DO SITE SEM WWW (fusionlabs.com.br): " site
        while [[  -z "$site" ]]; do
            read -p "É OBRIGADO INFORMAR A URL DO SITE SEM WWW (fusionlabs.com.br): " site
        done
        read -p "DIGITE O ALIAS (www): " site_alias
        if [ -z "$site_alias" ] 
        then
            site_alias="www"
        fi 
        read -p "DIGITE O EMAIL DO ADMINISTRADOR (admin@$site): " email
        if [ -z "$email" ] 
        then
            email="admin@$site"
        fi
        
        #! O nome do certificado é a url do site
        certname=$site

        #! Exclui todas as existências do certificado, do arquivo de configuração do site e do diretório www
        rm -rf /var/www/$site
        rm -rf /etc/apache2/sites-enabled/$site.conf
        rm -rf apache2
        rm -rf /etc/apache2/ssl/$site-cert.pem
        rm -rf /etc/apache2/ssl/$site-key.pem
        rm -rf ssl/cert/$certname-cert.pem
        rm -rf ssl/cert/$certname-key.pem

        #! Prepara o arquivo de configuração
        echo "[req]" > ssl/tmp/$certname.conf
        echo "default_bits = 2048" >> ssl/tmp/$certname.conf
        echo "distinguished_name = req_distinguished_name" >> ssl/tmp/$certname.conf
        echo "prompt = no" >> ssl/tmp/$certname.conf
        echo "" >> ssl/tmp/$certname.conf
        echo "[req_distinguished_name]" >> ssl/tmp/$certname.conf
        echo "C = "$pais >> ssl/tmp/$certname.conf
        echo "ST = "$uf >> ssl/tmp/$certname.conf
        echo "L = "$cidade >> ssl/tmp/$certname.conf
        echo "O = "$empresa >> ssl/tmp/$certname.conf
        echo "OU = "$setor >> ssl/tmp/$certname.conf
        echo "CN = "$site >> ssl/tmp/$certname.conf
        echo "" >> ssl/tmp/$certname.conf
        echo "[v3_ca]" >> ssl/tmp/$certname.conf
        echo "subjectAltName = @alt_names" >> ssl/tmp/$certname.conf
        echo "" >> ssl/tmp/$certname.conf
        echo "[alt_names]" >> ssl/tmp/$certname.conf
        echo "DNS.1 = "$site >> ssl/tmp/$certname.conf
        if [ ! -z "$site_alias" ] 
        then
            echo "DNS.2 = "$site_alias.$site >> ssl/tmp/$certname.conf
        fi
        clear

        #! Cria o certificado
        openssl req -new -sha256 -nodes -newkey rsa:2048 -keyout ssl/tmp/$certname.key -out ssl/tmp/$certname.csr -config ssl/tmp/$certname.conf
        openssl x509 -req -in ssl/tmp/$certname.csr -CA ssl/ca/$autcert-cert.pem -CAkey ssl/ca/$autcert-key.pem -CAcreateserial -out ssl/tmp/$certname.crt -sha256 -days 1460 -extfile ssl/tmp/$certname.conf -extensions v3_ca
        openssl rsa -in ssl/tmp/$certname.key -text > ssl/tmp/$certname-key.pem
        openssl x509 -inform PEM -in ssl/tmp/$certname.crt > ssl/tmp/$certname-cert.pem

        #! Copia o certificado para os diretórios
        cp ssl/tmp/$certname-key.pem ssl/cert/$certname-key.pem
        cp ssl/tmp/$certname-cert.pem ssl/cert/$certname-cert.pem
        cp ssl/cert/$certname-key.pem /etc/apache2/ssl/$certname-key.pem
        cp ssl/cert/$certname-cert.pem /etc/apache2/ssl/$certname-cert.pem

        #! Cria o diretório e subdiretórios do site
        mkdir /var/www/$site

        #! Cria o arquivo de configuração do site no apache2
        mkdir apache2
        echo "<virtualhost *:80>" > apache2/$site.conf
        echo "	ServerName" $site >> apache2/$site.conf
        if [ ! -z "$site_alias" ] 
        then
            echo "	ServerAlias" $site_alias.$site >> apache2/$site.conf
        fi
        echo "	ServerAdmin" $email >> apache2/$site.conf
        echo "	DocumentRoot /var/www/"$site >> apache2/$site.conf
        echo "	<directory /var/www/"$site"/>" >> apache2/$site.conf
        echo "		Options FollowSymLinks" >> apache2/$site.conf
        echo "		AllowOverride All" >> apache2/$site.conf
        echo "	</directory>" >> apache2/$site.conf
        echo "	LogLevel warn" >> apache2/$site.conf
        echo "	ErrorLog /var/log/apache2/"$site.log >> apache2/$site.conf
        if [ ! -z "$site_alias" ] 
        then
            echo "	RewriteEngine on" >> apache2/$site.conf
            echo "	RewriteCond %{SERVER_NAME}= "$site_alias.$site" [OR]" >> apache2/$site.conf
            echo "	RewriteCond %{SERVER_NAME}= "$site >> apache2/$site.conf
            echo "	RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]" >> apache2/$site.conf
        else
            echo "	RewriteEngine on" >> apache2/$site.conf
            echo "	RewriteCond %{SERVER_NAME} ="$site >> apache2/$site.conf
            echo "	RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]" >> apache2/$site.conf
        fi
        echo "</virtualhost>" >> apache2/$site.conf
        echo " " >> apache2/$site.conf
        echo "<VirtualHost _default_:443>" >> apache2/$site.conf
        echo "	ServerName" $site >> apache2/$site.conf
        if [ ! -z "$site_alias" ] 
        then
            echo "	ServerAlias" $site_alias.$site apache2/$site.conf
        fi
        echo "	ServerAdmin" $email >> apache2/$site.conf
        echo "	DocumentRoot /var/www/"$site >> apache2/$site.conf
        echo "	ErrorLog /var/log/apache2/"$site.log >> apache2/$site.conf
        echo "	<Directory /var/www/$site>" >> apache2/$site.conf
        echo "	        Options Indexes FollowSymLinks MultiViews" >> apache2/$site.conf
        echo "	        AllowOverride All" >> apache2/$site.conf
        echo "	        Order allow,deny" >> apache2/$site.conf
        echo "	        allow from all" >> apache2/$site.conf
        echo "	</Directory>" >> apache2/$site.conf
        echo "	SSLEngine on" >> apache2/$site.conf
        echo "	SSLCertificateFile /etc/apache2/ssl/"$certname-cert.pem >> apache2/$site.conf
        echo "	SSLCertificateKeyFile /etc/apache2/ssl/"$certname-key.pem >> apache2/$site.conf
        echo "	SSLCACertificatePath /etc/apache2/ssl/" >> apache2/$site.conf
        echo "	SSLCACertificateFile /etc/apache2/ssl/"$autcert-cert.pem >> apache2/$site.conf
        echo "	<FilesMatch \"\.(cgi|shtml|phtml|php)$\">" >> apache2/$site.conf
        echo "		SSLOptions +StdEnvVars" >> apache2/$site.conf
        echo "	</FilesMatch>" >> apache2/$site.conf
        echo "	<Directory /usr/lib/cgi-bin>" >> apache2/$site.conf
        echo "		SSLOptions +StdEnvVars" >> apache2/$site.conf
        echo "	</Directory>" >> apache2/$site.conf
        echo "</VirtualHost>" >> apache2/$site.conf
        echo "DirectoryIndex /public/index.php" > apache2/.htaccess
        echo "RewriteEngine on" >> apache2/.htaccess
        echo "RewriteCond \$1 !^(index\.php|img|app|css|js|robots\.txt)" >> apache2/.htaccess
        echo "RewriteCond %{REQUEST_FILENAME} !-f" >> apache2/.htaccess
        echo "RewriteCond %{REQUEST_FILENAME} !-d" >> apache2/.htaccess
        echo "RewriteRule ^(.*)$ ./public/index.php/\$1 [L,QSA]" >> apache2/.htaccess
        cp apache2/$site.conf /etc/apache2/sites-enabled/$site.conf
        rm -rf ssl/tmp
        composer create-project codeigniter4/appstarter /var/www/$site
        cd /var/www/$site
        composer require codeigniter4/translations
        cd /opt
        cp apache2/.htaccess /var/www/$site/.htaccess
        rm -rf apache2
        echo "----------------------------------------------------------------------------------"
        echo "CODEIGNITER (ÚLTIMA VERSÃO) + SSL + CA - PRONTOS!"
        echo "1) Copiar a Autoridade Certificadora config/ssl/$autcert-cert.pem para KeyChain"
        echo "2) Baixar o certificado do site $site e importar no KeyChain"
        echo "3) O site está disponível na pasta www/$site"
        echo "4) Para excluir o site, é necessario remover os seguintes arquivos:"
        echo "   www/$site"
        echo "   vhosts/$site.conf"
        echo "   config/ssl/$site-cert.pem"
        echo "   config/ssl/$site-key.pem"
        echo "   config/app/ssl/cert/$site-cert.pem"
        echo "   config/app/ssl/cert/$site-key.pem"
        echo ""
        echo ""
        service apache2 reload
        ;;
esac
