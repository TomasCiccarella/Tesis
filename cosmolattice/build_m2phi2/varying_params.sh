#!/bin/bash

# Ruta al archivo de parámetros de m2phi2
param_file="../src/models/parameter-files/m2phi2.in"

# Valores de m para variar (puedes agregar los que necesites)
# El valor original era 1.46e13
ms=(1.0e13 1.46e13 2.0e13)

# El valor de q calculado para que g sea ~1.024e-3
q_fixed=7280

for m in "${ms[@]}"
do
    # 1. Definimos la carpeta de salida
    output_folder="./data/m2phi2/var_m/m_${m}/"

    echo "=============================================="
    echo "Ejecutando m2phi2 para m = $m"
    echo "Usando q constante = $q_fixed"
    echo "Configurando output en: $output_folder"
    echo "=============================================="

    # 2. Creamos el directorio
    mkdir -p "$output_folder"

    # 3. Modificamos el archivo .in usando sed
    # Cambiamos el outputfile
    sed -i "s|^outputfile *= *.*|outputfile = $output_folder|" "$param_file"

    # Modificamos el parámetro m
    sed -i "s/^m *= *.*/m = $m/" "$param_file"

    # Modificamos el parámetro q para asegurar consistencia
    sed -i "s/^q *= *.*/q = $q_fixed/" "$param_file"

    # 4. Ejecutamos CosmoLattice
    ./m2phi2 input="$param_file"

    echo "✔️ Simulación para m=$m terminada."
    echo ""
done
