//
//  BrowseAndLoadController.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 01/11/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class BrowseAndLoadController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    var collectionViewWidget: UICollectionView!
    var selectedEntity: ReactionDiffusionEntity?
    let blurOverlay = UIVisualEffectView(effect: UIBlurEffect())
    let showDeletedSwitch = UISwitch(frame: CGRectZero)
    let showDeletedLabel = UILabel(frame: CGRectZero)
    
    var dataprovider: [ReactionDiffusionEntity] = [ReactionDiffusionEntity]()
    
    var fetchResults:[ReactionDiffusionEntity] = [ReactionDiffusionEntity]()
    {
        didSet
        {
            if let _collectionView = collectionViewWidget
            {
                populateDataProvider()
            }
        }
    }
    
    var showDeleted: Bool = false
    {
        didSet
        {
            populateDataProvider()
        }
    }
    
    func populateDataProvider()
    {
        func populateDataProvider_2(value: Bool)
        {
            if let _collectionView = collectionViewWidget
            {
                if showDeleted
                {
                    dataprovider = fetchResults
                }
                else
                {
                    dataprovider = fetchResults.filter({!$0.pendingDelete})
                }
                
                _collectionView.reloadData()
            }
            
            UIView.animate(withDuration: 0.125, animations: {self.collectionViewWidget.alpha = 1})
        }
        
        UIView.animate(withDuration: 0.125, animations: {self.collectionViewWidget.alpha = 0}, completion: populateDataProvider_2)
    }
    
    override func viewDidLoad()
    {
        selectedEntity = nil
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionViewWidget = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        collectionViewWidget.backgroundColor = UIColor.clear
        
        collectionViewWidget.delegate = self
        collectionViewWidget.dataSource = self
        collectionViewWidget.register(ReactionDiffusionEntityRenderer.self, forCellWithReuseIdentifier: "Cell")
        collectionViewWidget.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        showDeletedSwitch.tintColor = UIColor.darkGray
        showDeletedSwitch.addTarget(self, action: Selector(("showDeletedToggle")), for: UIControl.Event.valueChanged)
        showDeletedSwitch.setOn(showDeleted, animated: false)
        showDeletedLabel.text = "Show recently deleted"
        
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector(("longPressHandler:")))
        collectionViewWidget.addGestureRecognizer(longPress)
        
        view.addSubview(collectionViewWidget)
        view.addSubview(blurOverlay)
        view.addSubview(showDeletedSwitch)
        view.addSubview(showDeletedLabel)
    }
    
    var longPressTarget: (cell: UICollectionViewCell, indexPath: NSIndexPath)?
    
    func showDeletedToggle()
    {
        showDeleted = showDeletedSwitch.isOn
    }
    
    func longPressHandler(recognizer: UILongPressGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizer.State.began
        {
            if let _longPressTarget = longPressTarget
            {
                let entity = dataprovider[_longPressTarget.indexPath.item]
                
                let contextMenuController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                let deleteAction = UIAlertAction(title: entity.pendingDelete ? "Undelete" : "Delete", style: UIAlertAction.Style.default, handler: togglePendingDelete)
                
                contextMenuController.addAction(deleteAction)
                
                if let popoverPresentationController = contextMenuController.popoverPresentationController
                {
                    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.down
                    popoverPresentationController.sourceRect = _longPressTarget.cell.frame.rectByOffsetting(dx: collectionViewWidget.frame.origin.x, dy: collectionViewWidget.frame.origin.y - collectionViewWidget.contentOffset.y)
                    popoverPresentationController.sourceView = view
                    
                    present(contextMenuController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func togglePendingDelete(value: UIAlertAction!) -> Void
    {
        if let _longPressTarget = longPressTarget
        {
            let targetEntity = dataprovider[_longPressTarget.indexPath.item]
            
            targetEntity.pendingDelete = !targetEntity.pendingDelete
            
            if showDeleted
            {
                // if we're displaying peniding deletes....
                collectionViewWidget.reloadItems(at: [_longPressTarget.indexPath])
            }
            else
            {
                // if we're deleting
                if targetEntity.pendingDelete
                {
                    let targetEntityIndex = find(dataprovider, targetEntity)
                    dataprovider.remove(at: targetEntityIndex!)
                    collectionViewWidget.deleteItems(at: [_longPressTarget.indexPath])
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath)
    {
        longPressTarget = (cell: self.collectionView(collectionView: collectionViewWidget, cellForItemAtIndexPath: indexPath), indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return dataprovider.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        selectedEntity = dataprovider[indexPath.item]
 
        if let _popoverPresentationController = popoverPresentationController
        {
            if let _delegate = _popoverPresentationController.delegate
            {
               _delegate.popoverPresentationControllerDidDismissPopover!(_popoverPresentationController)
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ReactionDiffusionEntityRenderer
        
        cell.reactionDiffusionEntity = dataprovider[indexPath.item]
        
        return cell
    }
    
    override func viewDidLayoutSubviews()
    {
        collectionViewWidget.frame = view.bounds.rectByInsetting(dx: 10, dy: 10)
        
        blurOverlay.frame = CGRect(x: 0, y: view.frame.height - 40, width: view.frame.width, height: 40)

        let showDeletedOffset = (40.0 - showDeletedSwitch.frame.height) / 2
        showDeletedSwitch.frame = blurOverlay.frame.rectByInsetting(dx: showDeletedOffset, dy: showDeletedOffset)
        
        showDeletedLabel.frame = blurOverlay.frame.rectByInsetting(dx: showDeletedSwitch.frame.width + showDeletedOffset + 5, dy: 0)
        
        collectionViewWidget.reloadData()
    }
}


class ReactionDiffusionEntityRenderer: UICollectionViewCell
{
    let label = UILabel(frame: CGRectZero)
    let imageView = UIImageView(frame: CGRectZero)
    let blurOverlay = UIVisualEffectView(effect: UIBlurEffect())
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true

        label.numberOfLines = 0
        label.frame = CGRect(x: 0, y: frame.height - 20, width: frame.width, height: 20)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center

        imageView.frame = bounds.insetBy(dx: 0, dy: 0)
        
        blurOverlay.frame = CGRect(x: 0, y: frame.height - 20, width: frame.width, height: 20)
        
        contentView.addSubview(imageView)
        contentView.addSubview(blurOverlay)
        contentView.addSubview(label)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 1
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var reactionDiffusionEntity: ReactionDiffusionEntity?
    {
        didSet
        {
            if let _reactionDiffusionEntity = reactionDiffusionEntity
            {
                alpha = _reactionDiffusionEntity.pendingDelete ? 0.25 : 1

                label.text = _reactionDiffusionEntity.model
            
                let thumbnail = UIImage(data: (_reactionDiffusionEntity.imageData as NSData) as Data)
            
                imageView.image = thumbnail
            }
        }
    }
}
