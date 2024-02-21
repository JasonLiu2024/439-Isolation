//
//  ParameterWidget.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class ParameterWidget: UIControl, UIPopoverControllerDelegate
{
    let label = UILabel(frame: CGRectZero)
    let slider = UISlider(frame: CGRectZero)

    let parameterWidgetViewController: ParameterWidgetViewController
    let popoverController: UIPopoverController
    
    override init(frame: CGRect)
    {
        parameterWidgetViewController = ParameterWidgetViewController()
        popoverController =  UIPopoverController(contentViewController: parameterWidgetViewController)
        
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview()
    {

        label.textColor = UIColor.white
        layer.backgroundColor = UIColor.darkGray.cgColor
        
        layer.cornerRadius = 5
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        
        addSubview(label)
        addSubview(slider)
        
        slider.addTarget(self, action: Selector(("sliderChangeHandler")), for: UIControl.Event.valueChanged)
        parameterWidgetViewController.slider.addTarget(self, action: Selector(("bigSliderChangeHandler")), for: UIControl.Event.valueChanged)
        parameterWidgetViewController.slider.addTarget(self, action: Selector(("bigSliderTouchUpInsideHandler")), for: UIControl.Event.touchUpInside)

        let longPress = UILongPressGestureRecognizer(target: self, action: Selector(("longHoldHandler:")))
        longPress.minimumPressDuration = 0.75
        longPress.allowableMovement = 7.5
        addGestureRecognizer(longPress)
    }

    func longHoldHandler(recognizer: UILongPressGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizer.State.began
        {
            if let rootController = UIApplication.shared.keyWindow!.rootViewController
            {
                var popupSource = layer.frame
                popupSource.origin.x += superview!.frame.origin.x
                popupSource.origin.y += superview!.frame.origin.y
         
                popoverController.present(from: popupSource, in: rootController.view, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
            }
        }
    }
    
    func bigSliderTouchUpInsideHandler()
    {
        sendActions(for: UIControl.Event.ResetSimulation)
    }
    
    func bigSliderChangeHandler()
    {
        slider.value = parameterWidgetViewController.slider.value
        sliderChangeHandler()
    }
    
    func sliderChangeHandler()
    {
        value = slider.value
        
        popoulateLabel()
        
        sendActions(for: UIControl.Event.valueChanged)
    }
    
    func popoulateLabel()
    {
        if let fieldName = reactionDiffusionFieldName
        {
            label.text = fieldName.rawValue + " = " + (NSString(format: "%.6f", value) as String)
        }
    }
    
    var reactionDiffusionFieldName: ReactionDiffusionFieldNames?
    {
        didSet
        {
            popoulateLabel();
        }
    }
    
    var value: Float = 0
    {
        didSet
        {
            slider.value = value
            parameterWidgetViewController.slider.value = value
            popoulateLabel()
        }
    }
    
    var minimumValue: Float = 0
    {
        didSet
        {
            parameterWidgetViewController.slider.minimumValue = minimumValue
            slider.minimumValue = minimumValue
        }
    }
    
    var maximumValue: Float = 1
    {
        didSet
        {
            parameterWidgetViewController.slider.maximumValue = maximumValue
            slider.maximumValue = maximumValue
        }
    }
    
    override func layoutSubviews()
    {
        label.frame = CGRect(x: 5, y: -3, width: frame.width, height: frame.height / 2)
        slider.frame = CGRect(x: 0, y: frame.height - 30, width: frame.width, height: frame.height / 2)
    }
    
}
