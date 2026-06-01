#!/bin/bash

# Ruta al archivo de parámetros de m2phi2
param_file="../src/models/parameter-files/m2phi2.in"

# Valor de q fijo (podés ajustarlo al valor que necesites)
q_fixed=16000

# Valores de m para variar (en notación científica o decimal)
ms=(2.435e11 2.435e15 2.435e16)

for m in "${ms[@]}"
do
    # 1. Definimos la carpeta de salida basada en m
    output_folder="./data/var_m/m_${m}/"

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
