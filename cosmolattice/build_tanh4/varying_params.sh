#!/bin/bash

# Ruta al archivo de parámetros de tanh4
param_file="../src/models/parameter-files/tanh4.in"

# Listas de valores para M y Lambda4
Ms=(2.435e19 4.330e18 7.700e18)
Lambdas4=(1.7966e63 1.7966e65 1.7966e64)

# Valor de q fijo (según tu preferencia de q = 4e4)
q_fixed="64.64" # 4e4

for M in "${Ms[@]}"
do
    for L4 in "${Lambdas4[@]}"
    do
        # 1. Definimos la carpeta de salida basada en ambos parámetros
        output_folder="./data/tanh4/var_params/M_${M}_L4_${L4}/"

        echo "=============================================="
        echo "Ejecutando tanh4 para:"
        echo "M = $M"
        echo "Lambda4 = $L4"
        echo "q = $q_fixed"
        echo "Configurando output en: $output_folder"
        echo "=============================================="

        # 2. Creamos el directorio
        mkdir -p "$output_folder"

        # 3. Modificamos el archivo .in usando sed
        # Cambiamos el outputfile
        sed -i "s|^outputfile *= *.*|outputfile = $output_folder|" "$param_file"

        # Modificamos M
        sed -i "s/^M *= *.*/M = $M/" "$param_file"

        # Modificamos Lambda4
        sed -i "s/^Lambda4 *= *.*/Lambda4 = $L4/" "$param_file"

        # Nos aseguramos de que q sea el correcto
        sed -i "s/^q *= *.*/q = $q_fixed/" "$param_file"

        # 4. Ejecutamos CosmoLattice
        # Asegurate de que el ejecutable se llame tanh4 y esté en esta ruta
        ./tanh4 input="$param_file"

        echo "✔️ Simulación para M=$M y L4=$L4 terminada."
        echo ""
    done
done
