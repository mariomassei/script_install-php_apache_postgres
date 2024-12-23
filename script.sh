#!/bin/bash

# Atualiza o sistema
dnf update -y

# Instala pacotes necessários para adição de repositórios externos
dnf install -y dnf-utils
dnf install -y epel-release

# Adiciona o repositório Remi para o PHP 7.4
echo "Adicionando o repositório Remi para o PHP 7.4"
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf module enable -y php:remi-7.4
dnf install -y php php-cli php-common php-pgsql
echo "PHP 7.4 instalado com sucesso!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para continuar com a instalação do PostgreSQL..."

# Adiciona o repositório do PostgreSQL oficial para instalar a versão 16
echo "Adicionando o repositório do PostgreSQL 16"
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf -qy module disable postgresql
dnf install -y postgresql16-server # postgresql16-contrib
echo "PostgreSQL 16 instalado com sucesso!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para continuar com a instalação do pgAdmin..."

# Adiciona o repositório do pgAdmin 4 para CentOS/RHEL 9
echo "Adicionando o repositório do pgAdmin 4"
rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-2-1.noarch.rpm
#dnf install -y https://www.pgadmin.org/static/packages/release/pgadmin4-6.19-1.el9.x86_64.rpm
dnf install -y pgadmin4-web
/usr/pgadmin4/bin/setup-web.sh
echo "pgAdmin 4 instalado com sucesso!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para continuar com a instalação do Apache..."

# Instala o Apache
echo "Instalando o Apache..."
dnf install -y httpd
echo "Apache instalado com sucesso!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para iniciar e habilitar o Apache..."

# Inicia o Apache
systemctl start httpd
echo "Apache iniciado com sucesso!"

# Habilita o Apache para iniciar automaticamente no boot
systemctl enable httpd
echo "Apache habilitado para iniciar no boot!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para continuar com a configuração do PostgreSQL..."

# Configura o PostgreSQL
/usr/pgsql-16/bin/postgresql-16-setup initdb
systemctl enable postgresql-16
systemctl start postgresql-16
echo "PostgreSQL 16 configurado e iniciado com sucesso!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para continuar com a configuração do firewall..."

# Configura o firewall para liberar portas necessárias
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-port=5432/tcp --permanent # PostgreSQL
firewall-cmd --zone=public --add-service=samba --permanent
firewall-cmd --reload
echo "Firewall configurado com sucesso!"


# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para continuar com a configuração do Samba..."

# Instalação do Samba via repositórios padrão do CentOS 9
echo "Instalando o Samba..."
dnf install -y samba samba-client samba-common
echo "Samba instalado com sucesso!"

adduser dev

# Adiciona o usuário 'dev' ao Samba
smbpasswd -a dev
smbpasswd -e dev  # Habilita o usuário no Samba

# Adiciona o usuário 'dev' ao grupo do Apache (usuário 'apache' ou 'www-data', depende da distro)
usermod -aG apache dev  # Para CentOS/RHEL o grupo é 'apache', ajuste para 'www-data' caso esteja no Ubuntu


# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para configurar o Samba..."

# Configura o Samba para compartilhar a pasta /var/www/ com o usuário 'dev'
cat <<EOL > /etc/samba/smb.conf
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   netbios name = centos9
   security = user
   map to guest = bad user
   dns proxy = no

[www]
   path = /var/www/
   writable = yes
   browsable = yes
   valid users = dev
   guest ok = no
EOL
echo "Configuração do Samba concluída com sucesso!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para continuar com as permissões da pasta /var/www..."

# Ajusta permissões da pasta /var/www/ para o Samba e o Apache
# O Apache e o usuário 'dev' precisam de leitura e execução no diretório /var/www/
chmod -R 0775 /var/www/          # Permissões para leitura, execução e escrita para o grupo
chown -R root:apache /var/www/   # Propriedade do diretório para root e grupo 'apache' (o 'dev' estará nesse grupo)

# Dá permissões especiais de escrita para o Samba (somente para o diretório compartilhado)
setfacl -m u:dev:rwx /var/www/  # Permissões específicas para o usuário 'dev'
echo "Permissões da pasta /var/www/ configuradas com sucesso!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para continuar com a configuração do SELinux..."

# Configura o SELinux para o Samba
semanage fcontext -a -t samba_share_t "/var/www(/.*)?"
restorecon -Rv /var/www/
setenforce 0
echo "Configuração do SELinux concluída com sucesso!"

# Pausa para revisão antes de continuar
read -p "Pressione [Enter] para iniciar e habilitar os serviços Samba..."

# Reinicia o serviço Samba
systemctl enable --now smb nmb
echo "Samba configurado para iniciar automaticamente!"

# Reinicia os serviços
systemctl restart postgresql-16
systemctl restart smb
systemctl restart nmb
echo "Serviços reiniciados com sucesso!"

echo "Instalação completa! Acesse:"
echo "Apache: http://<IP_do_servidor>/info.php"
echo "pgAdmin Web: http://<IP_do_servidor>/pgadmin4"
echo "Compartilhamento Samba (usuário 'dev'): smb://<IP_do_servidor>/www"
