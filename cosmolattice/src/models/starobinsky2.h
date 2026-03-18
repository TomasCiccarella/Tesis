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
        double q, kappa;
        double MPl_phys = 1.22e19;

    public:
        MODELNAME(ParameterParser& parser, RunParameters<double>& runPar, std::shared_ptr<MemoryToolBox> toolBox): 
        Model<MODELNAME>(parser,runPar.getLatParams(), toolBox, runPar.dt, STRINGIFY(MODELLABEL))
        {
            /////////
            // Independent parameters of the model
            /////////
            q = parser.get<double>("q");
            kappa = parser.get<double>("kappa");

            /////////
            // Rescaling for program variables
            /////////
            alpha = 1.0; 
            fStar = fldS0[0];
            omegaStar = kappa * fStar;

            /////////
            // Initial homogeneous components of the fields (Input in physical units)
            /////////
            auto amp_GeV = parser.get<double, 2>("initial_amplitudes_GeV");
            auto mom_GeV2 = parser.get<double, 2>("initial_momenta_GeV2", {0.0, 0.0});

            // Adimensionalización interna
            fldS0 = {amp_GeV[0], amp_GeV[1]};
            piS0 = {mom_GeV2[0], mom_GeV2[1]};

            setInitialPotentialAndMassesFromPotential();
        }

        /////////
        // Program potential
        /////////
        auto potentialTerms(Tag<0>) // Inflaton potential energy
        {
            double k = sqrt(2.0 / 3.0);
            auto exp_term = exp(-k * fldS(0_c) * (fStar/MPl_phys));
            return 0.75 * pow<4>(MPl_phys/fStar) * pow<2>(kappa) * pow<2>(1.0 - exp_term);
        }

        auto potentialTerms(Tag<1>) // Interaction energy
        {
            return 0.5 * pow<2>(q / kappa) * pow<2>(fldS(0_c)) * pow<2>(fldS(1_c));
        }
   
        /////////
        // Derivatives of the program potential with respect fields
        /////////
        auto potDeriv(Tag<0>) // Derivative with respect to the inflaton
        {
            double k = sqrt(2.0 / 3.0);
            auto exp1 = exp(-k * fldS(0_c) * (fStar/MPl_phys));
            auto exp2 = exp(-2.0 * k * fldS(0_c) * (fStar/MPl_phys));
            
            return 1.5 * pow<4>(MPl_phys/fStar) * pow<2>(kappa) * k * (exp1 - exp2) + pow<2>(q / kappa) * fldS(0_c) * pow<2>(fldS(1_c));
        }

        auto potDeriv(Tag<1>)  // Derivative with respect to the daughter field
        {
            return pow<2>(q / kappa) * fldS(1_c) * pow<2>(fldS(0_c));
        }
   
        /////////
        // Second derivatives of the program potential with respect fields
        /////////
        auto potDeriv2(Tag<0>) // Second derivative with respect inflaton
        {
            double k = sqrt(2.0 / 3.0);
            auto exp1 = exp(-k * fldS(0_c) * (fStar/MPl_phys));
            auto exp2 = exp(-2.0 * k * fldS(0_c) * (fStar/MPl_phys));
            
            return 1.5 * pow<4>(MPl_phys/fStar) * pow<2>(kappa) * pow<2>(k) * (2.0 * exp2 - exp1) + pow<2>(q / kappa) * pow<2>(fldS(1_c));
        }

        auto potDeriv2(Tag<1>) // Second derivative with respect daughter field
        {
            return pow<2>(q / kappa) * pow<2>(fldS(0_c));
        }
    };
}

#endif //STAROBINSKY2_H
