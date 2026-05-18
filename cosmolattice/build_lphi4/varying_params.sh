#!/bin/bash

# Ruta al archivo de parámetros
param_file="../src/models/parameter-files/lphi4.in"

# Valores de lambda y q
lambdas=(9e-14)
qs=(0.5 3.26 5 26 1000 5050)

for lambda in "${lambdas[@]}"
do
    for q in "${qs[@]}"
    do
        # 1. Definimos la carpeta exacta
        # Agregamos '/' al final para mantener el formato de tu archivo original
        output_folder="./data/short/no_exp/var_q/q_${q}/"

        echo "=============================================="
        echo "Ejecutando para lambda = $lambda, q = $q"
        echo "Configurando output en: $output_folder"
        echo "=============================================="

        # 2. Creamos el directorio (mkdir -p crea toda la ruta si no existe)
        mkdir -p "$output_folder"

        # 3. Modificamos el archivo .in
        # Usamos '|' como separador para que las barras '/' de la ruta no den error.
        sed -i "s|^outputfile *= *.*|outputfile = $output_folder|" "$param_file"

        # Modificamos lambda
        sed -i "s/^lambda *= *.*/lambda = $lambda/" "$param_file"

        # Modificamos q
        sed -i "s/^q *= *.*/q = $q/" "$param_file"

        # 4. Ejecutamos CosmoLattice
        ./lphi4 input="$param_file"

        echo "✔️ Terminado."
        echo ""
    done
done
