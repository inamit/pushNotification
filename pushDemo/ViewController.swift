//
//  ViewController.swift
//  pushDemo
//
//  Created by Amit Inbar on 01/06/2017.
//  Copyright © 2017 Amit Inbar. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageBox: UITextField!
    @IBOutlet var signInBtn: UIButton!
    @IBOutlet var signOutBtn: UIButton!
    
    var messages = [Message]()
    
    let refreshControl = UIRefreshControl()
    
    var handle: AuthStateDidChangeListenerHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.messageBox.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(ViewController.observeMessages), for: .valueChanged)
        observeMessages()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.signInBtn.isHidden = true
                self.signOutBtn.isHidden = false
                
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func Post(_ sender: Any) {
        let msg: [String: AnyObject] = ["message": messageBox.text as AnyObject]
        let dbRef = Database.database().reference()
        dbRef.child("messages").childByAutoId().setValue(msg)
    }
    @IBAction func SignIn(_ sender: Any) {
        Auth.auth().signInAnonymously { (user, error) in
            if error != nil {
                print("error: \(String(describing: error?.localizedDescription))")
            } else {
                
                self.signInBtn.isHidden = true
                self.signOutBtn.isHidden = false
            }
        }
    }
    @IBAction func SignOut(_ sender: Any) {
        self.signOutBtn.isHidden = true
        self.signInBtn.isHidden = false
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            self.signInBtn.isHidden = true
            self.signOutBtn.isHidden = false
        }
        
    }
    
    
    
    func observeMessages() {
        self.messages.removeAll()
        let dbRef = Database.database().reference().child("messages")
        dbRef.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let text = Message()
                text.setValuesForKeys(dictionary)
                self.messages.insert(text, at: 0)
                
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                })
            }
            
        }, withCancel: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.message
        
        // Configure the cell...
        
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //let message = messages[indexPath.row]
            //let dbRef = Database.database().reference()
            //dbRef.child("messages").child(dbRef.key).removeValue()
        }
    }*/
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

