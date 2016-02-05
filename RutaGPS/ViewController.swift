//
//  ViewController.swift
//  RutaGPS
//
//  Created by Aaron Marquez on 03/02/16.
//  Copyright © 2016 Aaron Marquez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var mapa: MKMapView!
    private let manejador = CLLocationManager()
    var ubicacion: CLLocation!
    var distanciaAnterior:CLLocationDistance!
    var distanciaRecorrida:CLLocationDistance!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manejador.delegate = self
        manejador.desiredAccuracy  = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tipoDeMapa(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            mapa.mapType = .Standard
        case 1:
            mapa.mapType = .Satellite
        case 2:
            mapa.mapType = .Hybrid
        default:
            mapa.mapType = .Standard
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
            
        }else{
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if ubicacion == nil{
            iniciarValoresDeRuta()
        }else{
            distanciaRecorrida = manejador.location!.distanceFromLocation(ubicacion!)
            if (distanciaRecorrida - distanciaAnterior) > 50 {
                agregarPinMapa("Distancia recorrida:\(distanciaRecorrida)")
                distanciaAnterior = distanciaRecorrida
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "Error", message: "error \(error.code)", preferredStyle: .Alert)
        let accionOk = UIAlertAction(title: "Ok", style: .Default, handler: {
            (accion) in
            //..Se reinician valores
            self.iniciarValoresDeRuta()
        })
        alerta.addAction(accionOk)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    func iniciarValoresDeRuta(){
        ubicarRegionEnMapa()
        agregarPinMapa("Inicio de ruta")
        ubicacion = manejador.location
        distanciaAnterior = 0
        distanciaRecorrida = 0
    }
    
    func ubicarRegionEnMapa(){
        var region:MKCoordinateRegion = MKCoordinateRegion()
        region.span.latitudeDelta = 0.004
        region.span.longitudeDelta = 0.004
        region.center.latitude =  (manejador.location?.coordinate.latitude)!
        region.center.longitude = (manejador.location?.coordinate.longitude)!
        mapa.region = region
    }
    
    func agregarPinMapa(subtitulo: String){
        var coordenadas = CLLocationCoordinate2D()
        let pin = MKPointAnnotation()
        
        pin.subtitle = subtitulo
        coordenadas.latitude =  (manejador.location?.coordinate.latitude)!
        coordenadas.longitude = (manejador.location?.coordinate.longitude)!
        pin.title = "Latitud\(coordenadas.latitude), Longitud\(coordenadas.longitude)"
        pin.coordinate = coordenadas
        mapa.addAnnotation(pin)
    }
    
}

