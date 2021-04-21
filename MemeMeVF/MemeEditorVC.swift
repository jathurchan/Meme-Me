//
//  MemeEditorVC.swift
//  MemeMeVF
//
//  Created by Jathurchan Selvakumar on 13/02/2021.
//

import UIKit

class MemeEditorVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTF: UITextField!
    @IBOutlet weak var bottomTF: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    // MARK: Properties
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -2
    ]
    var modifiedTopTF = false   // used to know if default text in the Text Field or not
    var modifiedBottomTF = false    // same here
    
    
    // MARK: Init Text Fields
    
    func setupTextField(tf: UITextField,text: String) {
        tf.text = text
        tf.defaultTextAttributes = self.memeTextAttributes
        tf.textAlignment = .center
        tf.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fill behind the notch
        self.navbar.delegate = self
        
        // Customize text fields
        setupTextField(tf: topTF, text: "TOP")
        
        setupTextField(tf: bottomTF, text: "BOTTOM")
        
        // Disable Share button
        self.shareButton.isEnabled = false
        
        // Diable Camera button
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.cameraButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: NotificationCenter
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userinfo = notification.userInfo
        let keyboardSize = userinfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue   // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if self.bottomTF.isEditing {    // Consider only the bottom text field
            self.toolbar?.isHidden = true
            self.navbar?.isHidden = true
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if self.bottomTF.isEditing {    // Consider only the bottom text field
            self.toolbar?.isHidden = false
            self.navbar?.isHidden = false
            view.frame.origin.y = 0
        }
        
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: UINavigationBar delegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    // MARK: Actions
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.allowsEditing = true
            pickerController.sourceType = source
            present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func takeAPicture(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .savedPhotosAlbum)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        // Clear text fields and put default values
        
        self.topTF.text = "TOP"
        modifiedTopTF = false
        self.bottomTF.text = "BOTTOM"
        modifiedBottomTF = false
        
        // Clear image view
        
        imageView.image = nil
        
        // Disable the Share button
        self.shareButton.isEnabled = false
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func share(_ sender: Any) {
        let memedImage: UIImage = generateMemedImage()
        let shareSheet = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareSheet.completionWithItemsHandler = { (_, completed, _, _) in
            
            // Save only if shared
            if completed {
                self.save(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        present(shareSheet, animated: true, completion: nil)
        
    }
    
    
    // MARK: Save
    
    func save(memedImage: UIImage) {
        
        // Create the meme
        
        let meme = Meme(topText: topTF.text!, bottomText: bottomTF.text!, originalImage: imageView.image!, memedImage: memedImage)
        
        // Add it to the memes array on the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
    }
    
    // MARK: UIImageImagePicker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            
            self.shareButton.isEnabled = true// Enable Share Button
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextField Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.topTF && !modifiedTopTF {
            self.topTF.text = ""
            modifiedTopTF = true
        }
        
        if textField == self.bottomTF && !modifiedBottomTF {
            self.bottomTF.text = ""
            modifiedBottomTF = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    // MARK: Generate a memed image

    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        self.toolbar?.isHidden = true
        self.navbar?.isHidden = true
        
        // Additionnal feature (if text field untouched, ignored)
        
        if !self.modifiedTopTF {
            self.topTF?.isHidden = true
        }
        
        if !self.modifiedBottomTF {
            self.bottomTF?.isHidden = true
        }
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.toolbar?.isHidden = false
        self.navbar?.isHidden = false
        
        // Show text fields
        self.topTF?.isHidden = false
        self.bottomTF?.isHidden = false
        
        return memedImage
    }


}
