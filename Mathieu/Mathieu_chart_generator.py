import os
import numpy as np
from tqdm import tqdm 
import matplotlib as mpl
import matplotlib.pyplot as plt
from scipy.integrate import quad
from scipy.signal import find_peaks
from scipy.optimize import curve_fit
from scipy.integrate import solve_ivp

mpl.rc('figure', figsize=(12, 6))
mpl.rc('text', usetex = False)
mpl.rc('font', family = 'serif')
mpl.rc('font', size = '14')
mpl.rc('xtick', labelsize=14) 
mpl.rc('ytick', labelsize=14)
mpl.rcParams['mathtext.fontset'] = 'stix'

np.random.seed(42)

# Función para armarse la matriz de monodromía y calcular los coeficientes de Floquet
def mu_m2phi2(k, g, y0, Tosc):
    phi0, phi_dot0 = y0

    def pert(t, y, k, q):
        phi, phi_dot, chi_k, chi_dot_k = y
        phi_ddot = - phi
        chi_ddot_k = - (k**2 + q * phi**2) * chi_k
        return [phi_dot, phi_ddot, chi_dot_k, chi_ddot_k]

    t_span = (0, Tosc)

    sol1 = solve_ivp(pert, t_span, [phi0, phi_dot0, 1.0, 0.0], t_eval=[Tosc], method='RK45', rtol=1e-6, args=(k, g))
    y_final1 = sol1.y[:, -1]

    sol2 = solve_ivp(pert, t_span, [phi0, phi_dot0, 0.0, 1.0], t_eval=[Tosc], method='RK45', rtol=1e-6, args=(k, g))
    y_final2 = sol2.y[:, -1]

    M = np.array([
        [y_final1[2], y_final2[2]],
        [y_final1[3], y_final2[3]]
    ])

    tr_M = np.trace(M)
    argument = np.abs(tr_M / 2.0)

    if argument > 1.0:
        mu = np.arccosh(argument) / Tosc
        return mu
    else:
        return 0.0
    
# Función para calcular el período de oscilación del inflatón
def oscilation_m2phi2(E):
    def integrand(phi):
        V = 0.5 * phi**2
        return 1.0 / np.sqrt(2 * (E - V))
    phimax = np.sqrt(2*E)
    integral, _ = quad(integrand, 0, phimax, args=())
    Tosc = 4*integral
    return Tosc

# Guardar los resultados en una matriz con Ak en las filas, q en las columnas y mu en las celdas
def save_csv(qs, Aks, mu, filename='results'):
    output = np.zeros((len(Aks)+1, len(qs)+1))
    output[0, 1:] = qs
    output[1:, 0] = Aks
    output[1:, 1:] = np.real(mu)
    np.savetxt(f"{filename}.csv", output, delimiter=",")


# Verifico si el archivo de inestabilidades existe, sino lo armo
filename = "mathieu_m2phi2(kq).csv"
overwrite = input("¿Desea sobrescribir el archivo de inestabilidades? (s/n): ").lower()
if overwrite == "s":
    overwrite = True
else:
    overwrite = False

if not os.path.exists(filename) or overwrite == True:
    phi0 = 1
    phi_dot0 = 0
    y0 = (phi0, phi_dot0)
    E = 0.5 * phi_dot0**2 + 0.5 * phi0**2

    qs = np.linspace(0, 25, 300)
    ks = np.linspace(0, 2, 300)

    Q, K = np.meshgrid(ks, qs)
    mu = np.zeros((len(ks), len(qs)), dtype=complex)
    Tosc = oscilation_m2phi2(E)

    for i, q in enumerate(tqdm(qs)):
        for j, k in enumerate(ks):
            mu[j, i] = mu_m2phi2(k, q, y0, Tosc)

    # Guardemos los resultados en un archivo CSV
    save_csv(ks, qs, mu, filename='mathieu_m2phi2(kq)')
    
else:
    data = np.loadtxt(filename, delimiter=",")
    qs = data[0, 1:]
    ks = data[1:, 0]
    mu = data[1:, 1:]

guardar = input("¿Desea guardar la figura? (s/n): ").lower()

plt.figure(figsize=(10, 6))
contour = plt.contourf(ks, qs, np.real(mu), levels=100, cmap='inferno')
cbar = plt.colorbar(contour)
cbar.set_label(r'$\Re(\mu_k)$', fontsize=18, labelpad=25, rotation=0)
cbar.ax.tick_params(labelsize=18)
plt.xlabel(r'$q$', fontsize=20)
plt.ylabel(r'$\kappa$', fontsize=20, labelpad=20, rotation=0)
plt.xticks(fontsize=18)
plt.yticks(fontsize=18)
plt.grid(alpha = 0.1)
plt.tight_layout()

if guardar == "s":
    plt.savefig("Floquet_m2phi2.pdf", format = "pdf")
else:
    plt.show()
