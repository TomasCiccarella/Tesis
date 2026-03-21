import numpy as np
import matplotlib.pyplot as plt

# 1. Rutas de los archivos
data_dir = "./data/prueba_recal/"
file_energies = data_dir + "average_energies.txt"
file_scale = data_dir + "average_scale_factor.txt"

try:
    # 2. Cargamos las energías (Densidades físicas)
    t_e, e_k, e_g, e_v = np.loadtxt(file_energies, usecols=(0, 1, 2, 3), unpack=True)
    rho_tot = e_k + e_g + e_v
    
    # 3. Cargamos el factor de escala 'a'
    # En average_scale_factor.txt: col 0 es tiempo, col 1 es 'a'
    t_a, a = np.loadtxt(file_scale, usecols=(0, 1), unpack=True)
    
    data_loaded = True
except FileNotFoundError as e:
    print(f"Error al cargar archivos: {e}")
    data_loaded = False

if data_loaded:
    plt.figure(figsize=(10, 6))
    plt.plot(t_e, e_v * (a**3), label=r'$V(\phi) \times a^3$', color='blue', alpha=0.7)
    plt.plot(t_e, e_k * (a**3), label=r'$K(\phi) \times a^3$', color='red', alpha=0.7)

    plt.yscale('log')
    plt.xlabel('Tiempo de programa (t)')
    plt.ylabel('Energía Comóvil')
    plt.title('Conservación de Energía en Universo en Expansión')
    plt.legend()
    plt.grid(True, which="both", ls="--", alpha=0.5)

    plt.tight_layout()
    plt.show()