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
    var geodesicPolyline : MKGeodesicPolyline?
    var polyline : MKPolyline?
    var planeAnnotation: MKPointAnnotation!
    var planeAnnotationPosition = 0
    var planeDirection: CLLocationDirection!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        let worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld)
        self.mapView.region = worldRegion
        
        addMarkers()
        
        addPlane()

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
        
        self.geodesicPolyline = MKGeodesicPolyline(coordinates: coordinates, count: 2)
        self.polyline = MKPolyline(coordinates: coordinates, count: 2)
        self.mapView.addOverlays([self.geodesicPolyline!, self.polyline!])
    }
    
    func addPlane(){
        let annotation = MKPointAnnotation()
        annotation.title = NSLocalizedString("Plane", comment: "Plane marker")
        self.mapView.addAnnotation(annotation)
        
        self.planeAnnotation = annotation
        self.updatePlanePosition()
    }
    
    @objc func updatePlanePosition() {
        let step = 5
        guard planeAnnotationPosition + step < geodesicPolyline!.pointCount
            else { return }
        
        let points = geodesicPolyline!.points()
        let previousMapPoint = points[planeAnnotationPosition]
        planeAnnotationPosition += step
        let nextMapPoint = points[planeAnnotationPosition]
        
        self.planeDirection = directionBetweenPoints(sourcePoint: previousMapPoint, nextMapPoint)
        self.planeAnnotation.coordinate = MKCoordinateForMapPoint(nextMapPoint)
        
        perform(#selector(MapViewController.updatePlanePosition), with: nil, afterDelay: 0.03)
    }
    
    private func directionBetweenPoints(sourcePoint: MKMapPoint, _ destinationPoint: MKMapPoint) -> CLLocationDirection {
        let x = destinationPoint.x - sourcePoint.x
        let y = destinationPoint.y - sourcePoint.y
        
        return radiansToDegrees(radians: atan2(y, x)).truncatingRemainder(dividingBy: 360) + 90
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
        if polyline is MKGeodesicPolyline{
            overlayRenderer.strokeColor = UIColor.blue
        }else{
            overlayRenderer.strokeColor = UIColor.red
        }
        return overlayRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor viewForAnnotation: MKAnnotation) -> MKAnnotationView? {
        let planeIdentifier = "Plane"
        let reuseIdentifier = "Marker"
        if viewForAnnotation.title == planeIdentifier{
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: planeIdentifier)
                ?? MKAnnotationView(annotation: viewForAnnotation, reuseIdentifier: planeIdentifier)
            
            annotationView.image = UIImage(named: "airplane")
            annotationView.transform.rotated(by: CGFloat(degreesToRadians(degrees: self.planeDirection)))
            
            return annotationView
        }else{
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if #available(iOS 11.0, *) {
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: viewForAnnotation, reuseIdentifier: reuseIdentifier)
                }
                view?.displayPriority = .required
            } else {
                if view == nil {
                    view = MKPinAnnotationView(annotation: viewForAnnotation, reuseIdentifier: reuseIdentifier)
                }
            }
            view?.annotation = viewForAnnotation	
            view?.canShowCallout = true
            return view
        }
    }
    
    private func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / Double.pi
    }
    
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * Double.pi / 180
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

