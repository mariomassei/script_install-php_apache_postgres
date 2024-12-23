# script_install-php_apache_postgres
script automazanção de ambiente no centos_9 php7.4+apache+postgreSQL16+compatilhamento samba 

Este script Bash é utilizado para configurar um servidor CentOS 9 com PHP 7.4, PostgreSQL 16, pgAdmin 4, Apache e Samba. Ele realiza a instalação e configuração desses componentes, além de ajustes de permissões e configurações de firewall e SELinux.

Funcionalidades
Atualiza o sistema.

Instala pacotes necessários para repositórios externos.

Adiciona e configura o repositório Remi para PHP 7.4.

Instala PHP 7.4, incluindo extensões.

Adiciona e configura o repositório oficial do PostgreSQL para instalar a versão 16.

Instala e configura PostgreSQL 16.

Adiciona e configura o repositório do pgAdmin 4.

Instala e configura pgAdmin 4.

Instala e configura Apache.

Configura o firewall para liberar portas necessárias.

Instala e configura Samba para compartilhar a pasta /var/www.

Ajusta permissões e configurações do SELinux.

Como usar
Certifique-se de que você tem permissões de superusuário (root).

Baixe ou clone este repositório.

Execute o script Bash:

bash
./seu-script.sh
Siga as instruções e prompts fornecidos pelo script durante a execução.

Pré-requisitos
CentOS 9

Acesso à internet para baixar os pacotes e repositórios

Notas
O script inclui pausas (read -p) para permitir que você revise cada etapa antes de continuar.

As configurações de firewall e SELinux são ajustadas para permitir o funcionamento adequado dos serviços instalados.

O script cria um usuário Samba (dev) e ajusta as permissões da pasta /var/www para compatibilidade com Apache e Samba.

Acessos
Apache: http://<IP_do_servidor>/info.php

pgAdmin Web: http://<IP_do_servidor>/pgadmin4

Compartilhamento Samba (usuário 'dev'): smb://<IP_do_servidor>/www
