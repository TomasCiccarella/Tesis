#!/bin/bash

# Ruta al archivo de parámetros de Starobinsky
param_file="../src/models/parameter-files/starobinsky3.in"

ms=(2.435e13)
Ms=(2.435e20)
q_fixed=16000

for m in "${ms[@]}"
do
    for M in "${Ms[@]}"
    do
        # Convertimos notación científica para bc
        m_bc=$(echo $m | sed -e 's/[eE]/ * 10^/' -e 's/^+//')
        M_bc=$(echo $M | sed -e 's/[eE]/ * 10^/' -e 's/^+//')

        # Calculamos Lambda4: (m * M)^2 para que sqrt(Lambda4)/M = m
        L4=$(echo "scale=2; ($m_bc * $M_bc)^2" | bc -l)

        # Ajuste de formato para números menores a 1
        if [[ $L4 == .* ]]; then L4="0$L4"; fi

        output_folder="./data/starobinsky3/m_${m}/M_${M}/"
        mkdir -p "$output_folder"

        echo "=============================================="
        echo "Configurando Starobinsky3 para m = $m, M = $M"
        echo "Lambda4 calculada = $L4 | q = $q_fixed"
        echo "=============================================="

        # Modificamos el .in usando sed
        sed -i "s|^outputfile *= *.*|outputfile = $output_folder|" "$param_file"
        sed -i "s/^M *= *.*/M = $M/" "$param_file"
        sed -i "s/^Lambda4 *= *.*/Lambda4 = $L4/" "$param_file"
        sed -i "s/^q *= *.*/q = $q_fixed/" "$param_file"

        # Ejecutamos el binario correspondiente
        ./starobinsky3 input="$param_file"

        echo "✔️ Simulación de Starobinsky terminada."
        echo ""
    done
done
