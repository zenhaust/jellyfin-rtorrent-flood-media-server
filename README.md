# mediaserver-jellyfin-rtorrent-flood

Conjunto de servidor de medios + herramienta de descargas + herramienta de control de descargas

* Servidor de medios: [**Jellyfin**](https://jellyfin.org/) 
* Cliente BitTorrent: [**rTorrent**](https://github.com/rakshasa/rtorrent)
* Control de rTorrent: [**Flood**](https://github.com/Flood-UI/flood)



Se requiere docker / docker-compose

```bash
docker-compose up -d
```

Una vez levantados los contenedores, puedes acceder al servidor de medios a traves de la dirección 
[http://localhost:8096](http://localhost:8096).

La herramienta de gestión de descargas a través de rTorrent se encontrará accesible 
en [http://localhost:3001](http://localhost:3001). 

Los puertos de los distintos elementos pueden modificarse en el propio 
[docker-compose.yml](docker-compose.yml) que levanta el sistema.


**NOTA:** rTorrent admite solicitudes XML-RPC en el puerto 16891. El puerto no está abierto al 
exterior de la red declarada en [docker-compose.yml](docker-compose.yml).


## Sobre los servicios

### Jellyfin

Se debe prestar especial atención a los puntos de montaje. 
No requiere de ningún build. 

### rTorrent

Se construye la imagen desde los fuentes originales, puesto que por defecto los paquetes en 
distribución, no tienen soporte para XML-RPC. Dicho soporte es necesario para poder acceder
a rTorrent desde Flood.

### Flood

El servicio inicia con gestión de usuarios por defecto. Se solicitará autenticación, y 
configuración de host (nombre de contenedor) y puerto de rTorrent.

* **host:** Configurado en [docker-compose.yml](docker-compose.yml#L30): media-system-rtorrent
* **port:** Expuesto en [Dockerfile.rtorrent](containers/rtorrent/Dockerfile.rtorrent#L94): 16891

Existe la posibilidad de excluir el mecanismo de autenticación, modificando el entrypoint.

```bash 
    ...
    # Autenticación activa. Pedirá configurar host 
    #entrypoint: ["flood", "--host=0.0.0.0"] 
    # En entornos controlados, SIN autenticación.
    entrypoint: ["flood", "--host=0.0.0.0","--rthost=media-system-rtorrent", "--rtport=16891", "-n"] 
    ...
``` 

## Estructura de directorios

```bash
├── README.md
├── containers
│   ├── flood
│   │   └── config
│   ├── jellyfin
│   │   └── config
│   └── rtorrent
│       ├── Dockerfile.rtorrent
│       ├── config
│       └── torrents
├── docker-compose.yml
└── media
    ├── Cine
    ├── IPTV
    ├── Musica
    ├── Series
    └── Unclassified
        ├── finished
        └── loading
```

### containers/rtorrent/torrents

Aquí podemos poner los \*.torrent, e inmediatamente comienzan a descargarse.

Mientras se descargan se ubican en media/Unclassified/loading.

Cuando terminan van a parar a media/Unclassified/finished.

Por último, tu decides a que directorio de media quieres que vayan
los archivos descargados.

**NOTA:** Este mecanismos es útil si queremos ubicar masivamente \*.torrent.
La propia herramienta Flood permite subir torrent.


### media

Los subdirectorios existentes en este directorio se montan como volumenes 
para el servidor de medios \([docker-compose.yml](docker-compose.yml#L11)\).

Según se ha mencionado, el subdirectorio Unclassified contiene el material
descargado, o en descarga, pendiente de clasificar.

### Directorios config de cada contenedor

Destinados a guardar de forma persistente los datos de sesión de rTorrent, 
los datos de configuración, bibliotecas, y usuarios de Jellyfin, u otros 
datos de configuración y funcionamiento de Flood.


## Problemas comunes

### No se escribe nada en el directorio config de Flood

O lo que es lo mismo, los datos de conexión a la interfaz no son persistentes.

La imagen de Flood utilizada crea un usuario con UID 1100. El directorio
ha de tener privilegios de escritura para dicho UID. 

El log del contenedor mostrará el problema.

```bash 
    find containers/flood/* -type d -exec chmod 777 {} \;
    find containers/flood/* -type f -exec chmod 666 {} \;
``` 
En otro caso lo normal será modificar el argumento UGID en 
[docker-compose.yml](docker-compose.yml) para que ajuste a un usuario del sistema.

**NOTA:** No pueden uilizarse los UGID 1000 y 1001. 


### No se escribe nada en el directorio config de rTorrent

Se trata del mismo problema que en el caso anterior. 

Por defecto la imagen se construye con UID / GID 1100. 
Ver [Dockerfile.rtorrent](containers/rtorrent/Dockerfile.rtorrent#L3).

Para entornos controlados, se puede salir rápido del paso otorgando privilegios 
de lectura / escritura para todo el mundo.

```bash 
    find containers/rtorrent/* -type d -exec chmod 777 {} \;
    find containers/rtorrent/* -type f -exec chmod 666 {} \;
``` 

En otro caso lo normal será modificar el argumento UGID en 
[docker-compose.yml](docker-compose.yml) para que ajuste a un usuario del sistema.

**NOTA:** No pueden uilizarse los UGID 1000 y 1001. 

