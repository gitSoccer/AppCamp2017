//
//  MapMarkerDetailViewController.swift
//  Cache Me If You Can
//
//  Created by “Camp on 6/22/17.
//  Copyright © 2017 Ethan Rosenfeld. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase

class MapMarkerDetailViewController: UIViewController, UITextViewDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var instructions: UITextView!
    var myImg: UIImageView!
    
    var ref: DatabaseReference!
    var location: CLLocation?
    var desc = ""
    var ins = ""
    var placesCreated: Int = 0
    var imageStr = ""
    let formatter : DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    
    @IBAction func submitPressed(_ sender: UIButton)
    {
        placesCreated += 1
        desc = self.descriptionField.text
        ins = self.instructions.text
        let lat = location?.coordinate.latitude
        let lon = location?.coordinate.longitude
        ref.child("users").child(MyVariables.username).setValue([
            "createdPlaces": placesCreated
            ])
        ref.child("locations").child(MyVariables.username + " " + String(placesCreated)).setValue([
            "user": MyVariables.username,
            "timeAccessed": formatter.string(from: Date()),
            "description": desc, //description
            "instructions": ins, //instructions
            "lat": Double(lat ?? 0),
            "lon": Double(lon ?? 0),
            "title": MyVariables.username + " " + String(placesCreated),
            "image": imageStr
            ])
    }
    func setPlace(text: String, textView: UITextView)
    {
        textView.text = text
    }
    @IBAction func takePicture(_ sender: UIButton)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            let ethanBreaksThings = ImageManipulation.prepareImage(image: pickedImage, newWidth: (50))
            picker.dismiss(animated: true, completion: nil)
            imageStr = encode(image: ethanBreaksThings)
        }
    }
    func encode(image: UIImage) -> String
    {
        let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
        let string = imageData.base64EncodedString(options: .lineLength64Characters)
        return string
    }
    func decode(data: String) -> UIImage
    {
        let dataDecoded : Data = Data(base64Encoded: data, options: .ignoreUnknownCharacters)!
        let decodedImage:UIImage = UIImage(data: dataDecoded as Data)!
        return decodedImage
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.name.text! = ""
        setPlace(text: "Enter a description of your cache...", textView: descriptionField)
        setPlace(text: "Enter any special instructions...", textView: instructions)
        submitButton.layer.cornerRadius = 8;
        submitButton.layer.masksToBounds = true;
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "DamascusBold", size: 30)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        ref = Database.database().reference()
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let userDict = snapshot.value as? NSDictionary
            for userName in (userDict?.allKeys)!
            {
                //let userName = userDict?[x] as! String
                if userName as! String == MyVariables.username
                {
                    let user = userDict?[userName] as! NSDictionary
                    let places = user.value(forKey: "createdPlaces")
                    
                    if places != nil
                    {
                        self.placesCreated = places as! Int
                    }
                    else{
                        self.ref.child("users").setValue(["createdPlaces": self.placesCreated])
                    }
                }
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
