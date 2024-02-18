//
//  ReactionDiffusion.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit

class GrayScott: ReactionDiffusionBase, ReactionDiffusion
{
    let model = ReactionDiffusionModels.GrayScott
    
    let shaderName = "grayScottShader"
    
    let initalImage = UIImage(named: "grayScottNoisySquare.jpg")!
    
    let fieldNames = [ReactionDiffusionFieldNames.F, ReactionDiffusionFieldNames.K, ReactionDiffusionFieldNames.Du, ReactionDiffusionFieldNames.Dv]
    
    let iterationsPerFrame = 20
}
