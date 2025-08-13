# Implementación básica

## MongoDB

1. Instalación rápida con Docker:

```bash
docker run -d -p 27017:27017 --name mongo mongo
```

2. Insertar un documento:

```bash
docker exec -it mongo mongosh
```

```javascript
use tienda
db.productos.insertOne({nombre: "Camisa", precio: 20})
```

3. Consultar documentos:

```javascript
db.productos.find({precio: {$gt: 10}})
db.productos.find()
```

## Redis

1. Instalación rápida con Docker:

```bash
docker run -d -p 6379:6379 --name redis redis
```

2. Insertar un valor:

```bash
docker exec -it redis redis-cli
```

```bash
SET sesion:usuario123 "activo"
GET sesion:usuario123
```