import Foundation

class AuthService {
    
    private let baseURL = "https://hapi.cegeplabs.qc.ca/smartpantry"


    func register(requestBody: RegisterRequest) async throws {
        guard let url = URL(string: "\(baseURL)/register") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        //pas besoin du data ici donc juste _
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        //s'assurer du succès, mais succès pas juste 200,
        // peut-être aussi genre 201 (created, frequent pour register)
        //ref: https://stackoverflow.com/questions/26563688/get-http-status-using-swift
        //ref: https://codesignal.com/learn/courses/basics-of-http-requests-with-swift/lessons/making-get-requests-and-handling-responses-in-swift
        //à 2:25 de la video de deuxième référence
        //ref: https://www.youtube.com/watch?v=H5s_rjQa2hY
        //à 3:55 troisième ref, semble être un bon standard pour ce guard de http status

        //faque pour register, on veut juste un succès peu importe le code spécifique (peut-être 200 pour OK, mais
        // plus souvent pour un POST c'est 201 qui veut dire created si tu crée une ressource)
        // donc m'a utiliser le range
        //mais plus tard pour un GET ou login (POST aussi mais que sa prend une réponse genre le token)
        // m'a vraiment vérifier que c'est 200 et qu'on a obtenu la réponse
        //car je voudrais pas genre 204 (succès mais pas de body donc pas de contenu de retourné)

        //ps: login est un POST, mais code devrait être 200
        //un POST est en général 200 si POST sans crée de ressource, mais 201 si POST crée
        // une ressource genre nouveau user

        //ref http code: https://www.youtube.com/watch?v=nb0xQUcxVj4
    }
    
    func login(requestBody: LoginRequest) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        return loginResponse
    }
    
    func getMe(token: String) async throws -> MeResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let meResponse = try JSONDecoder().decode(MeResponse.self, from: data)
        
        return meResponse
    }
    
}
