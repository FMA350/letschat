import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    var friends : [UserNode] = [UserNode]()
    var selectedFriend : Int = -1

    @IBOutlet var messageTableView: UITableView!
    
    
    @IBAction func backButton(_ sender: Any) {
        do{
            try authToken.signOut()
            self.navigationController?.popViewController(animated: true)
        }
        catch{
            print("error signing out")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        retrieveChats()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        messageTableView.dataSource = self
        messageTableView.delegate   = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        messageTableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.senderUsername.text = friends[indexPath.row].email
        cell.messageBody.text = friends[indexPath.row].email //TODO: Change to the last sent text
        cell.avatarImageView.image = UIImage(named: "egg")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //add the user to the list of friends
        selectedFriend = indexPath.row
        performSegue(withIdentifier: "goToMessageView", sender: self)
    }
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    func retrieveChats(){
        friends.removeAll()
        loadFriendsString(){
            (data) in
            uidstrToNode(uidstr: data){
                (tmpNode) in
                var node = UserNode(email: tmpNode.email, uid: tmpNode.uid, relation: .friend)
                node.relation = .friend
                self.friends.append(node)
                //disable the relative user row.
                self.messageTableView.reloadData()
            }
        }
    }

    @IBAction func showFriends(_ sender: Any) {
        self.performSegue(withIdentifier: "goToFriendsView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if segue.identifier == "goToMessageView"  {
            let vc : MessageViewController = segue.destination as! MessageViewController
            vc.setFriendData(friend: friends[selectedFriend])
        }
            
        
    }
    
//end of class
}

