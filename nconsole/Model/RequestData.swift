//
//  RequestData.swift
//  nconsole
//
//  Created by NghiNV on 12/04/2024.
//

import Foundation

struct LogRequestData: Encodable {
    var timestamp: CLong
    var logType: String
    var secure: Bool
    var payload: LogPayload
    var language: String
}

struct LogPayload: Encodable {
    var data: String
    var encryptionKey: String?
}

struct LogPayloadData: Encodable {
    let clientInfo: ClientInfo
    let data: [Any]
    
    private enum CodingKeys: String, CodingKey {
        case clientInfo
        case data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(clientInfo, forKey: .clientInfo)

        var dataContainer = container.nestedUnkeyedContainer(forKey: .data)
        let res = data.map { element -> Any in
            if let dict = toDict(object: element) {
                return dict
            }
            return element
        }
        
        if res.isEmpty {
            for item in data {
                if let encodable = item as? Encodable {
                    try dataContainer.encode(AnyEncodable(encodable))
                }
            }
        } else {
            for item in res {
                if let itemDict = item as? [String: Any], let output = convertDictionaryToJSON(itemDict) {
                    try dataContainer.encode(output)
                } else {
                    if let encodable = item as? Encodable {
                        try dataContainer.encode(AnyEncodable(encodable))
                    }
                }
            }
        }
    }
    
    private func changeAnyToJson(dict: [String: Any]) -> String {
       if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
           let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)
           return jsonString ?? ""
       } else {
           return ""
       }
   }

    private func convertDictionaryToJSON(_ dictionary: [String: Any]) -> String? {
      guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
         return nil
      }


      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
         return nil
      }


      return jsonString
   }

    private func toDict<T>(object: T) -> [String:Any]? {
       var dict = [String:Any]()
       var hasKey: Bool = false
       let otherSelf = Mirror(reflecting: object)
       for child in otherSelf.children {
           if let key = child.label {
               dict[key] = child.value
               hasKey = true
           }
       }
       if !hasKey {
           return nil
       }
       
       return dict
   }
}

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }


    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
