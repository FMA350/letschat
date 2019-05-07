import UIKit
import Firebase


class MessageViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var friend : UserNode = UserNode()
    var messageArray : [Message] = [Message]()
    var chatName : String = ""

    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.dataSource = self
        messageTableView.delegate   = self
        inputField.delegate         = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        messageTableView.separatorStyle = .none
        setupChat()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(messageArray.count)
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.avatarImageView.image = UIImage(named: "egg")
        if cell.senderUsername.text == authToken.currentUser?.email as String? {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else{
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatSand()
        }
        return cell
    }
    
    @objc func tableViewTapped(){
        inputField.endEditing(true)
    }
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        inputField.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDB = database.reference().child(chatName)
        let messageDictionary = ["sender" : authToken.currentUser?.email, "messageBody": inputField.text!]
        messageDB.childByAutoId().setValue(messageDictionary){
            (error, reference) in
            
            if error != nil{
                print(error!)
            }
            else{
                print ("Message delivered successfully!")
            }
        }
        self.inputField.isEnabled = true
        self.sendButton.isEnabled = true
        self.inputField.text = ""
    }
    
    func setupChat(){
        if friend.uid.count == 0 {
            return
        }
        var db = database.reference().child(friend.uid+(authToken.currentUser?.uid)!)
        db.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if snapshot.exists(){
                self.chatName = self.friend.uid+(authToken.currentUser?.uid)!
                self.retrieveMessages(db: db)
            }
            else{
                db = database.reference().child(authToken.currentUser!.uid+self.friend.uid)
                self.chatName = authToken.currentUser!.uid+self.friend.uid
                self.retrieveMessages(db: db)
            }
        })
    }
    
    func retrieveMessages(db : DatabaseReference){
        let messageDB = db
        messageDB.observe(.childAdded){
            (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["messageBody"]!
            let sender = snapshotValue["sender"]!
            print("Sender: \(sender), text: \(text)")
            let msg : Message = Message()
            msg.messageBody = text
            msg.sender = sender
            self.messageArray.append(msg)
            self.configureTableView()
            print(self.messageArray.count)
            self.messageTableView.reloadData()
        }
        
    }
}

extension MessageViewController : FriendDelegate{
    
    func setFriendData(friend: UserNode) {
        self.friend = friend
    }
    
}
