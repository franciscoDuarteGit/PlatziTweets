//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Inx on 13/04/23.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    
    //MARK: - IBActions
    @IBAction func registerButtonAction() {
        view.endEditing(true)
        performRegister()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUi()
        // Do any additional setup after loading the view.
    }
    
    private func setupUi(){
        registerButton.layer.cornerRadius = 20
        
    }

    private func performRegister () {
        //Guard let para asegurar que si se introdusca el email
        
        //optional binding
        guard let email = emailTextField.text, !email.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo", style: BannerStyle.warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Debes ingresar la contraseña", style: BannerStyle.danger ).show()
            return
        }
        
        guard let fullName = fullNameTextField.text, !fullName.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Debes ingresar tu nombre completo", style: BannerStyle.warning ).show()
            return
        }
        
        if !email.isEmpty && !password.isEmpty && !fullName.isEmpty{
            //crear request
            let request = RegisterRequest(email: email, password: password, names: fullName)
            
            //indicar la carga al usuario
            SVProgressHUD.show()
            
            SN.post(endpoint: EndPoints.register,
                    model: request) { (response: SNResultWithEntity<RegisterResponse, ErrorResponse>) in// que menso, el loginResponse devuelve lo mismito
                
                SVProgressHUD.dismiss()// cerramos la carga al usuario
            // todo esto no funca, probablemente porque no jala nada del heroku app. Estan muertos los servicios
                switch(response){
                    
                case .success(let user):
                    NotificationBanner(subtitle: "Bienvenido\(user.user.names)", style: BannerStyle.success).show()
                    self.performSegue(withIdentifier: "showHome", sender: nil)
                    SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)

                    //todo lo bueno
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
            
            
            //NotificationBanner(title: "Success", subtitle: "Éxito realizando login", style: BannerStyle.success).show()// no me gusta.. seguro que se puede hacer de manera más simple y chingón
            
            //realizar el registro aquí
        }
    }

}
