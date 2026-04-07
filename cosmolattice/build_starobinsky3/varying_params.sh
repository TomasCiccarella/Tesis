#!/bin/bash

# Ruta al archivo de parámetros de Starobinsky
param_file="../src/models/parameter-files/starobinsky3.in"

# 1. Valores de 'm' (para emular el modelo cuadrático)
ms=(1.0e13 1.46e13 2.0e13)

# 2. Valores de M (ancho de la meseta de Starobinsky)
Ms=(1.0e19 2.435e19 5.0e19)

# 3. q ajustado para consistencia (el valor calculado para g equivalente)
q_fixed=616

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
