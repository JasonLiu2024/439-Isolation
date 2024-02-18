//
//  ReactionDiffusionProtocol.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit

protocol ReactionDiffusion
{
    var model: ReactionDiffusionModels { get }
    var fieldNames: [ReactionDiffusionFieldNames] { get }
    var shaderName: String { get }
    var iterationsPerFrame: Int { get }
    
    var initalImage: UIImage { get }
    
    var reactionDiffusionStruct: ReactionDiffusionParameters { get set }
    
    func getValueForFieldName(fieldName: ReactionDiffusionFieldNames) -> Float
    func setValueForFieldName(fieldName: ReactionDiffusionFieldNames, value: Float)
    func getMinMaxForFieldName(fieldName: ReactionDiffusionFieldNames) -> (min: Float, max: Float)
    
    func resetParameters()
}

class ReactionDiffusionBase
{
    var reactionDiffusionStruct = ReactionDiffusionParameters()
    
    func resetParameters()
    {
        reactionDiffusionStruct = ReactionDiffusionParameters()
    }
    
    func getValueForFieldName(fieldName: ReactionDiffusionFieldNames) -> Float
    {
        var returnValue: Float = 0.0
        
        switch(fieldName)
        {
        case .F:
            returnValue = reactionDiffusionStruct.F
        case .K:
            returnValue = reactionDiffusionStruct.K
        case .Du:
            returnValue = reactionDiffusionStruct.Du
        case .Dv:
            returnValue = reactionDiffusionStruct.Dv
        }
        
        return returnValue
    }
    
    func setValueForFieldName(fieldName: ReactionDiffusionFieldNames, value: Float)
    {
        switch(fieldName)
        {
            case .F:
                reactionDiffusionStruct.F = value
            case .K:
                reactionDiffusionStruct.K = value
            case .Du:
                reactionDiffusionStruct.Du = value
            case .Dv:
                reactionDiffusionStruct.Dv = value
        }
    }
    
    
    func getMinMaxForFieldName(fieldName: ReactionDiffusionFieldNames) -> (min: Float, max: Float)
    {
        var returnValue: (min: Float, max: Float) = (min: 0.0, max: 0.0)
        
        switch(fieldName)
        {
        case .F, .K:
            returnValue = (min: 0.02, max: 0.08)
        case .Du, .Dv:
            returnValue = (min: 0.0, max: 0.25)
        }
        
        return returnValue
    }
}

enum ReactionDiffusionModels: String
{
    case GrayScott = "Gray-Scott"
}

enum ReactionDiffusionFieldNames: String
{
    // Gray Scott
    
    case F = "F"
    case K = "K"
    case Du = "Du"
    case Dv = "Dv"
}

struct ReactionDiffusionParameters
{
    // Gray Scott
    
    var F: Float = 0.057031
    var K: Float = 0.063672
    var Du: Float = 0.155762
    var Dv: Float = 0.0644
}
