//
//  CharacterRetriever.swift
//  Rick and Morty
//
//  Created by itay gervash on 02/03/2022.
//

import Foundation
import Alamofire

class CharacterRetriever {
    
    static let shared = CharacterRetriever()
    
    static let baseURL: String = "https://rickandmortyapi.com/api/character"
    
    func getCharacters(url: String = baseURL, completion: @escaping ((_ success: Bool, _ result: [Character]?, _ nextPageURL: String?, _ error: AFError?) -> Void)) {

            let request = AF.request(url)

            request.responseDecodable(of: CharacterData.self) { response in
                
                if let error = response.error {
                        completion(false, nil, nil, error)
                } else {
                    if let retrievedCharacters = response.value?.results {
                        let nextPageURL = response.value?.info?.next
                            completion(true, retrievedCharacters, nextPageURL, nil)
                    }
                }
            }
    }
    
    func getCharacters(by name: String, completion: @escaping ((_ success: Bool, _ result: [Character]?, _ nextPageURL: String?, _ error: AFError?) -> Void)) {
            
            let url = CharacterRetriever.baseURL + "/?name=" + name.replacingOccurrences(of: " ", with: "+")
            let request = AF.request(url)
            request.responseDecodable(of: CharacterData.self) { response in
                
                if let error = response.error {
                        completion(false, nil, nil, error)
                } else {
                    if let retrievedCharacters = response.value?.results {
                        let nextPageURL = response.value?.info?.next
                            completion(true, retrievedCharacters, nextPageURL, nil)
                    }
                }
            }
    }
    
    private var loadedImages = [String: UIImage]()
    private var runningRequests = [UUID: DataRequest]()
    
    func getCharacterImage(of url: String, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        if let image = loadedImages[url] {
          completion(.success(image))
          return nil
        }

        let uuid = UUID()
        let request = AF.request(url)
        
        request.response { response in
                
            defer { self.runningRequests.removeValue(forKey: uuid) }
                
                guard let imageData = response.value as? Data,
                      let image = UIImage(data: imageData, scale: 1) else {
                    completion(.failure(CharacterRetrieverError.badResponse))
                    return
                }
                
                completion(.success(image))
            }
        
        runningRequests[uuid] = request
        return uuid
    }
    
    func cancelRequest(_ uuid: UUID) {
      runningRequests[uuid]?.cancel()
      runningRequests.removeValue(forKey: uuid)
    }
    
    func getEpisodes(by idList: [Int], completion: @escaping ((_ success: Bool, _ result: [Episode]?, _ error: AFError?) -> Void)) {
            
        var baseEpisodeURL: String = "https://rickandmortyapi.com/api/episode/"
        
        //add every episode id separated by come to the request
        for id in idList {
            baseEpisodeURL.append("\(id),")
        }
        //delete last comma
        baseEpisodeURL = String(baseEpisodeURL.dropLast())
    
        DispatchQueue.global(qos: .background).async {
            
            let request = AF.request(baseEpisodeURL)
            
            //if we request only 1 episode - we receive a single Episode object, but when requst more we get an array.
            if idList.count > 1 {
                request.responseDecodable(of: [Episode].self) { response in
                    
                    if let error = response.error {
                        
                        DispatchQueue.main.async {
                            completion(false, nil, error)
                        }
                    } else {
                        if let retrievedEpisodes = response.value {
                            DispatchQueue.main.async {
                                completion(true, retrievedEpisodes, nil)
                            }
                        }
                    }
                }
            } else if idList.count == 1 {
                request.responseDecodable(of: Episode.self) { response in
                    
                    if let error = response.error {
                        
                        DispatchQueue.main.async {
                            completion(false, nil, error)
                        }
                    } else {
                        if let retrievedEpisodes = response.value {
                            DispatchQueue.main.async {
                                completion(true, [retrievedEpisodes], nil)
                            }
                        }
                    }
                    


                }
            }

        }
        
    }
    
    func getCharacterNames(from episode: Episode, completion: @escaping ((_ success: Bool, _ result: [String]?, _ error: AFError?) -> Void)) {
        
        DispatchQueue.global(qos: .background).async {
            
            var baseCharacterURL: String = "https://rickandmortyapi.com/api/character/"
            let characterIDs = episode.numericCharacterIDList()
            
            //add every episode id separated by come to the request
            for id in characterIDs {
                baseCharacterURL.append("\(id),")
            }
            //delete last comma
            baseCharacterURL = String(baseCharacterURL.dropLast())
            
            let request = AF.request(baseCharacterURL)
            
            request.responseDecodable(of: [Character].self) { response in
                
                if let error = response.error {
                    DispatchQueue.main.async {
                        completion(false, nil, error)
                    }
                } else {
                    if let retrievedCharacters = response.value {
                        let names = retrievedCharacters.map { $0.name }
                        DispatchQueue.main.async {
                            completion(true, names, nil)
                        }
                    }
                }
                
            }
        }
    }
    
    
}
