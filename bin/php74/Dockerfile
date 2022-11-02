FROM php:7.4.2-apache-buster



ARG DEBIAN_FRONTEND=noninteractive

# Atualiza
RUN apt-get -y update --fix-missing && \
    apt-get upgrade -y && \
    apt-get --no-install-recommends install -y apt-utils && \
    rm -rf /var/lib/apt/lists/*


# Instalar ferramentas
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install zip unzip net-tools nano wget \
dialog \
libsqlite3-dev \
libsqlite3-0 && \
    apt-get -y --no-install-recommends install default-mysql-client \
zlib1g-dev \
libzip-dev \
libicu-dev && \
    apt-get -y --no-install-recommends install --fix-missing apt-utils \
build-essential \
git \
curl \
libonig-dev && \ 
    apt-get install -y iputils-ping && \
    apt-get -y --no-install-recommends install --fix-missing libcurl4 \
libcurl4-openssl-dev \
zip \
openssl && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalar o xdebug
RUN pecl install xdebug-3.1.4 && \
    docker-php-ext-enable xdebug && \
    mkdir /var/log/xdebug

# Instalar redis
RUN pecl install redis-5.1.1 && \
    docker-php-ext-enable redis

# Instalar imagick
RUN apt-get update && \
    apt-get -y --no-install-recommends install --fix-missing libmagickwand-dev && \
    rm -rf /var/lib/apt/lists/* && \
    pecl install imagick && \
    docker-php-ext-enable imagick

# Outras extensões do PHP7

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_sqlite && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install curl && \
    docker-php-ext-install tokenizer && \
    docker-php-ext-install json && \
    docker-php-ext-install zip && \
    docker-php-ext-install -j$(nproc) intl && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install gettext && \
    docker-php-ext-install calendar && \
    docker-php-ext-install exif


# Instalar o Freetype 
RUN apt-get -y update && \
    apt-get --no-install-recommends install -y libfreetype6-dev \
libjpeg62-turbo-dev \
libpng-dev && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd

# Cria o diretório dos certificados
RUN mkdir -p /etc/apache2/ssl

# Ativa o suporte SSL
RUN a2enmod ssl && a2enmod rewrite

# Ativa os módulos SSL
RUN a2enmod rewrite headers

# Limpa o sistema operacional
RUN rm -rf /usr/src/*

# Adiciona correção ao apache2
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN echo "Alias /phpmyadmin /usr/share/phpmyadmin" >> /etc/apache2/apache2.conf

# Muda o diretório principal do Apache
ENV APACHE_DOCUMENT_ROOT /var/wwww

# Define o diretório de trabalho
WORKDIR /var/www