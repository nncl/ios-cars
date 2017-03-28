//
//  Helper
//

import Foundation

class REST {
    static let basePath = "https://fiapcars.herokuapp.com/cars"
    
    static let configuration: URLSessionConfiguration = {
        
        let config = URLSessionConfiguration.default
        // URLSessionConfiguration.ephemeral Configuracao de sessao mais privada, ex: terminou? limpa tudo - MODO PRIVADO, apaga cookies, cache, etc...
        
        // URLSessionConfiguration.background(withIdentifier: "bg") // Sessao executada em background, QUANDO o app está em background // download de um rescurso mesmo que o app esteja fechado
        
        config.allowsCellularAccess = false // Não permite uso da rede cellular
        config.httpAdditionalHeaders = ["Content-Type" : "application/json"]
        config.timeoutIntervalForRequest = 30.0 // Se passar de 30 segundos informa que deu algum problema
        config.httpMaximumConnectionsPerHost = 4
        
        return config
    }()
    
    // static let session = URLSession.shared
    static let session = URLSession(configuration: configuration)
    
    // Recebe uma closure
    // Optional, caso nao retorne nada retorna nulo pra tratar no CarsTableVieController
    static func loadCars(onComplete: @escaping ([Car]?) -> Void) {
        
        // @escaping: acessa parâmetro que já "morreu", na verdade mantém ele lá ao término
        
        // Montar a URL
        guard let url = URL(string: basePath) else {
            // Cai fora se der erro antes de sair da função, mas antes avisa que não tem
            onComplete(nil)
            return
        }
        
        // GET
        session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                // Handle error
                onComplete(nil)
            } else {
                // Tratar resposta com response: ver se existe, verificar o status
                // guard pq a variável existe fora, se fosse if existira somente dentro; por isso dá um return
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil)
                    return
                }
                
                if response.statusCode == 200 {
                    // OK MLK
                    guard let data = data else {
                        onComplete(nil)
                        return
                    }
                    
                    // Parse data to JSON
                    let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [[String: Any]] // JSON no swift é um dicionário ou array de dicionários
                    
                    var cars: [Car] = []
                    for item in json {
                        // IF LET caso não exista ou seja null; existem bibliotecas que fazem parse de JSON
                        let brand = item["brand"] as! String
                        let name = item["name"] as! String
                        let price = item["price"] as! Double
                        let gasType = GasType(rawValue: item["gasType"] as! Int)! // vida loka
                        let id = item["id"] as! String
                        
                        let car = Car(brand: brand, name: name, price: price, gasType: gasType)
                        car.id = id
                        
                        cars.append(car)
                    }
                    
                    onComplete(cars)
                    
                    
                } else {
                    onComplete(nil)
                }
            }
        }.resume() // exec task
        
        // onComplete(nil) // Volta pra lá
    }
    
    // POST; não vamos fazer tudo a mesma coisa, mas na pratica temos que..
    static func saveCar(car: Car, onComplete: @escaping (Bool) -> Void) {
        guard let url = URL(string: basePath) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // request.addValue("application/json", forHTTPHeaderField: "Content-Type") - já temos isso definido na session
        
        let carDict: [String: Any] = [
            "brand": car.brand,
            "name": car.name,
            "price": car.price,
            "gasType": car.gasType.rawValue
        ]
        
        let json = try! JSONSerialization.data(withJSONObject: carDict, options: JSONSerialization.WritingOptions()) // queremos um json a partir de um object
        
        // Add body na requisição
        request.httpBody = json
        
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil {
                guard let response = response as? HTTPURLResponse else {return}
                
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    
                    let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [String: Any]
                    let id = json["id"] as! String
                    car.id = id
                    onComplete(true)
                }
            }
            }.resume()
    }
    
    // PATCH
    static func updateCar(car: Car, onComplete: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(basePath)/\(car.id!)" ) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        let carDict: [String: Any] = [
            "brand": car.brand,
            "name": car.name,
            "price": car.price,
            "gasType": car.gasType.rawValue
        ]
        
        let json = try! JSONSerialization.data(withJSONObject: carDict, options: JSONSerialization.WritingOptions()) // queremos um json a partir de um object
        
        // Add body na requisição
        request.httpBody = json
        
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil {
                guard let response = response as? HTTPURLResponse else {return}
                
                if response.statusCode == 200 {
                    onComplete(true)
                }
            }
            }.resume()
    }
    
    // DELETE
    static func deleteCar(car: Car, onComplete: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(basePath)/\(car.id!)" ) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil {
                guard let response = response as? HTTPURLResponse else {return}
                
                if response.statusCode == 200 {
                    onComplete(true)
                }
            }
        }.resume()
    }
}















