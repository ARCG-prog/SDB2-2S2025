# Maestro-Esclavo con Docker Compose

1. Crear las carpetas necesarias:
```bash
mkdir -p primary/init
```

2. Crear el archivo `docker-compose.yml` con el siguiente contenido:
```yaml
services:
  pg-primary:
    image: postgres:16
    container_name: pg-primary
    ports: ["5432:5432"]
    environment:
      POSTGRES_PASSWORD: postgres
    command: ["postgres",
      "-c","wal_level=replica",
      "-c","max_wal_senders=10",
      "-c","max_replication_slots=10",
      "-c","listen_addresses=*",
      "-c","hba_file=/etc/postgresql/pg_hba.conf"
    ]
    volumes:
      - ./primary/pg_hba.conf:/etc/postgresql/pg_hba.conf:ro
      - ./primary/init:/docker-entrypoint-initdb.d
      - primary-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL","pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 30
    networks: [pgnet]
volumes:
  primary-data:
networks:
  pgnet:
```

3. Crear el archivo `pg_hba.conf` en la carpeta `primary` con el siguiente contenido:
```
# TYPE  DATABASE     USER         ADDRESS         METHOD
local   all          all                          trust
host    all          all          0.0.0.0/0       scram-sha-256
host    all          all          ::/0            scram-sha-256
host    replication  replicator   0.0.0.0/0       scram-sha-256
host    replication  replicator   ::/0            scram-sha-256
```

4. Crear el archivo `01_init.sql` en la carpeta `primary/init` con el siguiente contenido:
```sql
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replica_pass';
CREATE USER app WITH PASSWORD 'app_pass';
CREATE DATABASE demo OWNER app;
GRANT ALL PRIVILEGES ON DATABASE demo TO app;
```

5. Levantar el contenedor:
```bash
docker compose up -d pg-primary
```

4. Verificar la configuración:
```bash
docker exec -it pg-primary psql -U postgres -c "SHOW listen_addresses;"
# Debería devolver '*'

docker exec -it pg-primary psql -U postgres -c "SHOW wal_level;"
# Debería devolver 'replica'

docker exec -it pg-primary psql -U postgres -c "SHOW max_wal_senders;"
# Debería devolver '10'

docker exec -it pg-primary psql -U postgres -c "SHOW max_replication_slots;"
# Debería devolver '10'

docker exec -it pg-primary psql -U postgres -c "\du+ replicator"
#              List of roles
# Role name  | Attributes  | Description 
# ------------+-------------+-------------
# replicator | Replication | 

docker exec -it pg-primary psql -U app -d demo -c "SELECT current_database(), current_user;"
#  current_database | current_user 
# ------------------+--------------
#  demo             | app
```

5. Agregamos un esclavo :
```yaml
services:
    pg-replica:
        image: postgres:16
        container_name: pg-replica
        ports: ["5433:5432"]
        environment:
        POSTGRES_PASSWORD: postgres
        command: ["postgres",
        "-c","hot_standby=on",
        "-c","listen_addresses=*"
        ]
        volumes:
        - replica-data:/var/lib/postgresql/data
        depends_on:
        - pg-primary
        healthcheck:
        test: ["CMD-SHELL","pg_isready -U postgres"]
        interval: 5s
        timeout: 3s
        retries: 30
        networks: [pgnet]

volumes:
    primary-data:
    replica-data:
networks:
    pgnet:
```

6. Corremos el esclavo:
```bash
docker compose up -d pg-replica
```

7. Verificamos el slot del esclavo:
```bash
docker exec -it pg-primary psql -U postgres -c "SELECT slot_name, active FROM pg_replication_slots WHERE slot_name='replica1';"
#   slot_name | active 
# -----------+--------
#  (0 rows)
```

8. Configuramos el slot:
```bash
docker exec -it pg-primary psql -U postgres -v ON_ERROR_STOP=1 -c "SELECT pg_create_physical_replication_slot('replica1');"
#  pg_create_physical_replication_slot 
# -------------------------------------
#  (replica1,)
```

9. Verificamos el slot nuevamente:
```bash
docker exec -it pg-primary psql -U postgres -c "SELECT slot_name, active FROM pg_replication_slots WHERE slot_name='replica1';"
#  slot_name | active 
# -----------+--------
#  replica1  | f
```

10. Reconectamos el esclavo:
```bash
docker restart pg-replica
```

11. Comprobamos:
```bash
docker exec -it pg-replica psql -U postgres -c "SELECT status FROM pg_stat_wal_receiver;"
#   status   
# -----------
#  streaming

docker exec -it pg-primary psql -U postgres -c "SELECT application_name, state FROM pg_stat_replication;"
#  application_name |   state   
# ------------------+-----------
#  replica1         | streaming

docker exec -it pg-primary psql -U postgres -c "SELECT slot_name, active FROM pg_replication_slots WHERE slot_name='replica1';"
docker exec -it pg-primary psql -U postgres -c "SELECT slot_name, active FROM pg_replication_slots WHERE slot_name='replica1';"
#  slot_name | active 
# -----------+--------
#  replica1  | t
```

12. Probamos la replicación:
```bash
# En el primario
docker exec -it pg-primary psql -U app -d demo -c "CREATE TABLE IF NOT EXISTS t1(id serial PRIMARY KEY, data text);"
docker exec -it pg-primary psql -U app -d demo -c "INSERT INTO t1(data) VALUES ('hola'),('replica-ok');"

# En el esclavo
docker exec -it pg-replica psql -U app -d demo -c "TABLE t1;"

# Verificar en modo standby recovery
docker exec -it pg-replica psql -U postgres -c "SELECT pg_is_in_recovery();"

## DEBERIA FALLAR AL INSERTAR
docker exec -it pg-replica psql -U app -d demo -c "INSERT INTO t1(data) VALUES ('deberia-fallar');"
```

13. Failover:
```bash
docker stop pg-primary
```

14. Promover el esclavo a primario:
```bash
docker exec -it pg-replica psql -U postgres -c "SELECT pg_promote(wait => true);"

docker exec -it pg-replica psql -U postgres -c "SELECT pg_is_in_recovery();"
# f

# Debe permitir escritura
docker exec -it pg-replica psql -U app -d demo -c "INSERT INTO t1(data) VALUES ('failover-ok');"
docker exec -it pg-replica psql -U app -d demo -c "TABLE t1;"
```