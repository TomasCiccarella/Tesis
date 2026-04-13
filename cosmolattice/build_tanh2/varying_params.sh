#!/bin/bash

# Ruta al archivo de parámetros
param_file="../src/models/parameter-files/tanh2.in"

# 1. Valores de 'm' y 'M'
ms=(1.0e13 1.46e13 2.0e13)
Ms=(1.0e19 2.435e19 5.0e19)
q_fixed=5000

for m in "${ms[@]}"
do
    for M in "${Ms[@]}"
    do
        # Convertimos la notación 'e' a '*' para que bc la entienda
        # Ejemplo: 1.0e13 -> 1.0*10^13
        m_bc=$(echo $m | sed -e 's/[eE]/ * 10^/' -e 's/^+//')
        M_bc=$(echo $M | sed -e 's/[eE]/ * 10^/' -e 's/^+//')

        # Calculamos Lambda4: (m * M)^2
        L4=$(echo "scale=2; ($m_bc * $M_bc)^2" | bc -l)

        # Si bc devuelve algo como .123, le agregamos el 0 inicial
        if [[ $L4 == .* ]]; then L4="0$L4"; fi

        output_folder="./data/tanh2/m_${m}/M_${M}/"
        mkdir -p "$output_folder"

        echo "=============================================="
        echo "Configurando Tanh2 para m = $m, M = $M"
        echo "Lambda4 calculada = $L4"
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
