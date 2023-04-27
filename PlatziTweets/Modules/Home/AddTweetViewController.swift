//
//  AddTweetViewController.swift
//  PlatziTweets
//
//  Created by Inx on 19/04/23.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import FirebaseStorage
import AVFoundation// desde aqui
import AVKit
import MobileCoreServices// hasta aqui, es lo que nos permitirá trabajar todo lo que tiene que ver con el reproductor de videos.
import CoreLocation//para localización

//paara error??
import UniformTypeIdentifiers


class AddTweetViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tweetTextTextView : UITextView!
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var publishButton : UIButton!
    @IBOutlet weak var previewImageView : UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    //MARK: - IBActions
    @IBAction func addTweetAction(){
        //validaciones para subir el post
        if currentVideoURL != nil{
            uploadVideoToFirebase()
            return
        }
        if previewImageView.image != nil {
            uploadPhotoToFirebase()
            return
        }
        
        postTweet(imageUrl: nil, videoUrl: nil)
        //uploadPhotoToFirebase()
        //openVideoCamera()// nomas para calar la grabación de video
        
        //llamar al metodo uploadVideoToFirebase
        //uploadVideoToFirebase()// a pues aqui se llama al metodo para agregar un tweet
        
        
    }
    
    @IBAction func backAction(){
        dismiss(animated: true,completion: nil)
        
    }
    
    @IBAction func openCameraAction(){
        // Hacer un selector para que el usuario decida si tomar una imagen o un video
        //Esto del alert es para mostrar un dialogo con opciones, los addAction sirven para agregar las opciones a los dialogos
        let alert = UIAlertController(title: "Cámara",
                                      message: "Selecciona una opción",
                                      preferredStyle: .actionSheet)// sirve para mostrar dialogos nativos al usuario en iOS
        
        
        //acción para abrir la camara para tomar foto
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { _ in
            self.openCamera()
        }))
        //acción para abrir la camara y capturar un video
        alert.addAction(UIAlertAction(title: "Vídeo", style: .default, handler: { _ in
            self.openVideoCamera()
        }))
        //para cancelar
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        //despues de configurar el alert, toca presentarlo
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = currentVideoURL else {
            return
        }
        //llamar al avpplayer para reproducir el video
        let avPlayer = AVPlayer(url: currentVideoURL)// este es el video
        let avPlayerController = AVPlayerViewController()// se encarga de levantar una pantalla con un reproductor de video
        avPlayerController.player = avPlayer
        
        //"Presenter"es nuestro método que nos presenta nuevas pantallas
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    
    //MARK: - Properties
    
    //propiedades
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    //propiedades nuevas para trabajar con la localización
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoButton.isHidden = true
        // Do any additional setup after loading the view.
        requestLocation()
    }
    
    
    //MARK: - Private Functions
    
    private func requestLocation(){
        //Validamos que el usario tenga el GPS activo y disponible
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager = CLLocationManager()
        //tenemos que asignarle un delegate
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest// esto es la certeza de la ubicación que tienes.
        locationManager?.startUpdatingLocation()// para que arranque a actualizar la ubicación apenas tenga la oportunidad.
    }
    
    private func openVideoCamera (){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]// nueva propiedad para  usar video
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self// con este delegate controlamos cuando o cuando no se toma la foto
        
        // si esto no se instancio pues entonces no pasa nada, solo return
        guard let imagePicker = imagePicker else{
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openCamera (){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self// con este delegate controlamos cuando o cuando no se toma la foto
        
        // si esto no se instancio pues entonces no pasa nada, solo return
        guard let imagePicker = imagePicker else{
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func uploadPhotoToFirebase(){
        
        //1. Asegurarnos que la imagen exista
        guard let imageSaved = previewImageView.image,
              // 2.comprimir la imagen y convertirla en Data
              let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else{// compressionQuality comprime la imagen para que esta sea muy ligera
            return
        }
        
        SVProgressHUD.show()
        //3. Configuración para guardar la imagen en Firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        //4. Referencia al storage de firebase
        let storage = Storage.storage()
        
        //5.crear nombre de la imagen a suir
        let imageName = Int.random(in: 100...1000)
        
        //6. Crear la referencia a ala carpeta donde se va a guardar la foto
        let folderReference  = storage.reference(withPath: "fotos-tweets/\(imageName).jpg")
        
        //7. Subir la foto al Firebase
        
        DispatchQueue.global(qos: .background).async {// dispatchQ porque esto puede ser una tarea pesada
            folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error? ) in
                
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    if let error  = error {
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: BannerStyle.warning).show()
                        return
                    }
                    
                    //obtener la URL de descarga
                    folderReference.downloadURL {(url: URL?,error: Error?) in
                        print(url?.absoluteString ?? "")
                        let downloadUrl = url?.absoluteString ?? ""
                        self.postTweet(imageUrl: downloadUrl, videoUrl: nil)
                    }
                }
            }
        }
    }
    
    
    // RETO: volver estas 2 funciones una sola con ayuda de parametros!
    private func uploadVideoToFirebase (){
        //1. Asegurarnos que el vídeo exista
        guard let currentVideoSavedURL = currentVideoURL,
              //2. Convertir en data el video
              let videoData : Data = try? Data(contentsOf: currentVideoSavedURL) else {
            return
        }
        
        // indicamos que algo esta cargando
        SVProgressHUD.show()
        //3. Configuración para guardar la imagen en Firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/mp4"
        
        //4. Referencia al storage de firebase
        let storage = Storage.storage()
        
        //5.crear nombre de la imagen a suir
        let videoName = Int.random(in: 100...1000)
        
        //6. Crear la referencia a ala carpeta donde se va a guardar la foto
        let folderReference  = storage.reference(withPath: "video-tweets/\(videoName).mp4")
        
        //7. Subir el vídeo al Firebase
        
        DispatchQueue.global(qos: .background).async {// dispatchQ porque esto puede ser una tarea pesada
            folderReference.putData(videoData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error? ) in
                
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    if let error  = error {
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: BannerStyle.warning).show()
                        return
                    }
                    
                    //obtener la URL de descarga
                    folderReference.downloadURL {(url: URL?,error: Error?) in
                        print(url?.absoluteString ?? "")
                        let downloadUrl = url?.absoluteString ?? ""
                        self.postTweet(imageUrl: nil, videoUrl: downloadUrl)
                    }
                }
            }
        }
    }
    
    
    // una vez terminado lo de la localizacion, ya esta terminado toda esta vista y el viewController
    private func postTweet(imageUrl : String?, videoUrl: String?){// se modificó, antes no recibia nada
        //Crear un request de localización
        var tweetLocation: TweetRequestLocation?
        
        if let userLocation = userLocation {
            tweetLocation = TweetRequestLocation(latitude: userLocation.coordinate.latitude,
                                                 longitude: userLocation.coordinate.longitude)
        }
        
        //1 crear request
        let request : TweetRequest
        
        //2. indicar carga al usuario
        SVProgressHUD.show()
        
        //3. Llamar al servicio del post
        if let text = tweetTextTextView.text {
            request = TweetRequest(text: tweetTextTextView.text,
                                   imageUrl: imageUrl,
                                   videoUrl: videoUrl,
                                   location: tweetLocation)// Cambie el tipo del ultimo parametro
            
            SN.post(endpoint: EndPoints.register,
                    model: request) { (response: SNResultWithEntity<Tweet, ErrorResponse>) in
                
                //4. cerrar indicador de carga
                SVProgressHUD.dismiss()
                
                
                switch(response){
                case .success:
                    self.dismiss(animated: true, completion: nil)
                    
                    
                case .error(let error):
                    //todo lo malo
                    
                    NotificationBanner(title: "Error", subtitle: "El error fue grave y es desconocido", style: BannerStyle.warning).show()
                    print( "El grave error es \(error)")
                    self.dismiss(animated: true, completion: nil)// aqui porque si no nunca se va a quitar, dado que el api no funca
                    return
                case .errorResult(let entity):
                    //error pero no tan malo
                    self.dismiss(animated: true, completion: nil)// aqui porque si no nunca se va a quitar, dado que el api no funca
                    NotificationBanner(title: "Semi-Error", subtitle: "El error es: \(entity.error)", style: BannerStyle.warning).show()
                    return
                    
                }
                
            }
            
            
            
            
        }else{
            print("No tiene texto")
        }
    }
    
    
}

