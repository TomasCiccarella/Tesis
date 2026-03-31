#ifndef STAROBINSKY2_H
#define STAROBINSKY2_H

#include "CosmoInterface/cosmointerface.h"

namespace TempLat
{
    struct ModelPars : public TempLat::DefaultModelPars {
        static constexpr size_t NScalars = 2;
        static constexpr size_t NPotTerms = 2;
    };

    #define MODELNAME starobinsky2

    template<class R>
    using Model = MakeModel(R, ModelPars);

    class MODELNAME : public Model<MODELNAME>
    {
    private:
        // Variables físicas del modelo
        double q, g, M, mu, phii;

    public:
        MODELNAME(ParameterParser& parser, RunParameters<double>& runPar, std::shared_ptr<MemoryToolBox> toolBox): 
        Model<MODELNAME>(parser,runPar.getLatParams(), toolBox, runPar.dt, STRINGIFY(MODELLABEL))
        {
            /////////
            // Independent parameters of the model
            /////////
            q = parser.get<double>("q");
            M = parser.get<double>("M");
            mu = parser.get<double>("mu");
            g = sqrt(q)*M;
            
            /////////
            // Initial homogeneous components of the fields (Input in physical units)
            /////////
            fldS0 = parser.get<double, 2>("initial_amplitudes");
            piS0 = parser.get<double, 2>("initial_momenta", {0, 0});

            /////////
            // Rescaling for program variables
            /////////
            phii = fldS0[0];
            alpha = 1.0; 
            fStar = phii;
            omegaStar = M;

            setInitialPotentialAndMassesFromPotential();
        }

        /////////
        // Program potential
        /////////
        auto potentialTerms(Tag<0>) // Inflaton potential energy
        {
            return 0.5 * pow<2>(mu/phii) * pow<2>(1.0 - exp(-fldS(0_c) * phii/mu));
        }

        auto potentialTerms(Tag<1>) // Interaction energy
        {
            return 0.5 * q * pow<2>(fldS(0_c)) * pow<2>(fldS(1_c));
        }
   
        /////////
        // Derivatives of the program potential with respect fields
        /////////
        auto potDeriv(Tag<0>) // Derivative with respect to the inflaton
        {
            return (mu/phii) * (exp(-1*fldS(0_c)*phii/mu) - exp(-2*fldS(0_c)*phii/mu)) + q* fldS(0_c) * pow<2>(fldS(1_c));
        }

        auto potDeriv(Tag<1>)  // Derivative with respect to the daughter field
        {
            return q * fldS(1_c) * pow<2>(fldS(0_c));
        }
   
        /////////
        // Second derivatives of the program potential with respect fields
        /////////
        auto potDeriv2(Tag<0>) // Second derivative with respect inflaton
        {
            return 2*exp(-2*fldS(0_c)*phii/mu) - exp(-1*fldS(0_c)*phii/mu) + q * pow<2>(fldS(1_c));
        }

        auto potDeriv2(Tag<1>) // Second derivative with respect daughter field
        {
            return q * pow<2>(fldS(0_c));
        }
    };
}

#endif //STAROBINSKY2_H
