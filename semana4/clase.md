# Clase 4

## Crear estructura de carpetas en el host

Ejecutar los siguientes comandos en la terminal:

```bash
  mkdir -p ./data
  mkdir -p ./backup
  mkdir -p ./wal_archive
```

## Docker Compose

Crear un archivo `docker-compose.yml` con el siguiente contenido:

```yaml
services:
  postgres:
    image: postgres:15.3
    container_name: pg_pitr
    environment:
      - POSTGRES_USER=fernando
      - POSTGRES_PASSWORD=S8DB2S2025
      - POSTGRES_DB=bases2-db
    volumes:
      - ./data:/var/lib/postgresql/data
      - ./wal_archive:/var/lib/postgresql/wal_archive
    ports:
      - 5432:5432`
```

## Configurar postgresql.conf dentro del contenedor

Instalar el editor `nano` dentro del contenedor:

```bash
  docker exec -it pg_pitr bash
  apt update && apt install nano -y
```

Abrir el archivo `postgresql.conf`:

```bash
  nano /var/lib/postgresql/data/postgresql.conf
```

Agrega/modifica las siguientes líneas

```conf
  archive_mode = on
  archive_command = 'cp %p /var/lib/postgresql/wal_archive/%f'
  wal_level = replica
```

También asegúrate de tener estas líneas activas

```conf
    listen_addresses = '*'
    port = 5432
```

Reinicia el contenedor

```bash
  exit
  docker restart pg_pitr
```

## Crear tabla y datos

Conéctate a la base de datos:

```bash
  docker exec -it pg_pitr psql -U fernando -d bases2-db
```

Crea una tabla y agrega algunos datos:

```sql
CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

INSERT INTO employees (name) VALUES 
  ('John Smith'),
  ('Emily Johnson'),
  ('Michael Brown'),
  ('Sophia Davis'),
  ('Daniel Wilson');

SELECT now(); -- Guarda el timestamp actual para usarlo en la recuperación 2025-07-29 19:49:48.800847+00
CHECKPOINT;
SELECT pg_switch_wal();

SELECT * FROM employees;
```

## Hacer un backup

Para hacer un backup de la base de datos, ejecuta el siguiente comando:

```bash
docker run --rm \
  -v ./backup:/backup \
  --network container:pg_pitr \
  postgres:15.3 \
  pg_basebackup -h localhost -U fernando -D /backup -Fp -Xs -P -v
```

## Simular pérdida de datos

Para simular una pérdida de datos, elimina la tabla `employees`:

```bash
  docker exec -it pg_pitr psql -U fernando -d bases2-db
```

```sql
  DROP TABLE employees;
  \q
```

## Recuperar al estado anterior (PITR)

1. Eliminar el contenedor

```bash
  docker-compose down
```

2. Borra la carpeta data y reemplázala por el backup

```bash
  rm -rf data
  cp -r backup data
```

3. Ejecutar los siguientes comandos para configurar la recuperación:

```bash
  echo "restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'" >> data/postgresql.auto.conf
  echo "recovery_target_time = '2025-07-29 19:49:48.800847+00'" >> data/postgresql.auto.conf
  touch data/recovery.signal
```