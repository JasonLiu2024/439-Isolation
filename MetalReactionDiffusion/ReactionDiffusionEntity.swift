//
//  ReactionDiffusionEntity.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 31/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ReactionDiffusionEntity: NSManagedObject {

    @NSManaged var model: String

    @NSManaged var f: NSNumber
    @NSManaged var k: NSNumber
    @NSManaged var du: NSNumber
    @NSManaged var dv: NSNumber
    @NSManaged var imageData: NSData
    @NSManaged var autoSaved: NSNumber
    
    var pendingDelete: Bool = false
    
    class func createInstanceFromEntity(entity: ReactionDiffusionEntity) -> ReactionDiffusion!
    {
        var returnObject: ReactionDiffusion!
        
        var model: ReactionDiffusionModels = ReactionDiffusionModels(rawValue: entity.model)!
        
        switch model
        {
            case .GrayScott:
                returnObject = GrayScott()
        }
        
        // populate numeric params...
        returnObject.reactionDiffusionStruct.F = Float(truncating: entity.f)
        returnObject.reactionDiffusionStruct.K = Float(truncating: entity.k)
        returnObject.reactionDiffusionStruct.Du = Float(truncating: entity.du)
        returnObject.reactionDiffusionStruct.Dv = Float(truncating: entity.dv)
        
        return returnObject
    }
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, model: String, reactionDiffusionStruct: ReactionDiffusionParameters, image: UIImage, autoSaved: Bool = false) -> ReactionDiffusionEntity
    {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "ReactionDiffusionEntity", into: moc) as! ReactionDiffusionEntity
        
        newItem.model = model
        
        newItem.imageData = image.resizeToBoundingSquare().jpegData(compressionQuality: 100)! as NSData
 
        newItem.f = reactionDiffusionStruct.F as NSNumber
        newItem.k = reactionDiffusionStruct.K as NSNumber
        newItem.du = reactionDiffusionStruct.Du as NSNumber
        newItem.dv = reactionDiffusionStruct.Dv as NSNumber
        newItem.autoSaved = autoSaved as NSNumber
        
        return newItem
    }
}
