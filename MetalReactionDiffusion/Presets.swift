//
//  Presets.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 16/11/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation


class Worms: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.049023
        reactionDiffusionStruct.K = 0.070117
        reactionDiffusionStruct.Du = 0.172852
        reactionDiffusionStruct.Dv = 0.058594
    }
}

class Spots: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.033945
        reactionDiffusionStruct.K = 0.067461
        reactionDiffusionStruct.Du = 0.144531
        reactionDiffusionStruct.Dv = 0.046387
    }
}

class SpottyBifurcation: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.023867
        reactionDiffusionStruct.K = 0.0725
        reactionDiffusionStruct.Du = 0.194824
        reactionDiffusionStruct.Dv = 0.010254
    }
}

class Strings: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.050391
        reactionDiffusionStruct.K = 0.070508
        reactionDiffusionStruct.Du = 0.182129
        reactionDiffusionStruct.Dv = 0.062012
    }
}

class Bifurcation: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.023867
        reactionDiffusionStruct.K = 0.0725
        reactionDiffusionStruct.Du = 0.194824
        reactionDiffusionStruct.Dv = 0.010254
    }
}
