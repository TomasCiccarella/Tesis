#!/bin/bash

# Ruta al archivo de parámetros de m2phi2
param_file="../src/models/parameter-files/m2phi2.in"

# Valor de m fijo (el original era 1.46e13)
m_fixed=1.46e13

# Valores de q para variar
qs=(25000 50000 75000 100000)

for q in "${qs[@]}"
do
    # 1. Definimos la carpeta de salida basada en q
    output_folder="./data/var_q/q_${q}/"

    echo "=============================================="
    echo "Ejecutando m2phi2 para q = $q"
    echo "Usando m constante = $m_fixed"
    echo "Configurando output en: $output_folder"
    echo "=============================================="

    # 2. Creamos el directorio
    mkdir -p "$output_folder"

    # 3. Modificamos el archivo .in usando sed
    # Cambiamos el outputfile
    sed -i "s|^outputfile *= *.*|outputfile = $output_folder|" "$param_file"

    # Modificamos el parámetro q
    sed -i "s/^q *= *.*/q = $q/" "$param_file"

    # Modificamos el parámetro m para asegurar consistencia
    sed -i "s/^m *= *.*/m = $m_fixed/" "$param_file"

    # 4. Ejecutamos CosmoLattice
    ./m2phi2 input="$param_file"

    echo "✔️ Simulación para q=$q terminada."
    echo ""
done
