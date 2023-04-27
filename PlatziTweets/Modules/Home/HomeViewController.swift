//
//  HomeViewController.swift
//  PlatziTweets
//
//  Created by Inx on 18/04/23.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit
import AVFoundation

class HomeViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView : UITableView!
    
    //MARK: - Properties
    private let cellId = "TweetTableViewCell"
    private var datasource = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    //metodo de ciclo de vida
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPost()// esto asegura que cada que se muestre en la pantalla, se va a llamar al getPost (pa los tweets)
        // no jalaba antes por la manera de presentacion del segue, se cambió a full screen y ya deberia funcar
    }
    
    private func setupUI(){
        
        tableView.delegate = self

        // configuracion de la tabla
        
        //1. asignar datasource
        
        tableView.dataSource = self
        //2. registrar celda
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    private func getPost(){
        // indicar carga al usuario
        SVProgressHUD.show()
        
        //2. Consumir el servicio
        
        SN.get(endpoint: EndPoints.tweets) { (response: SNResultWithEntity<[Tweet], ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            switch(response){
            case .success(response: let tweets):
                self.datasource = tweets
                self.tableView.reloadData()
                
            case .error(let error):
                //todo lo malo
                
                NotificationBanner(title: "Error", subtitle: "El error fue grave y es desconocido", style: BannerStyle.warning).show()
                print( "El grave error es \(error)")
                return
            case .errorResult(let entity):
                //error pero no tan malo
                
                NotificationBanner(title: "Semi-Error", subtitle: "El error es: \(entity.error)", style: BannerStyle.warning).show()
                return
                
            }
        }
    }
    // metodo que se va a encargar de eliminar un elemndo dao un indice... recuerda, un metodo solo debe realizar una cosa
    private func deletePostAt(indexPath : IndexPath){
        //1. indicar carga al usuario
        SVProgressHUD.show()
        //2. Obtener ID del post que se va a eliminar
        //let tweetId = datasource[indexPath.row].id
        //3. Preparamos el endpoint para borrar
        let endPoint = EndPoints.tweets //+ //"/\(tweetId)"
        //4. consumir servicio para borrar el tweet
        SN.delete(endpoint: endPoint) {( response: SNResultWithEntity<DeleteTweetResponse, ErrorResponse>) in
            // cerramos el indicador de carga
            
            SVProgressHUD.dismiss()
            switch response{
            case .success:
                //1. borrar el tweet del datasource
               // self.datasource.remove(at: indexPath.row)
                //2. Borrar la celda de la tabla
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
                
            case .error(let error):
                //todo lo malo
                
                NotificationBanner(title: "Error", subtitle: "El error fue grave y es desconocido", style: BannerStyle.warning).show()
                print( "El grave error es \(error)")
                
                // Se pondrá el código para eliminar del datasource aqui, dado que el api no funciona
                //self.datasource.remove(at: indexPath.row)// para el api
                //2. Borrar la celda de la tabla
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
               // return
                
            case .errorResult(let entity):
                //error pero no tan malo
                
                NotificationBanner(title: "Semi-Error", subtitle: "El error es: \(entity.error)", style: BannerStyle.warning).show()
                //no debe ir en los errorres
                self.tableView.deleteRows(at: [indexPath], with: .left)

                return
            }
        }
    }

}

//MARK: UITableDelegate
extension HomeViewController : UITableViewDelegate {
    //con este método le vamos a especificar a nuestra tabla que acciones pueden tener las celdas
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Borrar") { _, _ in
            //Aquí borramos el tweet
            self.deletePostAt(indexPath: indexPath)
            
        }
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //guardar el correo del usuario y validar contra uno real
        //return datasource[indexPath.row].author.email != "test1@test.com"// COMENTADO para el e test
        return true
        
    }
}


//MARK: - UITableViewDataSource
extension HomeViewController : UITableViewDataSource{
    //numero total de celdas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Esta validación se realizó porque no funca la api del curso
        if datasource.isEmpty{
            return 20
        }else{
            return datasource.count
        }
        
        
    }
    // que celda mostrar - configurar celda deseada
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        if let cell = cell as? TweetTableViewCell{
            // confifurar  la celda
            if datasource.isEmpty{
                print("data source empty")
            }else{
                cell.setupCellWith(tweet: datasource[indexPath.row])
                //Para mostrar video
                cell.needsToShowVideo = { url in// casi seguro que es un closure
                    //Aquí SI deberiamos abrir un viewControler
                    //llamar al avpplayer para reproducir el video
                    let avPlayer = AVPlayer(url: url)// este es el video
                    let avPlayerController = AVPlayerViewController()// se encarga de levantar una pantalla con un reproductor de video
                    avPlayerController.player = avPlayer
                    
                    //"Presenter"es nuestro método que nos presenta nuevas pantallas
                    self.present(avPlayerController, animated: true) {
                        avPlayerController.player?.play()
                    }
                    
                }
            }
            
            
        }
        return cell
    }
}

//MARK: - Navigation
extension HomeViewController {
    // este metodo se va a llamar cuando haya una trancición de una pantalla A a una B pero solo con storyboards
    //Hacer 2 validaciones:
    //1. Que el segue, o sea la conección, sea la que deseamos
    //2. Que vaya a donde deseamos que vaya.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //1. validar que el segue sea el esperado.
        if segue.identifier == "showMap", let mapViewController = segue.destination as? MapViewController { //el destination es el view al que va a llegar y se va a castear (as?) a MapViewController
            //YA sabemos que si vamos a la pantalla del map
            mapViewController.tweets = datasource.filter { $0.hasLocation} // orale, es como los closures que se vieron anetes. de los data source filtrame los que tienen haslocation.
            
        }
    }
}
