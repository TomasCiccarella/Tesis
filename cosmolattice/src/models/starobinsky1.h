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
        double g, q, kappa;
        double MPl_phys = 1.22e19;

    public:
        MODELNAME(ParameterParser& parser, RunParameters<double>& runPar, std::shared_ptr<MemoryToolBox> toolBox): 
        Model<MODELNAME>(parser,runPar.getLatParams(), toolBox, runPar.dt, STRINGIFY(MODELLABEL))
        {
            g = parser.get<double>("g");
            kappa = parser.get<double>("kappa");
            q = pow<2>(g/kappa);
            
            fldS0 = parser.get<double, 2>("initial_amplitudes");
            piS0 = parser.get<double, 2>("initial_momenta", {0, 0});
            
            /////////
            // Rescaling for program variables
            /////////
            alpha = 1.0; 
            fStar = MPl_phys;
            omegaStar = kappa * fStar;
            
            setInitialPotentialAndMassesFromPotential();
        }

        /////////
        // Program potential
        /////////
        auto potentialTerms(Tag<0>) 
        {
            double k = sqrt(2.0 / 3.0);
            auto exp_term = exp(-k * fldS(0_c));
            return 0.75 * pow<2>(1.0 - exp_term);
        }

        auto potentialTerms(Tag<1>) 
        {
            return 0.5 * q * pow<2>(fldS(0_c)) * pow<2>(fldS(1_c));
        }
   
        /////////
        // Derivatives of the program potential
        /////////
        auto potDeriv(Tag<0>) 
        {
            double k = sqrt(2.0 / 3.0);
            auto exp1 = exp(-k * fldS(0_c));
            auto exp2 = exp(-2.0 * k * fldS(0_c));
            
            return 1.5 * k * (exp1 - exp2) + q * fldS(0_c) * pow<2>(fldS(1_c));
        }

        auto potDeriv(Tag<1>)  
        {
            return q * fldS(1_c) * pow<2>(fldS(0_c));
        }
   
        /////////
        // Second derivatives of the program potential
        /////////
        auto potDeriv2(Tag<0>) 
        {
            double k = sqrt(2.0 / 3.0);
            auto exp1 = exp(-k * fldS(0_c));
            auto exp2 = exp(-2.0 * k * fldS(0_c));
            
            return 2.0 * exp2 - exp1 + q * pow<2>(fldS(1_c));
        }

        auto potDeriv2(Tag<1>) 
        {
            return q * pow<2>(fldS(0_c));
        }
    };
}

#endif //STAROBINSKY1_H
