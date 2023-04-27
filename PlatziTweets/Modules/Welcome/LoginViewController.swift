//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Inx on 13/04/23.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking// libreria para trabajar la los metodos http
import SVProgressHUD// libreria para mostrar indicadores de carga


class LoginViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: - IBActions
    @IBAction func loginButtonAction() {
        
        performLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    
    private func setupUI(){
        loginButton.layer.cornerRadius = 20
        
    }

    //MARK: - Private Methods
    private func performLogin () {
        //Guard let para asegurar que si se introdusca el email
        
        //optional binding
        guard let email = emailTextField.text, !email.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo", style: BannerStyle.warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Debes ingresar la contraseña", style: BannerStyle.warning ).show()
            return
        }
        
        if !email.isEmpty && !password.isEmpty{
            if isValidEmail(email){
        
                NotificationBanner(subtitle: "Bienvenido", style: BannerStyle.success).show()
                //crear request
                let request = LoginRequest(email: email, password: password)
                //iniciamos la carga
                SVProgressHUD.show()
                
                //llamar a libreria de red
                SN.post(endpoint: EndPoints.login,
                        model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
                    
                    SVProgressHUD.dismiss()
                // todo esto no funca, probablemente porque no jala nada del heroku app. Estan muertos los servicios
                    switch(response){
                    case .success(let user):
                        NotificationBanner(subtitle: "Bienvenido\(user.user.names)", style: BannerStyle.success).show()
                        self.performSegue(withIdentifier: "showHome", sender: nil)
                            //Para obtener el token con simplenetworking
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
                performSegue(withIdentifier: "showHome", sender: nil)
//                NotificationBanner(title: "Success", subtitle: "Éxito realizando login", style: BannerStyle.success).show()// no me gusta.. seguro que se puede hacer de manera más simple y chingón
            }
            NotificationBanner(title: "Invalid Email", subtitle: "Ingrese un correo valido", style: BannerStyle.warning).show()
            //Realizar el Login aquí
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    /* NOTA:
     if let and guard let serve similar, but distinct purposes.

     The "else" case of guard must exit the current scope. Generally that means it must call return or abort the program. guard is used to provide early return without requiring nesting of the rest of the function.

     if let nests its scope, and does not require anything special of it. It can return or not.

     In general, if the if-let block was going to be the rest of the function, or its else clause would have a return or abort in it, then you should be using guard instead. This often means (at least in my experience), when in doubt, guard is usually the better answer. But there are plenty of situations where if let still is appropriate.
     */
}
