# docker-lamp-dev
Ambiente de desenvolvimento LAMP + PHP Composer + SSL + MultiSite + Docker Compose

A basic LAMP stack environment built using Docker Compose. It consists of the following:

- PHP
- Apache
- MySQL
- phpMyAdmin
- Redis
- Composer
- CodeIgniter + Pacote de Idiomas (última versão)
- Certificado SSL para cada app
- Autoridade Certificadora

A partir de agora, temos várias versões diferentes em PHP. Use a versão php apropriada, conforme necessário:

- 7.4.x
- 8.0.x
- 8.1.x

## Instalação

- Clone este repositório no seu computador local
- configurar .env conforme necessário
- Executar o `docker-compose up -d --build`.

```shell
git clone https://github.com/juniorVOPJ/docker-lamp-dev.git
cd docker-lamp-dev
cp exemplo.env .env
// modificar exemplo.env conforme necessário
docker-compose up -d --build
docker-compose exec webserver bash
cd /opt
./menu.sh
```
### Como usar

No menu você pode escolher entre 3 opções:

1 Criar Autoridade Certificadora (CA)
2 Criar um host simples + SSL
3 Criar um host CodeIgniter + SSL

Após a criação do host, importe para o KeyChain os arquivos -cert.pem do diretório config/ssl.
Altere seu aquivos /etc/hosts com o nome dos host criados, ex.:

```shell
127.0.0.1 host.com.br
::1 host.com.br
```

E você estará apto a acessar pelo navegador na url especificada na criação.

Seu ambiente LAMP de desenvolvimento está pronto!! Você pode acessar `http://localhost`.

## Configuração e Uso

### Informações Gerais

Este Docker Stack é construído para desenvolvimento local e não para utilização na produção.

### Configuração

Este pacote vem com opções de configuração padrão. Você pode modificá-las criando o arquivo `.env' em seu diretório raiz.
Para facilitar, basta copiar o conteúdo do arquivo `exemplo.env` e atualizar os valores das variáveis de ambiente de acordo com sua necessidade.

### Configuração das Variáveis

Há as seguintes variáveis de configuração disponíveis e você pode personalizá-las substituindo-as em seu próprio arquivo `.env'.

---

#### PHP

---

_**PHPVERSION**_
É usado para especificar qual versão PHP você deseja usar. O padrão é o PHP 7.4.2.

_**PHP_INI**_
Defina sua modificação personalizada `php.ini` para atender às suas exigências.

---

#### APACHE

---

_**DOCUMENT_ROOT**_

É uma raiz de documentos para o servidor Apache. O valor padrão para isto é `./www'. Todos os seus sites irão para aqui e serão sincronizados automaticamente.

_**APACHE_DOCUMENT_ROOT**_

Valor do arquivo de configuração do Apache. O valor padrão para isto é /var/wwww.

_**VHOSTS_DIR**_

Isto é para os hosts virtuais. O valor padrão para isto é `./config/vhosts'. Você pode colocar seus arquivos conf de hosts virtuais aqui.

> Certifique-se de adicionar uma entrada no arquivo de "hosts" de seu sistema para cada host virtual.
> 127.0.0.1 host.com.br
> ::1 host.com.br

_**APACHE_LOG_DIR**_

Isto será usado para armazenar os registros Apache. O valor padrão para isto é `./logs/apache2'.

---

#### BANCO DE DADOS

---

> Para usuários Apple Silicon Chip:
> Por favor, selecione Mariadb como Banco de Dados. Oracle não constrói seus Containers SQL para arquitetura .ARM

_**DATABASE**_

Defina qual versão do MySQL ou do MariaDB você gostaria de utilizar.

_**MYSQL_INITDB_DIR**_

Quando um container é iniciado pela primeira vez neste diretório com as extensões `.sh', `.sql', `.sql.gz' e
`.sql.xz' serão executadas em ordem alfabética. Os arquivos `.sh' sem permissão de execução de arquivos são obtidos em vez de executados.
O valor padrão para isto é `./config/initdb'.

_**MYSQL_DATA_DIR**_

Este é o diretório de dados MySQL. O valor padrão para isto é `./dados/mysql'. Todos os seus arquivos de dados MySQL serão armazenados aqui.

