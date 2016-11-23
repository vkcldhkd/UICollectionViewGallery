//
//  File.swift
//  Pods
//
//  Created by Mehmed Kadir on 11/22/16.
//
//

import UIKit




open class VerticalFlowLayout: UICollectionViewFlowLayout {
    
    var collectionViewOriginalSize = CGSize.zero
    var used = false
    
    open var scalingOffset: CGFloat = 110
    open var minimumScaleFactor: CGFloat = 0.5
    
    
    func preferredContentOffsetForElement(at index: Int) -> CGPoint {
        guard self.collectionView!.numberOfItems(inSection: 0) > 0 else { return CGPoint(x: CGFloat(0), y: CGFloat(0)) }
        
        if used {
            return CGPoint(x:self.collectionView!.contentOffset.x, y:item(at: index)+tunc() - self.collectionView!.contentInset.bottom)
        }
        
        return CGPoint(x:self.collectionView!.contentOffset.x, y:item(at: index) - self.collectionView!.contentInset.bottom )
    }
    
    private func tunc()->CGFloat {
        return trunc(self.itemSize.height / 2) * collectionViewOriginalSize.height
    }
    
    private func item(at index: Int) -> CGFloat{
        return (self.itemSize.height + self.minimumLineSpacing) * CGFloat(index)
    }
    
    
    
    open func recenterIfNeeded() {
        if used {
            
            let page = self.collectionView!.contentOffset.y / collectionViewOriginalSize.height
            
            let radius = (self.collectionView!.contentOffset.y - trunc(page) * collectionViewOriginalSize.height) / collectionViewOriginalSize.height

            if radius >= 0.0 && radius <= 0.0002 && page >= self.itemSize.width / 2 + 40 {
                self.collectionView!.contentOffset = self.preferredContentOffsetForElement(at: 0)
            }
            if page < 1.0 {
                self.collectionView!.contentOffset = self.preferredContentOffsetForElement(at: 0)
            }
        }
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    override open func prepare() {
        assert(self.collectionView!.numberOfSections <= 1, "You cannot use UICollectionViewGallery with more than 2 sections")
        self.used = self.collectionView!.numberOfItems(inSection: 0) >= MIN_NUMBER_OF_ITEMS_REQUIRED
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, self.minimumLineSpacing)
        self.collectionView!.showsHorizontalScrollIndicator = false
        self.collectionView!.showsVerticalScrollIndicator = false
        super.prepare()
        self.collectionViewOriginalSize = super.collectionViewContentSize
    }
    
    
    override open var collectionViewContentSize: CGSize {
        var size: CGSize
        if used {
            size = CGSize(width: collectionViewOriginalSize.width, height: collectionViewOriginalSize.height * self.itemSize.height)
        }
        else {
            size = collectionViewOriginalSize
        }
        return size
        
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if self.collectionView == nil {
            return proposedContentOffset
        }
        
        let collectionViewSize = self.collectionView!.bounds.size
        
        
        let proposedRect = CGRect(x: 0, y: proposedContentOffset.y, width: collectionViewSize.height, height: collectionViewSize.width)
        
        let layoutAttributes = self.layoutAttributesForElements(in: proposedRect)
        
        if layoutAttributes == nil {
            return proposedContentOffset
        }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterY = proposedContentOffset.y + collectionViewSize.height / 2
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes! {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if fabs(attributes.center.y - proposedContentOffsetCenterY) < fabs(candidateAttributes!.center.y - proposedContentOffsetCenterY) {
                candidateAttributes = attributes
            }
            
        }
        
        if candidateAttributes == nil {
            return proposedContentOffset
        }
        
        var newOffsetX = candidateAttributes!.center.y - self.collectionView!.bounds.size.height / 2
        let offset = newOffsetX - self.collectionView!.contentOffset.y
        
        if (velocity.y < 0 && offset > 0) || (velocity.y > 0 && offset < 0) {
            let pageWidth = self.itemSize.height + self.minimumLineSpacing
            newOffsetX += velocity.y > 0 ? pageWidth : -pageWidth
        }
        
        return CGPoint(x: proposedContentOffset.x, y: newOffsetX)
        
        
    }
    
    
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if used == false {
            return super.layoutAttributesForElements(in: rect)!
        }
       
        let position = rect.origin.y / collectionViewOriginalSize.height
        let rectPosition = position - trunc(position)
        var modifiedRect = CGRect(x: rect.origin.x, y: rectPosition * collectionViewOriginalSize.height, width: rect.size.width, height: rect.size.height)
        var secondRect = CGRect.zero
        
        if modifiedRect.maxY > collectionViewOriginalSize.height {
            secondRect = CGRect(x: rect.origin.x, y: 0, width: rect.size.width, height: modifiedRect.maxY - collectionViewOriginalSize.height)
            modifiedRect.size.height = collectionViewOriginalSize.height - modifiedRect.origin.y
        }
        let attributes = self.newAttributes(for: modifiedRect, offset: trunc(position) * collectionViewOriginalSize.height)
        let attributes2 = self.newAttributes(for: secondRect, offset: (trunc(position) + 1) * collectionViewOriginalSize.height)
        let isResult = attributes + attributes2
        
        
        return isResult
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        
        return super.layoutAttributesForItem(at: indexPath)!
    }
    
    func newAttributes(for rect: CGRect, offset: CGFloat) -> [UICollectionViewLayoutAttributes] {
        let attributes = super.layoutAttributesForElements(in: rect)
        return self.modifyLayoutAttributes(attributes!, offset: offset)
    }
    
    func modifyLayoutAttributes(_ attributes: [UICollectionViewLayoutAttributes], offset: CGFloat) -> [UICollectionViewLayoutAttributes] {
        var isResult = [UICollectionViewLayoutAttributes]()
        let contentOffset = self.collectionView!.contentOffset
        let size = self.collectionView!.bounds.size
        
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: size.width, height: size.height)
        let visibleCenterY = visibleRect.midY
        
        for attr in attributes {
            let newAttr = attr
            newAttr.center = CGPoint(x: attr.center.x , y: attr.center.y + offset)
            isResult.append(newAttr)
            let distanceFromCenter = visibleCenterY - newAttr.center.y
            let absDistanceFromCenter = min(abs(distanceFromCenter), self.scalingOffset)
            let scale = absDistanceFromCenter * (self.minimumScaleFactor - 1) / self.scalingOffset + 1
            newAttr.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        }
        return isResult
        
    }
    
}

