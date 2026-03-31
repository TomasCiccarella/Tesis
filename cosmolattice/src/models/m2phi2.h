#ifndef M2PHI2_H
#define M2PHI2_H

#include "CosmoInterface/cosmointerface.h"

namespace TempLat
{
    struct ModelPars : public TempLat::DefaultModelPars {
        static constexpr size_t NScalars = 2;
        static constexpr size_t NPotTerms = 2;
    };

    #define MODELNAME m2phi2
  
    template<class R>
    using Model = MakeModel(R, ModelPars);
  
    class MODELNAME : public Model<MODELNAME>
    {
    private:
        double g, m, q, phii;
        
    public:
        MODELNAME(ParameterParser& parser, RunParameters<double>& runPar, std::shared_ptr<MemoryToolBox> toolBox) : 
            Model<MODELNAME>(parser, runPar.getLatParams(), toolBox, runPar.dt, STRINGIFY(MODELLABEL))
        {

            // Condiciones iniciales
            fldS0 = parser.get<double, 2>("initial_amplitudes");
            piS0 = parser.get<double, 2>("initial_momenta", {0, 0});
            phii = fldS0[0];
            
            // Parámetros del modelo
            m = parser.get<double>("m");
            q = parser.get<double>("q");
            g = sqrt(q) * m / phii;
            
            // Rescaling para variables del programa
            alpha = 1;
            fStar = phii;
            omegaStar = m;

            setInitialPotentialAndMassesFromPotential();
        }

        // Términos del potencial
        auto potentialTerms(Tag<0>) // Potencial del inflatón: ½m²φ²
        {
            return 0.5 * pow<2>(fldS(0_c));
        }
        
        auto potentialTerms(Tag<1>) // Término de interacción: ½g²φ²χ²
        {
            return 0.5 * q * pow<2>(fldS(0_c) * fldS(1_c));
        }

        // Derivadas del potencial
        auto potDeriv(Tag<0>) // Respecto al inflatón φ
        {
            return fldS(0_c) + q * fldS(0_c) * pow<2>(fldS(1_c));
        }

        auto potDeriv(Tag<1>) // Respecto al campo hijo χ
        {
            return q * fldS(1_c) * pow<2>(fldS(0_c));
        }

        // Derivadas segundas del potencial
        auto potDeriv2(Tag<0>) // Respecto a φ dos veces
        {
            return 1.0 + q * pow<2>(fldS(1_c));
        }

        auto potDeriv2(Tag<1>) // Respecto a χ dos veces
        {
            return q * pow<2>(fldS(0_c));
        }
    };
}

#endif // M2PHI2_H
