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

        // Convert clientInfo to Data
        try container.encode(clientInfo, forKey: .clientInfo)

        // Convert data to Data
        var dataContainer = container.nestedUnkeyedContainer(forKey: .data)
        for item in data {
//            let dataJson = try JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
            
            if let encodable = item as? Encodable {
                try dataContainer.encode(AnyEncodable(encodable))
            }
        }
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