//MARK: - UIImagePickerControllerDelegate
extension AddTweetViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //este metodo se va a disparar cuando el usuario termine de seleccionar la foto de la galeria, tomar la foto etc.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //cerrar cámara
        imagePicker?.dismiss(animated: true, completion: nil)
        
        //capturar imagen
        if info.keys.contains(.originalImage) {// el info que se llama, es un diccionario. le decimos, oye diccionario, en tus llames tienes una llave que contenga una originalImage
            previewImageView.isHidden = false
            
            //obtenemos la imagen tomada
            previewImageView.image = info[.originalImage] as? UIImage
        }
        
        // capturamos la url del video// lo de abajo era namas pa calar el grabado de video, debe ir en la accion de openPreviewAction
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL{
            
            
            videoButton.isHidden = false
            currentVideoURL = recordedVideoUrl
            //            //llamar al avpplayer para reproducir el video
            //            let avPlayer = AVPlayer(url: recordedVideoUrl)// este es el video
            //            let avPlayerController = AVPlayerViewController()// se encarga de levantar una pantalla con un reproductor de video
            //            avPlayerController.player = avPlayer
            //
            //            //"Presenter"es nuestro método que nos presenta nuevas pantallas
            //            present(avPlayerController, animated: true) {
            //                avPlayerController.player?.play()
            //            }
        }
    }
}


//MARK: - CLLocationManagerDelegate
extension AddTweetViewController : CLLocationManagerDelegate{
    //para obtener los resultados de la geolocalización
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let bestLocation = locations.last else { //con esto obtenemos el utlimo de ese arreglo, o sea, el más preciso
            return
        }
        
        //Ya tenemos la ubicación del usuario!😄
    }
}
