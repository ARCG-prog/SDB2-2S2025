
# Configuración del slave

## postgresql.conf

Activa el modo `hot_standby`, lo que permite:

- Replicar los WALs desde el master
- Consultar la base de datos mientras replica (solo lectura)

## Configurar el esclavo (replica base)

1. Entras al contenedor pg-slave
2. Cambias al usuario postgres
3. Borras los datos existentes
4. Usas pg_basebackup para copiar los datos del master
    - `-Fp`: formato plano
    - `-Xs`: incluir archivos de WAL
    - `-P`: progreso
    - `-R`: crea automáticamente standby.signal y configura primary_conninfo