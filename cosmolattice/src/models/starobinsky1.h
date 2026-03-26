#ifndef STAROBINSKY1_H
#define STAROBINSKY1_H

#include "CosmoInterface/cosmointerface.h"

namespace TempLat
{
    struct ModelPars : public TempLat::DefaultModelPars {
        static constexpr size_t NScalars = 2;
        static constexpr size_t NPotTerms = 2;
    };

    #define MODELNAME starobinsky1

    template<class R>
    using Model = MakeModel(R, ModelPars);

    class MODELNAME : public Model<MODELNAME>
    {
    private:
        // Parámetros físicos del modelo
        double g, kappa, q;
        static constexpr double MPl_red = 2.435e18;

    public:
        MODELNAME(ParameterParser& parser, RunParameters<double>& runPar, std::shared_ptr<MemoryToolBox> toolBox): 
        Model<MODELNAME>(parser, runPar.getLatParams(), toolBox, runPar.dt, STRINGIFY(MODELLABEL))
        {
            // Leer parámetros del .in
            g     = parser.get<double>("g");
            kappa = parser.get<double>("kappa");

            // Parámetro de resonancia q = (g/kappa)^2
            q = pow<2>(g / kappa);

            // -----------------------------------------------------------
            // RESCALADO: todas las variables del programa son adimensionales
            //
            //   phi_prog  = phi_fis  / fStar
            //   pi_prog   = pi_fis   / (omegaStar * fStar)
            //   t_prog    = t_fis    * omegaStar
            //
            // Con fStar = MPl_red y omegaStar = kappa * MPl_red,
            // el potencial de Starobinsky en variables del programa queda:
            //
            //   V_prog = (3/4) * (1 - exp(-sqrt(2/3) * phi_prog))^2
            //          + (1/2) * q * phi_prog^2 * chi_prog^2
            //
            // -----------------------------------------------------------
            alpha      = 1.0;           // factor de escala inicial (a=1)
            fStar      = MPl_red;       // escala de campo [GeV]
            omegaStar  = kappa * fStar; // escala de frecuencia [GeV]

            // Condiciones iniciales YA EN UNIDADES DEL PROGRAMA
            fldS0 = parser.get<double, 2>("initial_amplitudes");
            piS0  = parser.get<double, 2>("initial_momenta", {0.0, 0.0});

            setInitialPotentialAndMassesFromPotential();
        }

        // ================================================================
        // POTENCIAL V = V0 + V1
        //
        //   V0 = (3/4) * (1 - exp(-k * phi))^2       [Starobinsky]
        //   V1 = (1/2) * q * phi^2 * chi^2            [interacción]
        //
        // con k = sqrt(2/3)
        // ================================================================

        auto potentialTerms(Tag<0>)
        {
            constexpr double k = 0.8164965809; // sqrt(2/3)
            auto ephi = exp(-k * fldS(0_c));
            return 0.75 * pow<2>(1.0 - ephi);
        }

        auto potentialTerms(Tag<1>)
        {
            return 0.5 * q * pow<2>(fldS(0_c)) * pow<2>(fldS(1_c));
        }

        // Derivada total de V respecto al campo inflaton phi (campo 0)
        auto potDeriv(Tag<0>)
        {
            constexpr double k = 0.8164965809;
            auto exp1 = exp(-k * fldS(0_c));
            auto exp2 = exp(-2.0 * k * fldS(0_c));
            return 1.5 * k * (exp1 - exp2) + q * fldS(0_c) * pow<2>(fldS(1_c));
        }

        // Derivada total de V respecto al campo hijo chi (campo 1)
        auto potDeriv(Tag<1>)
        {
            // Solo V1 depende de chi
            return q * fldS(1_c) * pow<2>(fldS(0_c));
        }

        // Segunda derivada total de V respecto a phi
        auto potDeriv2(Tag<0>)
        {
            constexpr double k = 0.8164965809;
            auto exp1 = exp(-k * fldS(0_c));
            auto exp2 = exp(-2.0 * k * fldS(0_c));
            // Contribución de V0: 2*e^{-2k*phi} - e^{-k*phi}
            // Contribución de V1: q * chi^2
            return (2.0 * exp2 - exp1) + q * pow<2>(fldS(1_c));
        }

        // Segunda derivada total de V respecto a chi
        auto potDeriv2(Tag<1>)
        {
            // Solo V1 depende de chi
            return q * pow<2>(fldS(0_c));
        }
    };
}

#endif // STAROBINSKY1_H
