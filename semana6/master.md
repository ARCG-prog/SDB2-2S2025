# Configuración del master

## postgresql.conf

Configura el comportamiento del servidor maestro:

Parámetro|Función
---|---
data_directory|Define dónde se guardan los datos de la DB
hba_file|Archivo de configuración de acceso
listen_addresses|Permite conexiones externas
wal_level|Activa los WAL para replicación
max_wal_senders|Número máximo de procesos de envío WAL (replicación)
archive_mode|Permite guardar copias de WAL
archive_command|Comando para almacenar los WALs

## pg_hba.conf

Controla quién se puede conectar y desde dónde.
Se usa trust para permitir conexiones sin contraseña en entorno de práctica.


