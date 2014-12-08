//
//  SelectedRegionVC.swift
//  MapMaker
//
//  Created by Parker Lewis on 11/8/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit
import MapKit

class SelectedRegionVC: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var regionNameLabel: UILabel!
    
    @IBOutlet weak var map: MKMapView!

    var selectedRegion : Reminder!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.selectedRegion.identifier
        
        self.map.delegate = self
        self.map.userInteractionEnabled = false
        
        self.regionNameLabel.text = "REGION:        \(self.selectedRegion.identifier)\n\nLATITUDE:     \(self.selectedRegion.latitude)\nLONGITUDE: \(self.selectedRegion.longitude)"
    
    
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Make the region and display on map
        let region = MKCoordinateRegionMakeWithDistance(self.selectedRegion.makeCoordinate(), self.selectedRegion.radius * 2, self.selectedRegion.radius * 2)
        self.map.setRegion(region, animated: true)
        
        // Show circular overlay
        let overlay = MKCircle(centerCoordinate: self.selectedRegion.makeCoordinate(), radius: self.selectedRegion.radius)
        self.map.addOverlay(overlay)

    }
    

    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
        return renderer
    }

}
