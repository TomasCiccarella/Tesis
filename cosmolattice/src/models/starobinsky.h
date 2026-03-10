#ifndef STAROBINSKY_H
#define STAROBINSKY_H

#include "CosmoInterface/cosmointerface.h"

namespace TempLat
{
    struct ModelPars : public TempLat::DefaultModelPars {
        static constexpr size_t NScalars = 2;
        static constexpr size_t NPotTerms = 2;
    };

    #define MODELNAME starobinsky

    template<class R>
    using Model = MakeModel(R, ModelPars);

    class MODELNAME : public Model<MODELNAME>
    {
    private:
        // Variables físicas del modelo
        double q, kappa, gamma;

    public:
        MODELNAME(ParameterParser& parser, RunParameters<double>& runPar, std::shared_ptr<MemoryToolBox> toolBox): 
        Model<MODELNAME>(parser,runPar.getLatParams(), toolBox, runPar.dt, STRINGIFY(MODELLABEL))
        {
            /////////
            // Independent parameters of the model
            /////////
            q = parser.get<double>("q");
            kappa = parser.get<double>("kappa");
            gamma = parser.get<double>("gamma");

            /////////
            // Initial homogeneous components of the fields
            /////////
            fldS0 = parser.get<double, 2>("initial_amplitudes");
            piS0 = parser.get<double, 2>("initial_momenta", {0, 0});
            
            /////////
            // Rescaling for program variables
            /////////
            alpha = 1.0; 
            fStar = fldS0[0];
            omegaStar = sqrt(kappa)*fStar;

            setInitialPotentialAndMassesFromPotential();
        }

        /////////
        // Program potential
        /////////
        auto potentialTerms(Tag<0>) // Inflaton potential energy
        {
            double k = sqrt(2.0 / (3.0 * gamma));
            auto exp_term = exp(-k * fldS(0_c));
            return kappa * pow<2>(1.0 - exp_term);
        }

        auto potentialTerms(Tag<1>) // Interaction energy
        {
            return 0.5 * (q / kappa) * pow<2>(fldS(0_c)) * pow<2>(fldS(1_c));
        }
   
        /////////
        // Derivatives of the program potential with respect fields
        /////////
        auto potDeriv(Tag<0>) // Derivative with respect to the inflaton
        {
            double k = sqrt(2.0 / (3.0 * gamma));
            auto exp1 = exp(-k * fldS(0_c));
            auto exp2 = exp(-2.0 * k * fldS(0_c));
            
            return 2.0 * kappa * k * (exp1 - exp2) + (q / kappa) * fldS(0_c) * pow<2>(fldS(1_c));
        }

        auto potDeriv(Tag<1>)  // Derivative with respect to the daughter field
        {
            return (q / kappa) * fldS(1_c) * pow<2>(fldS(0_c));
        }
   
        /////////
        // Second derivatives of the program potential with respect fields
        /////////
        auto potDeriv2(Tag<0>) // Second derivative with respect inflaton
        {
            double k = sqrt(2.0 / (3.0 * gamma));
            auto exp1 = exp(-k * fldS(0_c));
            auto exp2 = exp(-2.0 * k * fldS(0_c));
            
            return 2.0 * kappa * pow<2>(k) * (2.0 * exp2 - exp1) + (q / kappa) * pow<2>(fldS(1_c));
        }

        auto potDeriv2(Tag<1>) // Second derivative with respect daughter field
        {
            return (q / kappa) * pow<2>(fldS(0_c));
        }
    };
}

#endif //STAROBINSKY_H
