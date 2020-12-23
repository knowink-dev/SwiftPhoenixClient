//
//  ChatRoomViewController.swift
//  Basic
//
//  Created by Daniel Rees on 12/22/20.
//  Copyright © 2020 SwiftPhoenixClient. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftPhoenixClient
import RxSwiftPhoenixClient

class ChatRoomViewController: UIViewController {
  
  // MARK: - Child Views
  @IBOutlet weak var messageInput: UITextField!
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Attributes
  private let socket = Socket("https://phxchat.herokuapp.com/socket/websocket")
  private let topic: String = "rooms:lobby"
  
  private var lobbyChannel: Channel?
  

  private let disposeBag = DisposeBag()
  
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    
    // Setup the socket to receive open/close events
    socket.delegateOnOpen(to: self) { (self) in
      print("CHAT ROOM: Socket Opened")
    }
    
    socket.delegateOnClose(to: self) { (self) in
      print("CHAT ROOM: Socket Closed")
      
    }
    
    socket.delegateOnError(to: self) { (self, error) in
      print("CHAT ROOM: Socket Errored. \(error)")
    }
    
    socket.logger = { msg in print("LOG:", msg) }
    
    // Setup the Channel to receive and send messages
    let channel = socket.channel(topic, params: ["status": "joining"])
    channel.rx
      .on("join")
      .subscribe( onNext: { (message) in
        let payload = message.payload
        guard
            let username = payload["user"],
            let body = payload["body"] else { return }
        let newMessage = "[\(username)] \(body)"
        print("New mesage received: \(newMessage)")
      
      }).disposed(by: disposeBag)
    
    // Now connect the socket and join the channel
    self.lobbyChannel = channel
    self.lobbyChannel?
      .join()
      .delegateReceive("ok", to: self, callback: { (self, _) in
        print("CHANNEL: rooms:lobby joined")
      })
      .delegateReceive("error", to: self, callback: { (self, message) in
        print("CHANNEL: rooms:lobby failed to join. \(message.payload)")
      })
    
    self.socket.connect()
  }
    
  
  // MARK: - IB Actions
  @IBAction func onExitButtonPressed(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  
  @IBAction func onSendButtonPressed(_ sender: Any) {
    
  }
  
  
}
