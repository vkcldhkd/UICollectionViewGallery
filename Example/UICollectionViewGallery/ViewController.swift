//
//  ViewController.swift
//  UICollectionViewGallery
//
//  Created by ro6lyo on 11/19/2016.
//  Copyright (c) 2016 ro6lyo. All rights reserved.
//

import UIKit
import UICollectionViewGallery

class ViewController: UIViewController {

    @IBOutlet weak var galleryCollectionView: UICollectionView!
    var stringArray: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    let verticalLayout = VerticalFlowLayout()
    var horizontalLayout = HorizontalFlowLayout()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        galleryCollectionView.isPagingEnabled = false
      
        configureGallery()
    }
    
    
    func configureGallery() {
        verticalLayout.minimumLineSpacing = 10
        verticalLayout.itemSize = CGSize(width: 200, height: 200)
        
        horizontalLayout.scrollDirection = .horizontal
        horizontalLayout.minimumLineSpacing = 10
        horizontalLayout.itemSize = CGSize(width: 200, height: 200)

    galleryCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    //galleryCollectionView.collectionViewLayout = horizontalLayout  // initail layout
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        switch toInterfaceOrientation {
        case .landscapeLeft,.landscapeRight:
            //horizontal.collectionViewLayout = self.horizontalLayout
         //   customScrollDirection = .horizontal
            UIView.animate(withDuration: 1) { () -> Void in
               // self.galleryCollectionView.collectionViewLayout.invalidateLayout()
               // self.galleryCollectionView.setCollectionViewLayout(self.gallery, animated: false)
            }
        

        case .portrait,.portraitUpsideDown,.unknown:
            //horizontal.collectionViewLayout = self.verticalLayout
            UIView.animate(withDuration: 1) { () -> Void in
               // self.galleryCollectionView.collectionViewLayout.invalidateLayout()
               // self.galleryCollectionView.setCollectionViewLayout(self.gallery, animated: false)
            }
        }
    }
    
    
}
//
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
//
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stringArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: customCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath as IndexPath) as? customCell)!
        cell.customLabel.text = stringArray[indexPath.row]
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if galleryCollectionView.collectionViewLayout.isKind(of: VerticalFlowLayout.self) {
            let lay = galleryCollectionView.collectionViewLayout as! VerticalFlowLayout
            lay.recenterIfNeeded()
        }
    }
    
}

class customCell :UICollectionViewCell {
    
    @IBOutlet weak var customLabel: UILabel!
}