_**MYSQL_LOG_DIR**_

Isto será usado para armazenar os registros Apache. O valor padrão para isto é `./logs/mysql'.

## SERVIDOR WEB

O Apache está configurado para funcionar na porta 80 e na porta 443. Portanto, você pode acessá-lo através de `http://localhost' ou `https://localhost'.

#### MÓDULOS APACHE

Por padrão os seguintes módulos estão ativados.

- rewrite
- headers

#### CONECTAR VIA SSH

Você pode se conectar ao servidor web utilizando o comando `docker-compose exec` para realizar várias operações nele. Utilize o comando abaixo para fazer login no container via ssh.

```shell
docker-compose exec webserver bash
```

## PHP

A versão instalada do php depende de seu arquivo `.env`.

#### EXTENSÕES

Por padrão, as extensões seguintes são instaladas.
Pode ser diferente para as versões PHP <7.x.x.x

- mysqli
- pdo_sqlite
- pdo_mysql
- mbstring
- zip
- intl
- mcrypt
- curl
- json
- iconv
- xml
- xmlrpc
- gd

> Se você quiser instalar mais extensão, basta atualizar `./bin/webserver/Dockerfile'.
> Você tem que reconstruir a imagem do docker executando o `docker-compose build' e reiniciar os containers.

## phpMyAdmin

phpMyAdmin está configurado para funcionar na porta 8080. Use as seguintes credenciais padrão.

http://localhost:8080/  
username: root  
password: jaguar

## Xdebug

Xdebug vem instalado por padrão e sua versão depende da versão PHP escolhida no arquivo `".env"`.

**Xdebug versões:**

PHP >= 7.4: Xdebug 3.X.X

Para utilizar o Xdebug você precisa habilitar as configurações no arquivo `./config/php/php.ini` de acordo com a versão escolhida PHP.

Exemplo:

```
# Xdebug 2
#xdebug.remote_enable=1
#xdebug.remote_autostart=1
#xdebug.remote_connect_back=1
#xdebug.remote_host = host.docker.internal
#xdebug.remote_port=9000

# Xdebug 3
#xdebug.mode=debug
#xdebug.start_with_request=yes
#xdebug.client_host=host.docker.internal
#xdebug.client_port=9003
#xdebug.idekey=VSCODE
```

Xdebug VS Code: você tem que instalar a extensão Xdebug "PHP Debug". Depois de instalado, vá até Debug e crie o arquivo de execução para que sua IDE possa ouvir e funcionar corretamente.

## REDIS

Ela vem com Redis. Funciona na porta padrão `6379`.

### 1) HTTPS no Localhost

Por padrão o HTTPS vem habilitado e com um script de geração de Autoridade Certificadora CA e certificados auto-assinados.

Foi desenvolvido um script bash que automatiza todo o processo de criação de um applicativo web, com Autoridade Certificadora, certificado SSL, instalação do CodeIgniter e entre outras funções.

## CONTRIBUIÇÃO

Ficamos felizes se você quiser criar um pull request ou ajudar as pessoas com seus problemas. Se você quiser criar uma PR, lembre-se que esta pilha não é construída para uso na produção, e as mudanças devem ser boas para fins gerais e não excessivamente especializadas.

> Por favor, note que simplificamos a estrutura do projeto de vários ramos para cada versão php, para um ramo mestre centralizado. 
>
> Obrigado!

## Por que você não deve usar esta pilha não modificada na produção

Queremos capacitar os desenvolvedores a criar rapidamente aplicações criativas. Portanto, estamos proporcionando um ambiente de desenvolvimento local fácil para vários Frameworks e Versões PHP diferentes.
Em Produção você deve modificar no mínimo os seguintes requisitos:

- php handler: mod_php=> php-fpm
- proteger os usuários do mysql com as devidas limitações de IP de origem
