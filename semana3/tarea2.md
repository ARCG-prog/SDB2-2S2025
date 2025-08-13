# Tarea 2

Pasos para crear un backup de una base de datos PostgreSQL usando pgBackRest:

1. Agregar al ```docker-compose.yml`` el servicio de pgBackRest:

```yaml
volumes:
      - ./postgres:/var/lib/postgresql/data
      - ./wal-archive:/var/lib/postgresql/wal_archive
      - ./pgbackrest-data:/var/lib/pgbackrest # Agregar esta línea
```

2. Apagar y encender el contenedor de PostgreSQL para aplicar los cambios:

```bash
docker-compose down
docker-compose up -d
```

3. Ingreasr al contenedor de PostgreSQL:

```bash
docker exec -it my-database bash
```

4. Actualizar e instalar pgBackRest:

```bash
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y pgbackrest cron nano
```

5. Configurar el archivo ```/etc/pgbackrest.conf```:

```ini
[global]
repo1-path=/var/lib/pgbackrest
log-level-console=info

[bases2-db]
pg1-path=/var/lib/postgresql/data
pg1-port=5432
pg1-user=fernando

[GLOBAL:retention]
repo1-retention-full=2
repo1-retention-diff=3
```

6. Editar el archivo ```nano /var/lib/postgresql/data/postgresql.conf``` para habilitar el modo de archivo y establecer el nivel de registro:

```conf
wal_level = replica
archive_mode = on
archive_command = '/usr/bin/pgbackrest --stanza=bases2-db archive-push %p'
archive_timeout = 1
```

7. Editar el archivo ```nano /var/lib/postgresql/data/postgresql.auto.conf``` para habilitar el comando de archivo:

```conf
archive_mode = 'on'
wal_level = 'replica'
# archive_command = 'pgbackrest --stanza=bases2-db archive-push %p'
```


7. Crear el "stanza" de pgBackRest:

```bash
pgbackrest --stanza=bases2-db stanza-create
```

8. Crear un backup completo:

```bash
pgbackrest --stanza=bases2-db --type=full --archive-check=n backup
```

9. Verificar el estado del backup:

```bash
pgbackrest --stanza=bases2-db info
```

Ejemplo de salida:

```
stanza: bases2-db
    status: ok
    cipher: none

    db (current)
        wal archive min/max (15): none present

        full backup: 20250807-053149F
            timestamp start/stop: 2025-08-07 05:31:49+00 / 2025-08-07 05:31:51+00
            wal start/stop: 000000010000000000000021 / 000000010000000000000022
            database size: 29.5MB, database backup size: 29.5MB
            repo1: backup set size: 3.9MB, backup size: 3.9MB
```

10. Crear un backup diferencial:

```bash
pgbackrest --stanza=bases2-db --type=diff --archive-check=n backup
```

11. Crear un backup incremental:

```bash
pgbackrest --stanza=bases2-db --type=incr --archive-check=n backup
```

12. Verificar el estado de los backups:

```bash
pgbackrest --stanza=bases2-db info
```

Ejemplo de salida:

```
stanza: bases2-db
    status: ok
    cipher: none

    db (current)
        wal archive min/max (15): none present

        full backup: 20250807-053149F
            timestamp start/stop: 2025-08-07 05:31:49+00 / 2025-08-07 05:31:51+00
            wal start/stop: 000000010000000000000021 / 000000010000000000000022
            database size: 29.5MB, database backup size: 29.5MB
            repo1: backup set size: 3.9MB, backup size: 3.9MB

        incr backup: 20250807-053149F_20250807-053717I
            timestamp start/stop: 2025-08-07 05:37:17+00 / 2025-08-07 05:37:18+00
            wal start/stop: 000000010000000000000027 / 000000010000000000000027
            database size: 29.5MB, database backup size: 1.6MB
            repo1: backup set size: 3.9MB, backup size: 189.7KB
            backup reference total: 1 full

        diff backup: 20250807-053149F_20250807-053801D
            timestamp start/stop: 2025-08-07 05:38:01+00 / 2025-08-07 05:38:02+00
            wal start/stop: 000000010000000000000029 / 000000010000000000000029
            database size: 29.5MB, database backup size: 1.6MB
            repo1: backup set size: 3.9MB, backup size: 189.7KB
            backup reference total: 1 full
```