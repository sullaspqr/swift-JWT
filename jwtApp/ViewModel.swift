//
//  ViewModel.swift
//  jwtApp
//
//  Created by Németh Bence on 2024. 11. 03..
//

import SwiftUI
import Combine

struct Item: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double
}

class ViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var token = ""
    @Published var data: [Item] = []
    @Published var showAlert = false
    var errorMessage = ""
    
    func handleLogin() {
        guard let url = URL(string: "https://jwt.sulla.hu/login") else { return }
        let loginData = ["username": username, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(loginData)
        } catch {
            showAlert("Hitelesítés sikertelen: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert("Hitelesítés sikertelen: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert("Hiba: Nincs válasz")
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode([String: String].self, from: data)
                DispatchQueue.main.async {
                    self.token = response["token"] ?? ""
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert("Hitelesítés sikertelen: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func fetchData() {
        guard let url = URL(string: "https://jwt.sulla.hu/termekek") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert("Adatok lekérése sikertelen: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert("Hiba: Nincs válasz")
                }
                return
            }
            
            do {
                let items = try JSONDecoder().decode([Item].self, from: data)
                DispatchQueue.main.async {
                    self.data = items
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert("Adatok lekérése sikertelen: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func showAlert(_ message: String) {
        errorMessage = message
        showAlert = true
    }
}
