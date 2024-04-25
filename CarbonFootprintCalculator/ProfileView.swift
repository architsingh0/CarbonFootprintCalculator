//
//  ProfileView.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel

    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    @State private var showingAlert = false
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""

    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                Button("Change Profile Picture") {
                    showingImagePicker = true
                }
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                }

                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }

                TextField("Name", text: $name)
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                Button("Update Profile") {
                    updateProfile()
                }
            }
            Section {
                Button("Sign Out") {
                    showingAlert = true
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Sign Out"),
                        message: Text("Are you sure?"),
                        primaryButton: .destructive(Text("Sign Out")) {
                            viewModel.signOut()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Profile")
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
        viewModel.uploadProfileImage(userId: Auth.auth().currentUser!.uid, image: inputImage) { url in
            viewModel.profileImageURL = URL(string: url)
        }
    }

    private func updateProfile() {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users").document(user.uid).updateData([
                "name": name,
                "email": email,
                "profileImageUrl": viewModel.profileImageURL?.absoluteString ?? ""
            ]) {error in
                if let error = error {
                    print("Error updating user: \(error.localizedDescription)")
                } else {
                    print("User updated")
                }
            }
        }
    }
}



#Preview {
    ProfileView()
}
