//
//  SignUpVC.swift
//  InstagramCopy
//
//  Created by Stephan Dowless on 2/3/18.
//  Copyright © 2018 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var imageSelected = false
    
    let plusPhotoBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoBtn)
        plusPhotoBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        configureViewComponents()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
    }
    
    // MARK: - UIImagePickerController 
    
    /// function that handles selecting image from camera roll
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // selected image
        guard let profileImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        // set imageSelected to true
        imageSelected = true
        
        // configure plusPhotoBtn with selected image
        plusPhotoBtn.layer.cornerRadius = plusPhotoBtn.frame.width / 2
        plusPhotoBtn.layer.masksToBounds = true
        plusPhotoBtn.layer.borderColor = UIColor.black.cgColor
        plusPhotoBtn.layer.borderWidth = 2
        plusPhotoBtn.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Handlers
    
    @objc func handleSelectProfilePhoto() {
        
        // configure image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // present image picker
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
       
        // properties
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            // handle error
            if let error = error {
                print("Failed to create user with error: ", error.localizedDescription)
                return
            }
            
            // set profile image
            guard let profileImg = self.plusPhotoBtn.imageView?.image else { return }
            
            // upload data
            guard let uploadData = UIImageJPEGRepresentation(profileImg, 0.3) else { return }
            
            // place image in firebase storage
            let filename = NSUUID().uuidString
            Storage.storage().reference().child("profile_images").child(filename).putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                // handle error
                if let error = error {
                    print("Failed to upload image to Firebase Storage with error", error.localizedDescription)
                }
                
                // profile image url
                guard let profileImageURL = metadata?.downloadURL()?.absoluteString else { return }
                
                // user id
                guard let uid = user?.uid else { return }
                
                let dictionaryValues = ["name": fullName,
                                        "username": username,
                                        "profileImageUrl": profileImageURL]
                
                let values = [uid: dictionaryValues]
                
                // save user info to database
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
                    
                    // configure view controllers in maintabvc
                    mainTabVC.configureViewControllers()
                    
                    // dismiss login controller
                    self.dismiss(animated: true, completion: nil)
                    
                })
            })
        }
    }
    
    @objc func formValidation() {
        
        guard
            emailTextField.hasText,
            passwordTextField.hasText,
            fullNameTextField.hasText,
            usernameTextField.hasText,
            imageSelected == true else {
                signUpButton.isEnabled = false
                signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
                return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    func configureViewComponents() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, usernameTextField, passwordTextField, signUpButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
    }

}