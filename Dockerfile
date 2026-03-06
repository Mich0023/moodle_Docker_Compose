FROM php:8.3-apache

# Instalación de dependencias
RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip git curl libzip-dev libjpeg-dev libpng-dev \
    libfreetype6-dev libicu-dev libxml2-dev

# Configuración de extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install mysqli zip gd intl soap exif && \
    docker-php-ext-enable mysqli zip gd intl soap exif

# Limpieza y clonación de Moodle
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN git clone git://git.moodle.org/moodle.git && \
    cd moodle && \
    git branch --track MOODLE_405_STABLE origin/MOODLE_405_STABLE && \
    git checkout MOODLE_405_STABLE && \
    cp -rf ./* /var/www/html/

# Ajustes de PHP para Moodle
RUN echo "max_input_vars=5000" >> /usr/local/etc/php/conf.d/docker-php-moodle.ini && \
    echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-moodle.ini

RUN mkdir -p /var/www/moodledata
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/ && \
    chmod -R 755 /var/www

EXPOSE 80
