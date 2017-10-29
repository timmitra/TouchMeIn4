//
//  DetailViewController.swift
//  TouchMeIn4
//
//  Created by Tim Mitra on 10/28/17.
//  Copyright © 2017 iT Guy Technologies. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
 // let ManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext


  @IBOutlet weak var detailTextView: UITextView!

  var note: Note? = nil
  
  var detailItem: AnyObject? {
    didSet {
      self.configureView()
    }
  }
  
  func configureView() {
    
    if let detail: Note = self.detailItem as? Note {
      if let detailTextView = self.detailTextView {
        detailTextView.text = detail.noteText
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
  }

}

