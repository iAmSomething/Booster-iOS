//
//  StatusService.swift
//  Booster
//
//  Created by 노한솔 on 2020/07/15.
//  Copyright © 2020 kimtaehoon. All rights reserved.
//

import Foundation
import Alamofire

struct StatusService {
  static let shared = StatusService()
  
  func getStatus(completion: @escaping (NetworkResult<Any>) -> Void) {
    
    let header: HTTPHeaders = ["token" : UserDefaults.standard.string(forKey: "token")!]
    
    let dataRequest = Alamofire.request(APIConstraints.progressRequest+"/list", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header)
    
    dataRequest.responseData { dataResponse in
      switch dataResponse.result {
      case .success :
        guard let statusCode = dataResponse.response?.statusCode else { return }
        guard let value = dataResponse.result.value else { return }
        var networkResult: NetworkResult<Any>?
        
        switch statusCode {
        case 200:
          let decoder = JSONDecoder()
          guard let decodedData = try? decoder.decode(StatusData.self, from: value) else {return networkResult = .pathErr}
          if decodedData.status == 200 {
            networkResult = .success(decodedData.data)
          }
          else if decodedData.status == 403 {
            networkResult = .requestErr(decodedData.message)
          }
          else {
            networkResult = .serverErr
          }
        case 400:
          networkResult = .pathErr
        case 500: networkResult = .serverErr
        default: networkResult = .networkFail
        }
        completion(networkResult!)
      case .failure : completion(.networkFail)
      }
    }
  }
}
