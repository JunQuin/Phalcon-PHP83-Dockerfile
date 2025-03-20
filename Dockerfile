FROM php:8.3-apache

# --- Actualización e Instalación de Dependencias del Sistema ---
# Actualiza los repositorios e instala las dependencias necesarias para las extensiones PHP,
# controladores de bases de datos y utilidades del sistema.
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    libpq-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libpcre3-dev \
    unixodbc \
    unixodbc-dev

# --- Instalación del Repositorio de Microsoft y Drivers de SQL Server ---
# Instala wget para descargar el paquete de configuración del repositorio de Microsoft.
RUN apt install wget

# Descarga el paquete de configuración del repositorio de Microsoft para Debian.
RUN curl -sSL -O https://packages.microsoft.com/config/debian/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2 | cut -d '.' -f 1)/packages-microsoft-prod.deb

# Instala el paquete del repositorio de Microsoft.
RUN dpkg -i packages-microsoft-prod.deb

# Limpia el paquete descargado.
RUN rm packages-microsoft-prod.deb

# Actualiza los repositorios después de añadir el de Microsoft.
RUN apt-get update

# Instala el driver ODBC para SQL Server 18.
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18

# Instala las herramientas de línea de comandos mssql-tools18 (opcional: para bcp y sqlcmd).
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools18

# Añade las herramientas de SQL Server al PATH del usuario.
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc

# --- Instalación y Configuración de Extensiones PHP ---
# Instala y habilita las extensiones PHP necesarias para la aplicación.
RUN docker-php-ext-install zip \
    curl \
    mbstring \
    gettext \
    intl \
    pdo_pgsql \
    pgsql \
    pdo_mysql mysqli \
    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install pdo_odbc \
    && pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv \
    && a2enmod rewrite

# --- Instalación de Phalcon Framework ---
# Descarga, descomprime e instala la extensión Phalcon para PHP 8.3.
RUN wget -P /root/phalcon https://github.com/phalcon/cphalcon/releases/download/v5.9.0/phalcon-php8.3-nts-ubuntu-gcc-x64.zip
RUN unzip /root/phalcon/phalcon-php8.3-nts-ubuntu-gcc-x64.zip -d /root/phalcon
RUN cp /root/phalcon/phalcon.so /usr/local/lib/php/extensions/no-debug-non-zts-20230831/
RUN sh -c 'echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini'

# --- Instalación de Herramientas de Desarrollo (Opcional) ---
# Instala herramientas de desarrollo como git, vim, nano y Xdebug.
RUN apt-get update && apt-get install -y \
    git \
    vim \
    nano \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# --- Habilitación del Módulo Headers de Apache ---
# Habilita el módulo headers de Apache para permitir la manipulación de cabeceras HTTP.
RUN a2enmod headers

# --- Creación de Usuario para Volúmenes ---
# Define los argumentos para el nombre, UID y GID del usuario para volúmenes.
ARG USUARIO_VOLUME_NAME=<NAME_USUARIO_VOLUME>
ARG USUARIO_VOLUME_UID=<UID_USUARIO_VOLUME>
ARG USUARIO_VOLUME_GID=<GID_USUARIO_VOLUME>

# Crea el grupo y el usuario especificados para el manejo de volúmenes.
RUN addgroup --gid $USUARIO_VOLUME_GID $USUARIO_VOLUME_NAME && \
    adduser --system --uid $USUARIO_VOLUME_UID --gid $USUARIO_VOLUME_GID $USUARIO_VOLUME_NAME

# --- Configuración de Apache para Ejecutar como Usuario de Volúmenes ---
# Modifica la configuración de Apache para que se ejecute con el usuario especificado.
RUN sed -i "s/^User .*/User $USUARIO_VOLUME_NAME/" /etc/apache2/apache2.conf && \
    sed -i "s/^Group .*/Group $USUARIO_VOLUME_NAME/" /etc/apache2/apache2.conf

# --- Configuración del Directorio de Trabajo ---
# Establece el directorio de trabajo predeterminado para Apache.
WORKDIR /var/www/html
