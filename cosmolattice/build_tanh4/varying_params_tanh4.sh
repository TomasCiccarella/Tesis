#!/bin/bash

param_file="../src/models/parameter-files/tanh4.in"

# Parámetros
lambdas=(9e-14)
Lambdas4=(5.8e66 1e61 1e63 1e68 1e70 1e72) # (6.078e62) # 1.7966e58 1.7966e59 1.7966e60 1.7966e61 1.7966e62 1.7966e63 1.7966e64 1.7966e65 1.7966e66 1.7966e67 1.7966e68 1.7966e69 1.7966e70 1.7966e71 1.7966e72)
q_fixed="5050"

for lambda in "${lambdas[@]}"
do
    for L4 in "${Lambdas4[@]}"
    do
        # Calculamos M usando Python para no tener errores de precisión con bc
        # M = (L4 / lambda)^(1/4)
        M_final=$(python3 -c "print((${L4} / ${lambda})**0.25)")

        output_folder="./data/DEF/lambda_${lambda}/L4_${L4}/"
        mkdir -p "$output_folder"

        echo "----------------------------------------------"
        echo "Lanzando: lambda=$lambda | L4=$L4"
        echo "M calculado correctamente: $M_final"
        echo "----------------------------------------------"

        # Modificamos el .in asegurando que no queden valores vacíos
        sed -i "s|^outputfile *=.*|outputfile = $output_folder|" "$param_file"
        sed -i "s|^M *=.*|M = $M_final|" "$param_file"
        sed -i "s|^Lambda4 *=.*|Lambda4 = $L4|" "$param_file"
        sed -i "s|^q *=.*|q = $q_fixed|" "$param_file"

        # Ejecutamos
        ./tanh4 input="$param_file"
    done
done
