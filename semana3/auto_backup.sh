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