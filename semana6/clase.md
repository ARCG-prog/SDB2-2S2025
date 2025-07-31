# Clase 6

Guía de instrucción para la ejecución de la parte práctica:

## Carpetas y archivos:

- `semana6/`
  - `docker-compose.yml`: (archivo de configuración de Docker Compose)
  - `master/` (carpeta para la configuración del maestro)
    - `postgresql.conf`: (configuración del servidor PostgreSQL maestro)
    ```config
        data_directory = '/var/lib/postgresql/data'
        hba_file = '/var/lib/postgresql/conf/pg_hba.conf'
        listen_addresses = '*'
        port = 5432
        max_wal_senders = 10
        wal_level = replica
        wal_keep_size = 64
        archive_mode = on
        archive_command = 'cp %p /var/lib/postgresql/data/archive/%f'
    ```
    - `pg_hba.conf`: (configuración de acceso del servidor PostgreSQL maestro)
    ```config
        local   all             all                                     trust
        host    all             all             0.0.0.0/0               trust
        host    replication     replicator      0.0.0.0/0               trust
    ```
  - `slave/` (carpeta para la configuración del esclavo)
    - `postgresql.conf`: (configuración del servidor PostgreSQL esclavo)
    ```config
        data_directory = '/var/lib/postgresql/data'
        hba_file = '/var/lib/postgresql/conf/pg_hba.conf'
        hot_standby = on
        port = 5432
    ```
    - `pg_hba.conf`: (configuración de acceso del servidor PostgreSQL esclavo)
    ```config
        local   all             all                                     trust
        host    all             all             0.0.0.0/0               trust
        ```


## Pasos

1. Crear el archivo `docker-compose.yml` con el siguiente contenido:

```yaml
services:
  master:
    image: postgres:15.3
    container_name: pg-master
    restart: always
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: replicator
      POSTGRES_PASSWORD: replica_pass
      POSTGRES_DB: demo
    volumes:
      - ./master:/var/lib/postgresql/conf
    command: >
      postgres -c config_file=/var/lib/postgresql/conf/postgresql.conf

  slave:
    image: postgres:15.3
    container_name: pg-slave
    restart: always
    ports:
      - "5433:5432"
    environment:
      POSTGRES_USER: replicator
      POSTGRES_PASSWORD: replica_pass
      POSTGRES_DB: demo
    depends_on:
      - master
    volumes:
      - ./slave:/var/lib/postgresql/conf
    command: >
      postgres -c config_file=/var/lib/postgresql/conf/postgresql.conf
```

2. Ejecutar el comando para iniciar los servicios definidos en el archivo `docker-compose.yml`:

```bash
    docker compose up -d
```

3. Verificar que los contenedores se estén ejecutando correctamente:

```bash
    docker ps
```

4. Configurar esclavo para replicación

```bash
    docker exec -it pg-slave bash
```

5. Cambiar al usuario postgres

```bash
    su - postgres
```

6. Elimina el contenido del data directory:

```bash
    rm -rf /var/lib/postgresql/data/*
```

7. jecuta pg_basebackup para clonar desde pg-master

```bash
    PGPASSWORD=replica_pass /usr/lib/postgresql/15/bin/pg_basebackup -h pg-master -U replicator -D /var/lib/postgresql/data -Fp -Xs -P -R
```

8. Salir del contenedor esclavo:

```bash
    exit
```

9. Reiniciar el contenedor esclavo para aplicar los cambios:

```bash
    docker restart pg-slave
```

10. Verificar que funciona la replicación

```bash
    docker exec -it pg-master psql -U replicator -d demo
```

11. Crear una tabla de prueba en el maestro:

```sql
    CREATE TABLE sensores (
        id SERIAL PRIMARY KEY,
        ubicacion TEXT,
        lectura NUMERIC,
        fecha TIMESTAMP DEFAULT now()
    );

    INSERT INTO sensores (ubicacion, lectura) VALUES ('Zona 1', 22.5), ('Zona 2', 23.7);
```

12. Consultar los datos en el esclavo:

```bash
    docker exec -it pg-slave psql -U replicator -d demo -p 5432
```

13. Verificar que los datos se replicaron correctamente:

```sql
    SELECT * FROM sensores;
```

## Activar replicación síncrona

1. En el master

```bash
    docker exec -it pg-master psql -U replicator -d demo
```

2. Verifica el nombre del standby:

```sql
    SELECT application_name FROM pg_stat_replication;
```

salida:
```diff
 application_name 
------------------
 walreceiver
```

3. Activar sincronía

```sql
    ALTER SYSTEM SET synchronous_standby_names = 'walreceiver';
    SELECT pg_reload_conf();
```

4. Confirmar

```sql
    SELECT application_name, state, sync_state FROM pg_stat_replication;
```

5. Insertar datos en el maestro:

```sql
    INSERT INTO sensores (ubicacion, lectura) VALUES ('Zona Sync', 30.2);

    INSERT INTO sensores (ubicacion, lectura) VALUES ('Zona Sync2', 40.5);
```

6. Verificar en el esclavo:

```bash
    docker exec -it pg-slave psql -U replicator -d demo -p 5432
```

```sql
    SELECT * FROM sensores;
```