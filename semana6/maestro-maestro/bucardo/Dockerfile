FROM postgres:15

# Instalar dependencias necesarias para Bucardo
RUN apt-get update && \
    apt-get install -y bucardo perl libdbi-perl libdbd-pg-perl libboolean-perl && \
    rm -rf /var/lib/apt/lists/*

    # Crear carpeta de configuración para Bucardo y darle permisos
RUN mkdir -p /var/run/bucardo /var/lib/postgresql/.bucardo && \
    chown -R postgres:postgres /var/run/bucardo /var/lib/postgresql/.bucardo

ENV BUCARDO_CONFIG /var/lib/postgresql/.bucardo/bucardorc

# Bucardo necesita carpeta para datos
RUN mkdir -p /var/run/bucardo && chown postgres:postgres /var/run/bucardo

USER postgres

# Comando por defecto (puedes cambiarlo después)
CMD ["bash"]
