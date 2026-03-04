#!/bin/bash

# Ruta al archivo de parámetros
param_file="../src/models/parameter-files/starobinsky.in"

# Valores de alpha_star a testear
alphas=(1e-11 5e-11 1e-10 5e-10 1e-9)

# Fijamos el régimen de resonancia (q / alpha_star) para mantener la estabilidad
q_eff=100

for alpha in "${alphas[@]}"
do
    # 1. Calculamos el q proporcional para no romper el dt
    q=$(awk -v a="$alpha" -v qe="$q_eff" 'BEGIN {print a * qe}')

    # 2. Calculamos el momento inicial físico exacto para este alpha
    pi0=$(awk -v a="$alpha" 'BEGIN {print -sqrt(0.287 * a)}')

    output_folder="./data/var_alpha/alpha_${alpha}/"
    
    echo "=============================================="
    echo "Ejecutando para alpha_star = $alpha"
    echo "q ajustado = $q (Mantiene q_eff = $q_eff)"
    echo "Momento inicial = $pi0"
    echo "=============================================="

    mkdir -p "$output_folder"

    # 3. Sobrescribimos TODO desde la terminal
    ./starobinsky input="$param_file" outputfile="$output_folder" alpha_star="$alpha" q="$q" initial_momenta="$pi0 0"

    echo "✔️ Terminado."
    echo ""
done
