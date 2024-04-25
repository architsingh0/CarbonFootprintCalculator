//
//  AppViewModel.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

class AppViewModel: ObservableObject {
    let auth = Auth.auth()
    let storage = Storage.storage()
    let db = Firestore.firestore()
    @Published var signedIn: Bool = false
    @Published var profileImageURL: URL?
    let dashboardViewModel = DashboardViewModel()

    var isSignedIn: Bool {
            return auth.currentUser != nil
        }

        init() {
            self.signedIn = isSignedIn
            fetchProfileImage()
            observeAuthChanges()
        }

        private func observeAuthChanges() {
            auth.addStateDidChangeListener { [weak self] (auth, user) in
                self?.signedIn = user != nil
                if let user = user {
                    self?.fetchProfileImage()
                    NotificationCenter.default.post(name: NSNotification.Name("UserDidChange"), object: nil)
                } else {
                    self?.profileImageURL = nil
                    NotificationCenter.default.post(name: NSNotification.Name("UserDidChange"), object: nil)
                }
            }
        }

        func signIn(email: String, password: String) {
            auth.signIn(withEmail: email, password: password)
        }

        func signUp(email: String, password: String, name: String, image: UIImage) {
            auth.createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self, error == nil, let user = result?.user else { return }

                self.uploadProfileImage(userId: user.uid, image: image) { imageUrl in
                    let userData = ["name": name, "email": email, "uid": user.uid, "profileImageUrl": imageUrl]
                    self.db.collection("users").document(user.uid).setData(userData) { error in
                        if error == nil {
                            self.signedIn = true
                        }
                    }
                }
            }
        }

    func uploadProfileImage(userId: String, image: UIImage, completion: @escaping (String) -> Void) {
        let storageRef = storage.reference().child("profileImages/\(userId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else { return }
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else { return }
                completion(downloadURL.absoluteString)
            }
        }
    }

    func signOut() {
        try? auth.signOut()
    }

    func fetchProfileImage() {
        guard let uid = auth.currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                if let urlString = data["profileImageUrl"] as? String, let url = URL(string: urlString) {
                    print(url)
                    self.profileImageURL = url
                }
            }
        }
    }
}
