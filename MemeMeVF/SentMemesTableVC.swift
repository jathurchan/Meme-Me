//
//  ViewController.swift
//  MemeMeVF
//
//  Created by Jathurchan Selvakumar on 13/02/2021.
//

import UIKit

class SentMemesTableVC: UITableViewController{
    
    // MARK: Model
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView!.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell", for: indexPath) as! MemeTableCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        // Set the name of the meme and the memed image
        
        cell.memeTableLabel.text = "\(meme.topText.uppercased())...\(meme.bottomText.uppercased())"
        cell.memeTableImageView.image = meme.memedImage
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailVC") as! MemeDetailVC
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    
    // MARK: Actions

    @IBAction func presentMemeEditor(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let memeEditorVC = storyboard.instantiateViewController(withIdentifier: "MemeEditorVC")
        
        memeEditorVC.modalPresentationStyle = .fullScreen
        
        present(memeEditorVC, animated: true, completion: nil)
    }

}

