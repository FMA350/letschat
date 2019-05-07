import UIKit
import Firebase
import SVProgressHUD
import PopupDialog
class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()

        authToken.signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            SVProgressHUD.dismiss()
            if error != nil {
                print(error!)
                let popup = PopupDialog(title: "Snag!", message: "Wrong username or password")
                self.present(popup, animated: true, completion: nil)
            }
            else{
                print("login succesful")
                print("my key: \(authToken.currentUser?.uid)")
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    }
    
}  
