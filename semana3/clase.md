# Clase 3

Requisitos:

- Docker
- Docker Compose
- Imagen PostgresSQL
- Imagen pgAdmin
- DBeaver o cualquier otro cliente SQL

## Instrucciones

1. Clonar el repositorio de la clase.
2. Ejecutar el comando `docker-compose up -d` en la terminal dentro del directorio del repositorio clonado.
3. Abrir el navegador y acceder a `http://localhost:8080` para pgAdmin.
4. Iniciar sesión con las credenciales:
    - Usuario: `fernando@google.com`
    - Contraseña: `123456`
5. Crear un nuevo servidor en pgAdmin con los siguientes detalles:
    - Nombre: `my-database`
    - Host: `postgres`
    - Puerto: `5432`
    - Usuario: `fernando`
    - Contraseña: `S8DB2S2025`
6. Conectar al servidor y crear una nueva base de datos llamada `clase3`.
7. Ejecutar los scripts `ddl.sql` y `seed.sql`.

## Respaldo manual

Para realizar un respaldo manual de la base de datos, seguir los siguientes pasos:

1. En la terminal, ejecutar el comando:

```bash
   docker exec -t my-database pg_dump -U fernando -d bases2-db > respaldo_logico.sql
```

2. Este comando creará un archivo `respaldo_logico.sql` en el directorio actual con el respaldo de la base de datos `bases2-db`.

## Script Bash para automatizar respaldos lógicos

Para automatizar el proceso de respaldo lógico, se puede crear un script Bash. A continuación se muestra un ejemplo de cómo hacerlo:

```bash
#!/bin/bash

# Variables
FECHA=$(date +%F_%H-%M)
BACKUP_DIR=./respaldos
ARCHIVO=$BACKUP_DIR/mi_base_$FECHA.sql

# Crear carpeta si no existe
mkdir -p $BACKUP_DIR

# Ejecutar backup lógico desde Docker
docker exec -t my-database pg_dump -U fernando -d bases2-db > "$ARCHIVO"

# Limpiar respaldos de más de 7 días
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Respaldo completado: $ARCHIVO"
```

Dar permisos de ejecución al script:

```bash
    chmod +x auto_backup.sh
```

Luego, se puede ejecutar el script con:

```bash
    ./auto_backup.sh
```
