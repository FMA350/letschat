//
//  databaseIO.swift
//  Flash Chat
//
//  Created by Francesco Maria Moneta (BFS EUROPE) on 01/05/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import Foundation
import Firebase

var database = Database.database()
var authToken = Auth.auth()

func loadReqSentString(uid : String? = Auth.auth().currentUser?.uid, closure : @escaping (_ data:String)->Void){
    guard let currentUserId = uid  else {
        print("could not run func loadRequestsSent() because currentUser is not set")
        return
    }
    database.reference().child("Users").child(currentUserId).observeSingleEvent(of: .value){
        (snapshot) in
        if let node = snapshot.value as? Dictionary<String, String>{
            let requestsSent : String = node["requestsSent"] as! String
            closure(requestsSent)
        }
    }
}

func loadReqReceivedString(uid: String? = Auth.auth().currentUser?.uid, closure : @escaping (_ data:String)->Void){
    
    guard let currentUserId = uid  else {
        print("could not run func loadRequestsReceived() because currentUser is not set")
        return
    }
    database.reference().child("Users").child(currentUserId).observeSingleEvent(of: .value){
        (snapshot) in
        if let node = snapshot.value as? Dictionary<String, String>{
            let requestsReceived : String = node["requestsReceived"] as! String
            closure(requestsReceived)
        }
    }
}

func loadFriendsString(uid: String? = Auth.auth().currentUser?.uid, closure : @escaping (_ data:String)->Void){
    guard let currentUserId = uid  else {
        print("could not run func loadFriends() because currentUser is not set")
        return
    }
    database.reference().child("Users").child(currentUserId).observeSingleEvent(of: .value){
    (snapshot) in
        if let node = snapshot.value as? Dictionary<String, String>{
            let requestsReceived : String = node["friends"] as! String
            closure(requestsReceived)
        }
    }
}

func uidstrToNode(uidstr: String, closure : @escaping (_ data: UserNode)->Void){
    let requests = uidstr.split(separator: ";")
    for uid in requests{
        loadUserNode(uid: String(uid)){
            (data) in
            closure(data)
        }
    }
}

func loadUserNode(uid: String, closure : @escaping(_ data:UserNode)->Void){
    var node = UserNode(email: "", uid: "", relation: .notFriend)
    database.reference().child("Users").child(uid).observeSingleEvent(of: .value){
        (snapshot) in
        if var snapshotValue = snapshot.value as? [String:String]{
            node.email = snapshotValue["email"]!
            node.uid   = uid
            closure(node)
        }
    }
}

func setFriendshipsRequest(uid: String){
    guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
    loadReqReceivedString(uid: uid){
        (str) in
        let newString = str + "\(currentUserUID);"
    database.reference().child("Users").child(uid).child("requestsReceived").setValue(newString)
    }
    loadReqSentString{
        (str) in
        let newString = str + "\(uid);"
        database.reference().child("Users").child(currentUserUID).child("requestsSent").setValue(newString)
    }
}

func setFriendship(friendUID : String){
    guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
    
    //remove from the friend request sent
    loadReqSentString(uid: friendUID){
        (str) in
        let newString = str.replacingOccurrences(of: currentUserUID+";", with: "")
        database.reference().child("Users").child(friendUID).child("requestsSent").setValue(newString)
    }
    //remove from my requestsreceived
    loadReqReceivedString(){
        (str) in
        let newString = str.replacingOccurrences(of: friendUID+";", with: "")
        database.reference().child("Users").child(currentUserUID).child("requestsReceived").setValue(newString)
    }
    //add the friend to my friends
    loadFriendsString(){
        (str) in
        let newString = str + "\(friendUID);"
        database.reference().child("Users").child(currentUserUID).child("friends").setValue(newString)
    }
    // add myself to friends' friends
    
    loadFriendsString(uid: friendUID){
        (str) in
        let newString = str + "\(currentUserUID);"
        database.reference().child("Users").child(friendUID).child("friends").setValue(newString)
    }

}
