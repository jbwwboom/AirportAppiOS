//
//  MapViewController.swift
//  AirportApp
//
//  Created by Justin van den Boomen on 19/09/2018.
//  Copyright © 2018 Justin van den Boomen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    var airport : Airport?
    var schipholIcao = "EHAM"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMarkers()

        // Do any additional setup after loading the view.
    }
    
    
    func addMarkers(){
        
        let annotation = MKPointAnnotation()
        if let airport = airport{
            let centerCoordinate = CLLocationCoordinate2D(latitude: airport.latitude!, longitude: airport.longitude!)
            annotation.coordinate = centerCoordinate
            annotation.title = airport.name!
        }
        
        
        var schiphol : Airport?
        for airport in AirportFactory.getInstance().getAllAirports(force: false){
            if(airport.icao == schipholIcao){
                schiphol = airport
            }
        }
        
        let schipholPoint = MKPointAnnotation()
        if let schiphol = schiphol{
            let coordinate = CLLocationCoordinate2D(latitude: schiphol.latitude!, longitude: schiphol.longitude!)
            schipholPoint.coordinate = coordinate
            schipholPoint.title = schiphol.name!
        }
        
        self.mapView.addAnnotations([annotation, schipholPoint])
        
        let coordinates = [annotation.coordinate,schipholPoint.coordinate]
        
        let geodesicPolyline = MKGeodesicPolyline(coordinates: coordinates, count: 2)
        self.mapView.add(geodesicPolyline)
        
        print(geodesicPolyline.pointCount)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else{
            return MKOverlayRenderer()
        }
        
        let overlayRenderer = MKPolylineRenderer(polyline: polyline)
        overlayRenderer.lineWidth = 3.0
        overlayRenderer.alpha = 0.5
        overlayRenderer.strokeColor = UIColor.black
        
        return overlayRenderer
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
