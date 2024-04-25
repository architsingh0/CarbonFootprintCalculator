//
//  LoginView.swift
//  CarbonFootprintCalculator
//
//  Created by Archit Singh on 4/22/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    @State private var isSignIn = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    
    var body: some View {
        NavigationView {
            VStack {
                Text(isSignIn ? "Sign In" : "Register")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                if !isSignIn {
                    Button(action: {
                        self.showingImagePicker = true
                    }) {
                        VStack {
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                        ImagePicker(image: self.$inputImage)
                    }
                    
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    if isSignIn {
                        viewModel.signIn(email: email, password: password)
                    } else {
                        guard let inputImage = inputImage else { return }
                        viewModel.signUp(email: email, password: password, name: name, image: inputImage)
                    }
                }) {
                    Text(isSignIn ? "Sign In" : "Create Account")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Spacer()
                
                Button("Switch to \(isSignIn ? "Register" : "Sign In")") {
                    isSignIn.toggle()
                }
                .padding()
                
            }
            .padding()
            .navigationTitle("Welcome to Carbon Footprint Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


#Preview {
    LoginView()
}
