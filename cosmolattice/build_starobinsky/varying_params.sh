#!/bin/bash

# Ruta al archivo de parámetros
param_file="../src/models/parameter-files/starobinsky.in"

# Valores de alpha_star y q
alphas=(0.01 1 20 50 100)
qs=(5050)

for alpha in "${alphas[@]}"
do
    for q in "${qs[@]}"
    do
        # 1. Definimos la carpeta exacta
        output_folder="./data/var_alpha/alpha_${alpha}/"

        echo "=============================================="
        echo "Ejecutando para alpha_star = $alpha, q = $q"
        echo "Configurando output en: $output_folder"
        echo "=============================================="

        # 2. Creamos el directorio (mkdir -p crea toda la ruta si no existe)
        mkdir -p "$output_folder"

        # 3. Modificamos el archivo .in
        sed -i "s|^outputfile *= *.*|outputfile = $output_folder|" "$param_file"

        # Modificamos alpha_star (¡Acá estaba el error!)
        sed -i "s/^alpha_star *= *.*/alpha_star = $alpha/" "$param_file"

        # Modificamos q
        sed -i "s/^q *= *.*/q = $q/" "$param_file"

        # 4. Ejecutamos CosmoLattice
        ./starobinsky input="$param_file"

        echo "✔️ Terminado."
        echo ""
    done
done
