//
//  GrayScottModel.swift
//  MetalReactionDiffusion
//
//  Created by Xiaoyi Liu on 2/22/24.
//  Copyright © 2024 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit



class GrayScottModel{
    let name = "Gray-Scott Model" // displayed
    let shader = "grayScottShader" // name of Shader kernel function
    let defaultImage = UIImage(named: "grayScottNoisySquare.jpg")! // image to start the reaction
    var parameters : [String: Float] = [
        "F": 0.049,
        "K": 0.070117,
        "Du": 0.172852,
        "Dv": 0.058594,
    ] // 'Worms' preset
    let iterationsPerFrame = 20 // time step
}
