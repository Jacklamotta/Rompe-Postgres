#!/bin/bash

# Archivos con los datos
hosts_file="hosts.txt"
credentials_file="credentials.txt"
databases_file="databases.txt"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Calcular el total de intentos
total_attempts=$(($(wc -l < "$hosts_file") * $(wc -l < "$credentials_file") * $(wc -l < "$databases_file")))
current_attempt=0

# Iterar sobre cada combinación de host, usuario, contraseña y base de datos
while IFS= read -r host; do
    while IFS=':' read -r user pass; do
        while IFS= read -r database; do
            let current_attempt+=1
            echo -e "Intento $current_attempt de $total_attempts: Probando $host con usuario $user en la base $database..."
            # Intentar conectarse
            PGPASSWORD=$pass psql -h "$host" -U "$user" -d "$database" -p 5432 -c '\q' 2>/dev/null
            exit_status=$?
            if [[ $exit_status -eq 0 ]]; then
                echo -e "${GREEN}Conexión exitosa a $host con usuario $user y contraseña $pass en la base $database${NC}"
            else
                echo -e "${RED}Fallo al conectar a $host con usuario $user y contraseña $pass en la base $database (Código de salida: $exit_status)${NC}"
            fi
        done < "$databases_file"
    done < "$credentials_file"
done < "$hosts_file"
