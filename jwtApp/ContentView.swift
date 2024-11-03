//
//  ContentView.swift
//  jwtApp
//
//  Created by Németh Bence on 2024. 11. 03..
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Bejelentkezés")
                .font(.largeTitle)
            
            TextField("Felhasználónév", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Jelszó", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Bejelentkezés") {
                viewModel.handleLogin()
            }
            .padding()
            
            if viewModel.token != "" {
                VStack(spacing: 15) {
                    Text("Védett végpont")
                        .font(.headline)
                    
                    Button("Végpont lekérdezés") {
                        viewModel.fetchData()
                    }
                    
                    if !viewModel.data.isEmpty {
                        List(viewModel.data, id: \.id) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("\(item.price)")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Hiba"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
