//
//  MapViewController.swift
//  PlatziTweets
//
//  Created by Inx on 26/04/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var mapContainer: UIView! //Container porque va mostrar el mapa, es la vista en blanco que se agregó
    
    
    //MARK: - Properties
    var tweets = [Tweet]()
    var map : MKMapView? // es la verdadera representación del mapa que se insertará dentro del contenedor
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupMap()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupMap()
    }
    
    //MARK: - Private Functions
    //Configura el mapa
    private func setupMap(){
        map = MKMapView(frame: mapContainer.bounds)// pide como parametro un frame, y con .bounds le damos las dimensiones de ese frame
        
        mapContainer.addSubview(map ?? UIView())// como no se puede dar una opcional como parametro, le decimos que tiene una por default
        setupMarkers()
        
    }
    //configura los marcadores
    private func setupMarkers(){
        tweets.forEach{ item in
            let marker  = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)// le damos la localización al marcador
            marker.title = item.text// oye marcador, este es tu titulo
            marker.subtitle = item.author.names// oye marcador, los subtitulos serán los nombres de quien hizo el tweet
            map?.addAnnotation(marker)// le agregamos el marcador al mapa
            
        }
        //buscar la ultima posición de los tweets. buscamos el último tweet del arreglo
        guard let lastPost = tweets.last else {
            return
        }
        
        //crear la ubicación del último tweet
        let lastTweetLocation = CLLocationCoordinate2D(latitude: lastPost.location.latitude, longitude: lastPost.location.longitude)
        
        guard let heading =  CLLocationDirection(exactly: 12) else {
            return
        }
        //es lo que nos va a permitir movernos en el mapa de manera inicial
        map?.camera = MKMapCamera(lookingAtCenter: lastTweetLocation, fromDistance: 30, pitch: 0, heading: heading)// jugar con estos valores para comprenderlo mejor
        
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
