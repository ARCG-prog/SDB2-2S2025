# Clase 5

## Pasos

1. Crear el docker-compose.yml

```yaml
services:
  cockroach1:
    image: cockroachdb/cockroach:v23.1.11
    container_name: cockroach1
    command: start --insecure --join=cockroach1,cockroach2,cockroach3
    ports:
      - "8080:8080"   # UI Web
      - "26257:26257" # PostgreSQL port
    volumes:
      - cockroach1-data:/cockroach/cockroach-data
    networks:
      - cockroach-net

  cockroach2:
    image: cockroachdb/cockroach:v23.1.11
    container_name: cockroach2
    command: start --insecure --join=cockroach1,cockroach2,cockroach3
    networks:
      - cockroach-net
    volumes:
      - cockroach2-data:/cockroach/cockroach-data

  cockroach3:
    image: cockroachdb/cockroach:v23.1.11
    container_name: cockroach3
    command: start --insecure --join=cockroach1,cockroach2,cockroach3
    networks:
      - cockroach-net
    volumes:
      - cockroach3-data:/cockroach/cockroach-data

volumes:
  cockroach1-data:
  cockroach2-data:
  cockroach3-data:

networks:
  cockroach-net:
```

2. Iniciar el cluster de CockroachDB

```bash
    docker-compose up -d
```

3. Inicializar el cluster

```bash
    docker exec -it cockroach1 ./cockroach init --insecure --host=cockroach1
```

4. Acceder a la interfaz web

Abrir el navegador y acceder a `http://localhost:8080` para la interfaz web de CockroachDB.

5. Crear una base de datos

Conectarse al contenedor de CockroachDB y crear una base de datos:

```bash
    docker exec -it cockroach1 ./cockroach sql --insecure --host=cockroach1
```

Dentro del shell de CockroachDB, ejecutar:

```sql
    CREATE DATABASE prueba_replica;
    USE prueba_replica;

    CREATE TABLE sensores (
        id SERIAL PRIMARY KEY,
        ubicacion STRING,
        lectura FLOAT,
        fecha TIMESTAMPTZ DEFAULT now()
    );

    INSERT INTO sensores (ubicacion, lectura) VALUES ('Zona 1', 23.7);
    INSERT INTO sensores (ubicacion, lectura) VALUES ('Zona 2', 25.1);
```

6. En otra terminal, conectarse al contenedor de CockroachDB y verificar la replicación:

```bash
    for i in {1..5}; do
        docker exec -it cockroach3 ./cockroach sql --insecure --host=cockroach3 -e "SELECT * FROM prueba_replica.sensores ORDER BY id DESC LIMIT 1;"
        sleep 1
    done
```

7. Simular fallo de nodo 2:

```bash
    docker stop cockroach2
```

8. Insertar nuevos datos en el nodo 1:

```bash
    docker exec -it cockroach1 ./cockroach sql --insecure --host=cockroach1
```

```sql
    INSERT INTO sensores (ubicacion, lectura) VALUES ('Zona 3', 28.0);
```

9. Recuperar el nodo 2:

```bash
    docker start cockroach2
```

10. En otra terminal, verificar que los datos se han replicado correctamente:

```bash
    for i in {1..5}; do
        docker exec -it cockroach3 ./cockroach sql --insecure --host=cockroach3 -e "SELECT * FROM prueba_replica.sensores ORDER BY id DESC;"
        sleep 1
    done
```

11. Detener el cluster de CockroachDB:

```bash
    docker-compose down -v
```

```bash
docker exec -it cockroach1 ./cockroach sql --insecure --host=cockroach1 -e "SHOW RANGES FROM TABLE prueba_replica.sensores;"
```