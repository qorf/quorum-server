# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
# This post might help us figure out mail: https://stackoverflow.com/questions/47247952/send-email-on-testing-docker-container-with-php-and-sendmail
FROM php:8.0.9-fpm

RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update &&\
    pecl install redis-5.3.7 &&\
    docker-php-ext-enable redis &&\
    apt-get -y install curl libcurl4-openssl-dev &&\
    docker-php-ext-install curl
