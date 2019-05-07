//
//  CustomChatCell.swift
//  Flash Chat
//
//  Created by Francesco Maria Moneta (BFS EUROPE) on 30/04/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class CustomChatCell: UITableViewCell {
    @IBOutlet weak var chatImage: UIImageView!

    @IBOutlet weak var chatUserName: UILabel!
    
    @IBOutlet weak var chatLastMessage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
