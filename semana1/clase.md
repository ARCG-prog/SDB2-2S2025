# Clase 1

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
    - Nombre: `Postgres Local`
    - Host: `postgres`
    - Puerto: `5432`
    - Usuario: `postgres`
    - Contraseña: `postgres`
6. Conectar al servidor y crear una nueva base de datos llamada `clase1`.
7. Ejecutar el script `data.sql` para crear las tablas y cargar los datos iniciales en la base de datos `clase1`.
8. Verificar que las tablas se han creado correctamente y que los datos se han insertado.

## Notas

- Asegúrate de que Docker y Docker Compose están instalados y funcionando correctamente.
- Puedes usar DBeaver o cualquier otro cliente SQL para conectarte a la base de datos `clase1` si prefieres no usar pgAdmin.
- Si tienes problemas con la conexión, verifica que los contenedores de Docker están corriendo correctamente con el comando `docker ps`.
- Puedes detener los contenedores con `docker-compose down` cuando hayas terminado la clase.