# Pasos

Piensa en IPFS como una versión P2P de la web. En la web normal (HTTP), accedes al contenido por su ubicación (ej. http://servidor.com/foto.jpg). En IPFS, accedes al contenido por lo que es (su hash criptográfico, una especie de huella digital única).

Esto significa que no importa quién te da el archivo, solo importa que el archivo tenga la huella digital correcta. Los nodos en la red IPFS colaboran para encontrar y distribuir contenido entre ellos.

El Objetivo de Nuestra Simulación
Crearemos una pequeña red P2P aislada con 3 nodos IPFS dentro de Docker. Haremos lo siguiente:

Iniciaremos 3 nodos que no se conocen entre sí.

Haremos que se descubran y se conecten para formar un pequeño "enjambre" (swarm).

Añadiremos un archivo en el Nodo A.

Veremos cómo el Nodo B puede recuperar ese archivo directamente del Nodo A, usando solo su hash, sin necesidad de un servidor central

1. Ejecutar el siguiente en la terminal :

```bash
    docker logs ipfs-node-a
```

La salida debería ser similar a la siguiente:

```
Changing user to ipfs
ipfs version 0.36.0
generating ED25519 keypair...done
peer identity: 12D3KooWC1AbRo5H6AGQe3ZiqutNRQ1nxm1UypRYcSBaRJ3oqYbL
initializing IPFS node at /data/ipfs
Initializing daemon...
Kubo version: 0.36.0-37b8411
Repo version: 16
System version: arm64/linux
Golang version: go1.24.5
PeerID: 12D3KooWC1AbRo5H6AGQe3ZiqutNRQ1nxm1UypRYcSBaRJ3oqYbL
2025/08/08 03:33:34 failed to sufficiently increase receive buffer size (was: 208 kiB, wanted: 7168 kiB, got: 416 kiB). See https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes for details.
Swarm listening on 127.0.0.1:4001 (TCP+UDP)
Swarm listening on 172.20.0.2:4001 (TCP+UDP)
Swarm listening on [::1]:4001 (TCP+UDP)
Run 'ipfs id' to inspect announced and discovered multiaddrs of this node.
RPC API server listening on /ip4/0.0.0.0/tcp/5001
WebUI: http://127.0.0.1:5001/webui
Gateway server listening on /ip4/0.0.0.0/tcp/8080
Daemon is ready
```

2. Copiar el `PeerID` que aparece en la salida del comando anterior. En este caso es:

```12D3KooWC1AbRo5H6AGQe3ZiqutNRQ1nxm1UypRYcSBaRJ3oqYbL```

3. En otra terminal, ejecutar el siguiente comando:

```bash
    docker-compose up -d ipfs-node-b ipfs-node-c
```

4. Ejecutar para el nodo B:

```bash
    docker exec -it ipfs-node-b sh
    ipfs swarm connect /dns4/ipfs-node-a/tcp/4001/p2p/12D3KooWC1AbRo5H6AGQe3ZiqutNRQ1nxm1UypRYcSBaRJ3oqYbL
    exit
```

5. Ejecutar para el nodo C:

```bash
    docker exec -it ipfs-node-c sh
    ipfs swarm connect /dns4/ipfs-node-a/tcp/4001/p2p/12D3KooWC1AbRo5H6AGQe3ZiqutNRQ1nxm1UypRYcSBaRJ3oqYbL
    exit
```

6. Volvemos al nodo A y ejecutamos el siguiente comando:

```bash
    docker exec -it ipfs-node-a sh
    echo "Esto es una prueba en una red P2P simulada con Docker" > prueba.txt
    ipfs add prueba.txt
```

La salida debería ser similar a la siguiente:

```
added Qmc1gEzU7SAkT8u1MwbRxMKeXKcDA5h72PPWyAZ1g24fFD prueba.txt
 54 B / ? [----------------------------------------------------------------------------------=-----------------------------------------------------]
```
7. Desde el nodo B o C, podemos verificar que el archivo se ha añadido correctamente ejecutando:

```bash
    docker exec -it ipfs-node-b sh
    ipfs cat Qmc1gEzU7SAkT8u1MwbRxMKeXKcDA5h72PPWyAZ1g24fFD
```

http://localhost:8080/ipfs/Qmc1gEzU7SAkT8u1MwbRxMKeXKcDA5h72PPWyAZ1g24fFD