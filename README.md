Automatización de la instalación, la configuración y el despliegue de servicios como ELK, Filebeat, Nginx, Mysql y Wordpress. Fue testeado en entornos deb (Debian y Ubuntu).

*Supported distros: Debian based.*

*Estos scripts utilizan sudo para ciertos comandos.*

Los pasos a seguir son sencillos:

1- Clonamos el repositorio y accedemos a el directorio. 
2- Ejecutamos web-deploy.sh en una maquina virtual (debemos recordar la ip de esta misma).
3- Ejecutamos elk-deploy.sh en otra maquina virtual (debemos recordar la ip de esta misma).
4- Una vez desplegado el sitio en Wordpress accedemos con las credenciales dadas luego, nos creamos un usuario, procedemos con la instalación y accedemos a nuestro sitio.
5- Asumiendo que llegamos al paso 4: ejecutamos wp-debug.sh (Para habilitar el debug en wordpress)
6- En la maquina que tengamos filebeat instalado editamos el archivo: /etc/filebeat/filebeat.yml. Debajo de la opción output.logstash en hosts: ["localhost:5044"] cambiamos localhost por la ip de la maquina virtual donde tengamos instalado el stack ELK.

¡Y listo, eso sería todo!
