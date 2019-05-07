import UIKit
import Firebase
import PopupDialog


extension Int {
    static var friend: Int {
        return 0
    }
    static var requestReceived : Int{
        return 1
    }
    static var requestSent : Int {
        return 2
    }
    static var notFriend : Int{
        return 3
    }
    
}


struct UserNode{
    var email : String  = ""
    var uid   : String  = ""
    var relation : RelationEnum = RelationEnum.notFriend //not friend

}

//TODO: to be removed in next refactoring

public enum RelationEnum: Int {
    case friend
    case requestSent
    case requestReceived
    case notFriend
}

class FriendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    
    var numberOfFields = 4
    var friends                 : [UserNode] = [UserNode]()
    var friendRequestsSent      : [UserNode] = [UserNode]()
    var friendRequestsReceived  : [UserNode] = [UserNode]()
    var users                   : [UserNode] = [UserNode]()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UITextField!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
        tableView.register(UINib(nibName: "CustomFriendCell", bundle: nil), forCellReuseIdentifier: "customFriendCell")
        reloadTableData()
    }

    func loadRestOfTheTable(){
        loadFriendsString(){
            (data) in
            uidstrToNode(uidstr: data){
                (tmpNode) in
                var node = UserNode(email: tmpNode.email, uid: tmpNode.uid, relation: .friend)
                node.relation = .friend
                self.friends.append(node)
                //disable the relative user row.
                self.users.remove(at: self.users.firstIndex{$0.uid == node.uid}!)
                self.tableView.reloadData()
            }
        }
        loadReqReceivedString(closure: {(data) in
            uidstrToNode(uidstr: data){
                (tmpNode) in
                //append the usernode in the array
                var node = UserNode(email: tmpNode.email, uid: tmpNode.uid, relation: .requestReceived)
                node.relation = .requestReceived
                self.friendRequestsReceived.append(node)
                //disable the relative user row.
                self.users.remove(at: self.users.firstIndex{$0.uid == node.uid}!)
                self.tableView.reloadData()
            }
        })
        loadReqSentString(closure: {(data) in
            uidstrToNode(uidstr: data){
                (tmpNode) in
                var node = UserNode(email: tmpNode.email, uid: tmpNode.uid, relation: .requestSent)
                node.relation = .requestSent
                self.friendRequestsSent.append(node)
                //disable the relative user row.
                self.users.remove(at: self.users.firstIndex{$0.uid == node.uid}!)
                self.tableView.reloadData()
            }
        })
    }
    
    func setupTableView(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120.0
    }
    
    
    func loadUsers(closure: @escaping ()->Void){
        //USERS
        database.reference().child("Users").observeSingleEvent(of: .value){
            (snapshot) in
            for nodeSnap in snapshot.children.allObjects as! [DataSnapshot]{
                if nodeSnap.key != authToken.currentUser?.uid{
                    //loading a different user
                    let node = nodeSnap.value as! Dictionary<String, String>
                    self.users.append(UserNode(email: node["email"]!, uid: nodeSnap.key, relation: RelationEnum.notFriend))
                    self.tableView.reloadData()
                }
            }
            closure()
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfFields
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //add the user to the list of friends
        if indexPath.section == .notFriend {
            sendFriendRequest(uid: users[indexPath.row].uid, email: users[indexPath.row].email)
        }
        
        //friend requests received
        if indexPath.section == .requestReceived {
            addFriend(uid : friendRequestsReceived[indexPath.row].uid, email: friendRequestsReceived[indexPath.row].email)
        }
        //removing friends
        if indexPath.section == .friend {
            //removeFriend(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == .friend {
            return friends.count
        }
        else if section == .requestReceived {
            return friendRequestsReceived.count
        }
        else if section == .requestSent {
            return friendRequestsSent.count
        }
        else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == .friend {
            return "Friends"
        }
        else if section == .requestReceived {
            return "Friends requests"
        }
        else if section == .requestSent {
            return "Friends requests sent"
        }
        else {
            return "Users"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customFriendCell", for: indexPath) as! CustomFriendCell
        if indexPath.section == .friend{
            cell.friendName.text = friends[indexPath.row].email
            cell.friendImage.image = UIImage(named: "egg")
        }
        else if indexPath.section == .requestReceived {
            cell.friendName.text = friendRequestsReceived[indexPath.row].email
            cell.friendImage.image = UIImage(named: "egg")
        }
        else if indexPath.section == .requestSent {
            cell.friendName.text = friendRequestsSent[indexPath.row].email
            cell.friendImage.image = UIImage(named: "egg")
        }
        if indexPath.section == .notFriend {
            cell.friendName.text = users[indexPath.row].email
            cell.friendImage.image = UIImage(named: "egg")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func sendFriendRequest(uid : String, email : String){
        //set the request in other person account
        guard let currentUserUID = authToken.currentUser?.uid else{
            print("could not send friend request because currentUser in not logged in")
            return
        }
        for req in friendRequestsSent{
            if req.uid == uid {
                let popup = PopupDialog(title: "Snap!", message: "You cannot add \(req.email) as a friend because you have already sent a request!")
                self.present(popup, animated: true, completion: nil)
                return
            }
        }

        for req in friendRequestsReceived{
            if req.uid == uid {
                setFriendship(friendUID:uid)
                return
            }
        }
        
        setFriendshipsRequest(uid: uid)
        let popup = PopupDialog(title: "Hurray!", message: "Your friend request to \(email) is on its way!")
        self.present(popup, animated: true, completion: nil)
        reloadTableData()

    }
    
    func addFriend(uid : String, email : String){
        setFriendship(friendUID: uid)
        let popup = PopupDialog(title: "Hurray!", message: " \(email) is now your friend!")
        self.present(popup, animated: true, completion: nil)
        reloadTableData()
    }
    
    func reloadTableData(){
        friends.removeAll()
        friendRequestsSent.removeAll()
        friendRequestsReceived.removeAll()
        users.removeAll()
        
        loadUsers(closure: {
            () in
            self.loadRestOfTheTable()
        })
    }
    
//endofclass
}
