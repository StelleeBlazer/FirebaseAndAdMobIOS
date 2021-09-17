//
//  ViewController.swift
//  Firebase and Admob
//
//  Created by Mac n Cheese on 18/07/21.
//

import UIKit
import Firebase
import GoogleMobileAds 

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tfNamaMahasiswa: UITextField!
    @IBOutlet weak var tblMahasiswa: UITableView!
    @IBOutlet weak var tfJurusan: UITextField!
    @IBOutlet weak var bannerAdmob: GADBannerView!
    
    var databaseReference = DatabaseReference()
    var mahasiswa = [Mahasiswa]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tblMahasiswa.delegate = self
        tblMahasiswa.dataSource = self
        
        databaseReference = Database.database().reference().child("data-mahasiswa")
        reloadData()
        
        bannerAdmob.adUnitID = "ca-app-pub-7561338621110802/4800240540"
        bannerAdmob.rootViewController =  self
        bannerAdmob.load(GADRequest())
    }
    
    func reloadData(){
        
        databaseReference.observe(DataEventType.value) { (DataSnapshot) in
            
            if DataSnapshot.childrenCount > 0{
                
                self.mahasiswa.removeAll()
                
                for data in DataSnapshot.children.allObjects as! [DataSnapshot]{
                    
                    let dataMahasiswa = data.value as! [String : String]
                    let id = dataMahasiswa["id"]
                    let nama = dataMahasiswa["nama"]
                    let jurusan = dataMahasiswa["jurusan"]
                    
                    let mhs = Mahasiswa(id: id!, nama: nama!, jurusan: jurusan!)
                    self.mahasiswa.append(mhs)
                    self.tblMahasiswa.reloadData()
                }
            }
        }
    }

    
    @IBAction func btnSave(_ sender: UIButton) {
        
        let nama = tfNamaMahasiswa.text
        let jurusan = tfJurusan.text
        
        if nama?.count == 0 || jurusan?.count == 0 {
            showAlert()
        }
        else{
            let key = databaseReference.childByAutoId().key
            
            let param = ["id" : key,
                         "nama" : nama,
                         "jurusan" : jurusan]
            
            databaseReference.child(key!).setValue(param)
            
            tfNamaMahasiswa.text = ""
            tfJurusan.text = ""
            tfNamaMahasiswa.becomeFirstResponder()
        }
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Info", message: "Tidak Boleh Kosong", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mahasiswa.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMahasiswa")
        
        cell?.textLabel?.text = mahasiswa[indexPath.row].nama
        cell?.detailTextLabel?.text = mahasiswa[indexPath.row].jurusan
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataMahasiswa = mahasiswa[indexPath.row]
        
        let alert = UIAlertController(title: "Action", message: "Update or Delete", preferredStyle: .alert)
        
        let update = UIAlertAction(title: "Update", style: .default) { (UIAlertAction) in
            
            let id = dataMahasiswa.id
            let nama = alert.textFields![0].text
            let jurusan = alert.textFields![1].text
            
            let param = ["id" : id,
                          "nama" : nama,
                          "jurusan" : jurusan]
            
            self.databaseReference.child(id!).setValue(param)
        }
        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) in
            
            self.databaseReference.child(dataMahasiswa.id!).removeValue()
            self.mahasiswa.remove(at: indexPath.row)
            self.tblMahasiswa.reloadData()
        }
        
        alert.addTextField { (tfNama) in
            tfNama.text = dataMahasiswa.nama
        }
        
        alert.addTextField { (tfJurusan) in
            tfJurusan.text = dataMahasiswa.jurusan
        }
        
        alert.addAction(update)
        alert.addAction(delete)
        
        present(alert, animated: true, completion: nil)
        
    }
}

