import UIKit
import Firebase
import SVProgressHUD
import PopupDialog


class RegisterViewController: UIViewController {

    
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        SVProgressHUD.show()
        let email = emailTextfield.text!
        let password = passwordTextfield.text!
        print("user \(email) is trying to signup")
        Auth.auth().createUser(withEmail: email , password: password, completion: {
            (user, error) in
            if error != nil{
                print(error!)
                SVProgressHUD.dismiss()
                let popup = PopupDialog(title: "Oh Snag!", message: "An error has occured")
                self.present(popup, animated: true, completion: nil)

            }
            else{
                let m = Database.database().reference().child("Users")
                let emailDictionary : Dictionary<String,Any> = ["email" : email, "friends":"", "requestsReceived":"", "requestsSent":""]
                m.child((Auth.auth().currentUser?.uid)!).setValue(emailDictionary){
                    (error, reference) in
                    if error != nil{
                        print(error!)
                        SVProgressHUD.dismiss()
                        let popup = PopupDialog(title: "Oh Snag!", message: "An error has occured")
                        self.present(popup, animated: true, completion: nil)
                    }
                    else{
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "goToChat", sender: self)
                    }
                }
            }
        })
    } 
}
