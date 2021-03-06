////
////  firstViewController.swift
////  2020SummerProj
//  Created by Jiayi Ling on 2020/6/7.
//  Copyright © 2020 Jiayi Ling. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct Item {
    var itemName: String
    var price: double_t
    var imageName: String
    var latitude: double_t
    var longitude: double_t
}
class firstViewController: UIViewController {

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let cellidentifier = "ItemCollectionViewCell"
    let viewImageSegueIdentifier = "viewImageSegueIdentifier"
    let manager = CLLocationManager()
    
    @IBAction func SegControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            collectionView.isHidden = false
            mapView.isHidden = true
        } else {
            collectionView.isHidden = true
            mapView.isHidden = false
        }
    }
    
    var data:[Item] = [Item(itemName: "5W USB Official OEM Charger and Power", price: 19.9, imageName: "1", latitude: 37.0902, longitude: -95.7129),
                       Item(itemName: "Fire 7 Tablet - Black", price: 49.99, imageName: "2", latitude: 37.0902, longitude: -94.7129),
                       Item(itemName: "Alexa Voice Remote", price: 39.99, imageName: "3", latitude: 37.2902, longitude: -95.7429),
                       Item(itemName: "Echo Dot (3rd Gen)", price: 49.99, imageName: "4", latitude: 37.0952, longitude: -95.7199),
                       Item(itemName: "Champion Men's Jersey Short With Pockets", price: 11.20, imageName: "5", latitude: 38.0902, longitude: -92.7129),
                       Item(itemName: "CROC Classic Clog", price: 25.49, imageName: "6", latitude: 37.4902, longitude: -95.0129),
                       Item(itemName: "Polarized Aviator Sunglasses", price: 16.99, imageName: "7", latitude: 37.1902, longitude: -95.7829),
                       Item(itemName: "Remington R5000 Series Electric Rotary Shaver", price: 80.0, imageName: "8", latitude: 36.0902, longitude: -97.7129)]
    var filtedData:[Item]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        mapView.isHidden = true
        filtedData = data
        setupMapView()
        let font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        segControl.setTitleTextAttributes([NSAttributedString.Key.font: font as Any],
                                                for: .normal)
        segControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.419141829, blue: 0.3983109295, alpha: 1)], for: .selected)
        
    }
    
    private func setupMapView() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        var annotations:[MKPointAnnotation]! = []
        for data in filtedData {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
            annotation.title = data.itemName
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
        }
        mapView.showAnnotations(annotations, animated: true)
    }
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: cellidentifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellidentifier)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupCollectionViewItemSize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let item = sender as! Item
        if segue.identifier == viewImageSegueIdentifier {
            if let vc = segue.destination as? ImageViewerViewController {
                vc.imageName = item.imageName
                vc.itemN = item.itemName
                vc.price = item.price
            }
        }
    }
    
    private func setupCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let itemPerRow: CGFloat = 2
            let lineSpacing: CGFloat = 5
            let interItemSpacing: CGFloat = 5
            
            let width = (collectionView.frame.width - (itemPerRow - 1) *  interItemSpacing) / itemPerRow
            let height = width
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
}

extension firstViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtedData = searchText.isEmpty ? data : data.filter { $0.itemName.localizedCaseInsensitiveContains(searchText)}
        collectionView.reloadData()
        setupMapView()
    }
}

extension firstViewController:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellidentifier, for: indexPath) as! ItemCollectionViewCell
        cell.imageView.image = UIImage(named: "\(filtedData[indexPath.item].imageName)-1")
        cell.priceLabel.attributedText = NSAttributedString.init(string: "\(String(filtedData[indexPath.item].price)) $/day")
        cell.nameLabel.attributedText = NSAttributedString.init(string: filtedData[indexPath.item].itemName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = filtedData[indexPath.item]
        performSegue(withIdentifier: viewImageSegueIdentifier, sender: item)
    }
}
