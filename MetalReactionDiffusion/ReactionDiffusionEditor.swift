//
//  ReactionDiffusionEditor.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class ReactionDiffusionEditor: UIControl
{
    var parameterWidgets = [ParameterWidget]()
    let toolbar = UIToolbar(frame: CGRectZero)
    let menuButton = UIButton(frame: CGRectZero)
    let label = UILabel(frame: CGRectZero)
    var requestedReactionDiffusionModel : ReactionDiffusionModels?

    override func didMoveToSuperview()
    {
        let resetSimulationButton = UIBarButtonItem(title: "Reset Sim", style: UIBarButtonItem.Style.plain, target: self, action: Selector(("resetSimulation")))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let resetParametersButton = UIBarButtonItem(title: "Reset Params", style: UIBarButtonItem.Style.plain, target: self, action: Selector(("resetParameters")))
        
        toolbar.items = [resetSimulationButton, spacer, resetParametersButton]
        
        toolbar.barStyle = UIBarStyle.blackTranslucent
        
        addSubview(toolbar)
        
        menuButton.layer.borderColor = UIColor.lightGray.cgColor
        menuButton.layer.borderWidth = 1
        menuButton.layer.cornerRadius = 5
        
        menuButton.showsTouchWhenHighlighted = true
        menuButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        menuButton.setImage(UIImage(named: "hamburger.png"), for: UIControl.State.normal)

        menuButton.addTarget(self, action: Selector(("displayCallout")), for: UIControl.Event.touchDown)
        
        addSubview(menuButton)
        
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.white
        
        addSubview(label)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: -1, height: 2)
        layer.shadowOpacity = 1
    }
    
    var reactionDiffusionModel: ReactionDiffusion!
    {
        didSet
        {
            if oldValue == nil || oldValue.model.rawValue != reactionDiffusionModel.model.rawValue
            {
                //createUserInterface()
            }
            createUserInterface()
        }
    }

    func displayCallout()
    {
        // work in progress! Refactor to create once, draw list of possible models from seperate class....
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let grayScottAction = UIAlertAction(title: ReactionDiffusionModels.GrayScott.rawValue, style: UIAlertAction.Style.default, handler: reactionDiffusionModelChangeHandler)
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: saveActionHandler)
        let loadAction = UIAlertAction(title: "Browse and Load", style: UIAlertAction.Style.default, handler: loadActionHandler)
        let aboutAction = UIAlertAction(title: "About", style: UIAlertAction.Style.default, handler: aboutActionHandler)
        
        alertController.addAction(grayScottAction)
        
        alertController.addAction(saveAction)
        alertController.addAction(loadAction)
        alertController.addAction(aboutAction)
        
        if let viewController = UIApplication.shared.keyWindow!.rootViewController
        {
            if let popoverPresentationController = alertController.popoverPresentationController
            {
                let xx = menuButton.frame.origin.x + frame.origin.x
                let yy = menuButton.frame.origin.y + frame.origin.y
                
                popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.right
                
                popoverPresentationController.sourceRect = CGRect(x: xx, y: yy, width: menuButton.frame.width, height: menuButton.frame.height)
                popoverPresentationController.sourceView = viewController.view

                viewController.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func reactionDiffusionModelChangeHandler(value: UIAlertAction!) -> Void
    {
        requestedReactionDiffusionModel = ReactionDiffusionModels(rawValue: value.title ?? "No title present")
        
        sendActions(for: UIControl.Event.ModelChanged)
    }
    
    func saveActionHandler(value: UIAlertAction!) -> Void
    {
        sendActions(for: UIControl.Event.SaveModel)
    }
    
    func loadActionHandler(value: UIAlertAction!) -> Void
    {
        sendActions(for: UIControl.Event.LoadModel)
    }
    
    func aboutActionHandler(value: UIAlertAction!) -> Void
    {
        let alertController = UIAlertController(title: "ReDiLab v1.0\nReaction Diffusion Laboratory", message: "\nSimon Gladman | November 2014", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let openBlogAction = UIAlertAction(title: "Open Blog", style: .default, handler: visitFlexMonkey)
        
        alertController.addAction(okAction)
        alertController.addAction(openBlogAction)
        
        if let viewController = UIApplication.shared.keyWindow!.rootViewController
        {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func visitFlexMonkey(value: UIAlertAction!)
    {
        UIApplication.shared.openURL(URL(string: "http://flexmonkey.blogspot.co.uk")! as URL)
    }

    
    func resetSimulation()
    {
        sendActions(for: UIControl.Event.ResetSimulation)
    }
    
    func resetParameters()
    {
        reactionDiffusionModel.resetParameters()
        
        for widget in parameterWidgets
        {
            widget.value = reactionDiffusionModel.getValueForFieldName(fieldName: widget.reactionDiffusionFieldName!)
        }
        
        sendActions(for: UIControl.Event.valueChanged)
    }
    
    func createUserInterface()
    {
        label.text = reactionDiffusionModel.model.rawValue
        
        for widget in parameterWidgets
        {
            var varWidget: ParameterWidget? = widget
            
            varWidget!.removeFromSuperview()
            varWidget = nil
        }
        
        parameterWidgets = [ParameterWidget]()
        
        for fieldName in reactionDiffusionModel.fieldNames
        {
            let widget = ParameterWidget(frame: CGRectZero)
            
            parameterWidgets.append(widget)
            
            widget.minimumValue = reactionDiffusionModel.getMinMaxForFieldName(fieldName: fieldName).min
            widget.maximumValue = reactionDiffusionModel.getMinMaxForFieldName(fieldName: fieldName).max
      
            widget.value = reactionDiffusionModel.getValueForFieldName(fieldName: fieldName)
            widget.reactionDiffusionFieldName = fieldName
            
            widget.addTarget(self, action: Selector(("widgetChangeHandler:")), for: UIControl.Event.valueChanged)
            widget.addTarget(self, action: Selector(("resetSimulation")), for: UIControl.Event.ResetSimulation)
 
            addSubview(widget)
        }
        
        setNeedsLayout()
    }

    func widgetChangeHandler(widget: ParameterWidget)
    {
        if let fieldName = widget.reactionDiffusionFieldName
        {
            reactionDiffusionModel.setValueForFieldName(fieldName: fieldName, value: widget.value)
            
            sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    override func layoutSubviews()
    {
        layer.backgroundColor = UIColor.darkGray.cgColor

        toolbar.frame = CGRect(x: 0, y: frame.height - 40, width: frame.width, height: 40)
        
        for (idx: Int, widget: ParameterWidget) in parameterWidgets.enumerated()
        {
            widget.frame = CGRect(x: 10, y: 60 + idx * 80, width: Int(frame.width - 20), height: 55)
        }
        
        menuButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        
        label.frame = CGRect(x: 40, y: 10, width: frame.width - 40 - 10, height: 30)
    }

}

extension UIControl.Event
{
    static let ResetSimulation: UIControl.Event = UIControl.Event(rawValue: 0x01000000)
    static let ModelChanged: UIControl.Event = UIControl.Event(rawValue: 0x02000000)
    static let SaveModel: UIControl.Event = UIControl.Event(rawValue: 0x04000000)
    static let LoadModel: UIControl.Event = UIControl.Event(rawValue: 0x08000000)
}
