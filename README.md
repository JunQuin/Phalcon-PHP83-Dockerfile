# Dockerfile para PHP 8.3 con Phalcon y SQL Server

Este repositorio contiene un `Dockerfile` para construir una imagen de Docker con PHP 8.3, el framework Phalcon, y soporte para SQL Server.

## Descripción

El `Dockerfile` proporciona un entorno de desarrollo completo para aplicaciones PHP que utilizan el framework Phalcon y necesitan conectarse a bases de datos SQL Server, PostgreSQL y MySQL. Incluye las siguientes características:

* **PHP 8.3 con Apache:** Se utiliza la imagen base `php:8.3-apache`.
* **Dependencias del Sistema:** Se instalan las dependencias necesarias para las extensiones PHP, controladores de bases de datos y utilidades del sistema.
* **Drivers de SQL Server:** Se configura el repositorio de Microsoft e instalan los drivers ODBC para SQL Server 18.
* **Extensiones PHP:** Se instalan y habilitan las extensiones PHP necesarias, incluyendo `sqlsrv` y `pdo_sqlsrv` para la conexión a SQL Server.
* **Framework Phalcon:** Se descarga, descomprime e instala la extensión Phalcon para PHP 8.3.
* **Herramientas de Desarrollo (Opcional):** Se incluyen herramientas de desarrollo como `git`, `vim`, `nano` y `xdebug`.
* **Configuración de Apache:** Se habilita el módulo `headers` y se configura Apache para ejecutarse con un usuario específico para el manejo de volúmenes.

## Requisitos Previos

* [Docker](https://www.docker.com/) instalado en tu sistema.

## Cómo Utilizar

1.  **Construir la Imagen:**
    Navega hasta el directorio que contiene el `Dockerfile` y ejecuta el siguiente comando:

    ```bash
    docker build \
        --build-arg USUARIO_VOLUME_NAME=$(whoami) \
        --build-arg USUARIO_VOLUME_UID=$(id -u) \
        --build-arg USUARIO_VOLUME_GID=$(id -g) \
        -t php83-phalcon .
    ```

    Este comando construye la imagen de Docker y la etiqueta como `php83-phalcon`. Los argumentos `--build-arg` se utilizan para configurar el usuario y grupo para los volúmenes, permitiendo una mejor integración con el sistema de archivos del host.

2.  **Ejecutar el Contenedor:**
    Ejecuta el siguiente comando para iniciar un contenedor basado en la imagen construida:

    ```bash
    docker run -d -p 8082:80 --name php83-phalcon -v /home/junquin/html:/var/www/html php83-phalcon:latest
    ```

    Este comando ejecuta el contenedor en modo *detached* (-d), mapea el puerto 8082 del host al puerto 80 del contenedor, le asigna el nombre `php83-phalcon` y monta el directorio `/home/junquin/html` del host en el directorio `/var/www/html` del contenedor. Reemplace `/home/junquin/html` con la ruta a su directorio de trabajo.

3.  **Acceder a la Aplicación:**
    Abre tu navegador web y navega a `http://localhost:8082` para acceder a tu aplicación PHP.

## Personalización

* **Extensiones PHP:** Puedes agregar o modificar las extensiones PHP instaladas en el `Dockerfile`.
* **Herramientas de Desarrollo:** Puedes personalizar las herramientas de desarrollo instaladas según tus necesidades.
* **Configuración de Apache:** Puedes modificar la configuración de Apache para adaptarla a tus requisitos específicos.
* **Framework Phalcon Version:** puedes ajustar la version de phalcon modificando la url de descarga del archivo .zip

## Contribución

¡Las contribuciones son bienvenidas! Si encuentras algún problema o tienes sugerencias para mejorar este `Dockerfile`, por favor, abre un *issue* o envía un *pull request*.