#!/bin/bash

# Ruta al archivo de parámetros
param_file="../src/models/parameter-files/starobinsky.in"

# Valores de gamma y kappa a testear
gammas=(1e-5 1e-4 1e-3)
kappas=(0.1 0.5 1.0)

# Fijamos el régimen de resonancia u otras constantes
q_eff=100

for gamma in "${gammas[@]}"
do
    for kappa in "${kappas[@]}"
    do
        # 1. Calculamos q (Revisar si esta relación sigue siendo válida para tu modelo)
        q=$(awk -v g="$gamma" -v k="$kappa" -v qe="$q_eff" 'BEGIN {print g * k * qe}')
        
        # 2. Calculamos la amplitud inicial (phi0)
        phi0=$(awk -v g="$gamma" 'BEGIN {
            term = sqrt(2.0 / (3.0 * g));
            print sqrt(1.5 * g) * log(term + 1.0)
        }')

        # 3. Calculamos el momento inicial (pi0)
        pi0=$(awk -v g="$gamma" -v k="$kappa" 'BEGIN {
            term = sqrt(2.0 / (3.0 * g));
            print sqrt(2.0 * k) * (1.0 - 1.0 / (term + 1.0))
        }')

        # Creamos una carpeta de salida única
        output_folder="./data/var_params/gamma_${gamma}_kappa_${kappa}/"
        
        echo "=============================================="
        echo "Ejecutando para gamma = $gamma | kappa = $kappa"
        echo "q ajustado = $q"
        echo "Amplitud inicial = $phi0"
        echo "Momento inicial = $pi0"
        echo "=============================================="

        mkdir -p "$output_folder"

        # 4. Ejecutamos CosmoLattice pasando todos los parámetros
        ./starobinsky input="$param_file" outputfile="$output_folder" gamma="$gamma" kappa="$kappa" q="$q" initial_amplitudes="$phi0 0" initial_momenta="$pi0 0"

        echo "✔️ Terminado."
        echo ""
    done
done
