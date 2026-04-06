#!/bin/bash

# Ruta al archivo de parámetros
param_file="../src/models/parameter-files/tanh2.in"

# 1. Definimos los valores de 'm' (frecuencia en el mínimo) que queremos emular
# Estos deberían ser los mismos que usaste en m2phi2
ms=(1.0e13 1.46e13 2.0e13)

# 2. Definimos valores de M para ver distintos anchos de la meseta
Ms=(1.0e19 2.435e19 5.0e19)

# 3. q fijo para que g sea equivalente (usando el q=687 que calculamos antes)
q_fixed=687

for m in "${ms[@]}"
do
    for M in "${Ms[@]}"
    do
        # Calculamos Lambda4: Lambda4 = (m * M)^2
        # Esto asegura que sqrt(Lambda4)/M = m siempre.
        L4=$(echo "scale=10; ($m * $M)^2" | bc -l)

        # Definimos carpeta: organizada por masa m y luego por el ancho M
        output_folder="./data/tanh2/m_${m}/M_${M}/"
        mkdir -p "$output_folder"

        echo "=============================================="
        echo "Configurando Tanh2 para emular m = $m"
        echo "Con escala M = $M -> Lambda4 calculada = $L4"
        echo "=============================================="

        # Modificamos el .in
        sed -i "s|^outputfile *= *.*|outputfile = $output_folder|" "$param_file"
        sed -i "s/^M *= *.*/M = $M/" "$param_file"
        sed -i "s/^Lambda4 *= *.*/Lambda4 = $L4/" "$param_file"
        sed -i "s/^q *= *.*/q = $q_fixed/" "$param_file"

        # Ejecutamos
        ./tanh2 input="$param_file"

        echo "✔️ Simulación terminada."
        echo ""
    done
done
