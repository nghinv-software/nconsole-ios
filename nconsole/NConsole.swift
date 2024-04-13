//
//  NConsole.swift
//  nconsole
//
//  Created by NghiNV on 03/04/2024.
//

import Foundation
import UIKit
import CommonCrypto


let _kDefaultUri = "ws://localhost:9090";

public class NConsole {
    private static var sharedInstance: NConsole = {
        return NConsole()
    }()
    
    public static var isEnable: Bool = false
    private static var listenLog: (([Any], LogType) -> Void)?
    
    private var _uri: String = _kDefaultUri
    private var _clientInfo: ClientInfo?
    private var _publicKey: String?
    private var _isSecure: Bool = true
    private var _socket: URLSessionWebSocketTask?
    private var _isConnected = false
    
    public static func setUri(_ uri: String?) {
        sharedInstance._uri = uri ?? _kDefaultUri
        sharedInstance._socket?.cancel()
        sharedInstance._socket = nil
        sharedInstance._isConnected = false
    }
    
    public static func setPublicKey(_ publicKey: String?) {
        sharedInstance._publicKey = publicKey
    }
    
    public static func setUseSecure(_ isSecure: Bool) {
        sharedInstance._isSecure = isSecure
    }
    
    public static func setClientInfo(_ clientInfo: ClientInfo) {
        sharedInstance._clientInfo = clientInfo
    }
    
    public static var uri: String {
        get {
            return sharedInstance._uri
        }
    }
    
    private func getUri(_ uri: String?) -> String {
        guard let uri = uri else {
            return "ws://localhost:9090"
        }
        
        var newUri = uri.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !newUri.hasPrefix("ws://") && !newUri.hasPrefix("wss://") {
            newUri = "ws://\(newUri)"
        }
        
        let uriParts = newUri.split(separator: ":")
        
        if uriParts.count == 3 {
            return newUri
        }
        
        if uriParts.count == 2 {
            let ipParts = uriParts[1].split(separator: ".")
            if ipParts.count == 4 {
                return "\(newUri):9090"
            }
            
            if uriParts[1] == "localhost" {
                return "\(newUri):9090"
            }
            
            return newUri
         }
        
        return newUri
    }
    
    private func connectWebSocket(_ data: String? = nil) {
        if _socket != nil { return }
        
        _socket?.cancel()
        
        guard let url = URL(string: getUri(_uri)) else { return }
        
        let session = URLSession(configuration: .default)
        _socket = session.webSocketTask(with: url)
        _socket?.resume()
        sendData(data)
    }
    
    private func isSocketConnected() -> Bool {
        if _socket == nil {
            return false
        }
        
        switch _socket!.state {
        case .running:
            return true
        case .suspended:
            return true
        case .canceling:
            return false
        case .completed:
            return false
        @unknown default:
            return false
        }
    }
    
    private func sendData(_ data: String? = nil) {
        if let data = data {
            let message = URLSessionWebSocketTask.Message.string(data)
            _socket?.send(message, completionHandler: { error in
                if error != nil {
                    // send message error
                }
            })
        }
    }
    
    private func genHexString(length: Int) -> String {
        let hex = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var output = ""
        
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<hex.count)
            let character = hex[hex.index(hex.startIndex, offsetBy: randomIndex)]
            output.append(character)
        }
        
        return output
    }
    
    public static func log(_ data: Any...) {
        sharedInstance.sendData(data: data, type: .log)
    }
    
    public static func info(_ data: Any...) {
        sharedInstance.sendData(data: data, type: .info)
    }
    
    public static func warn(_ data: Any...) {
        sharedInstance.sendData(data: data, type: .warn)
    }
    
    public static func error(_ data: Any...) {
        sharedInstance.sendData(data: data, type: .error)
    }
    
    public static func group(_ data: Any...) {
        sharedInstance.sendData(data: data, type: .group)
    }
    
    public static func groupCollapsed(_ data: Any...) {
        sharedInstance.sendData(data: data, type: .groupCollapsed)
    }
    
    public static func groupEnd(_ data: Any...) {
        sharedInstance.sendData(data: data, type: .groupEnd)
    }
    
    public static func clear(_ data: Any...) {
        sharedInstance.sendData(data: data, type: .clear)
    }
    
    private func sendData(data: [Any], type: LogType) {
        if !NConsole.isEnable {
            return
        }
        
        var isDebug = false
        #if DEBUG
            isDebug = true
        #endif
        
        if _clientInfo == nil {
            let device = UIDevice.current
            _clientInfo = ClientInfo(
                id: device.identifierForVendor?.uuidString ?? "",
                name: device.name,
                platform: "iOS",
                debug: isDebug,
                isSimulator: device.name.contains("Simulator"),
                version: device.systemVersion,
                buildVersion: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
                model: device.model,
                manufacturer: "Apple",
                os: "iOS",
                osVersion: device.systemVersion,
                language: "Swift"
            )
        }
                
        do {
            let payloadData = LogPayloadData(clientInfo: _clientInfo!, data: data)
            let dataJson = try JSONEncoder().encode(payloadData)
            guard let dataString = String(data: dataJson, encoding: .utf8) else {
                return
            }
            
            let currentTime = CLong(Date().timeIntervalSince1970)
            
            let dataRequest = LogRequestData(
                timestamp: currentTime,
                logType: type.rawValue,
                secure: _publicKey != nil,
                payload: encode(dataString),
                language: "swift"
            )
            
            let requestString = try JSONEncoder().encode(dataRequest)
            guard let dataRequestString = String(data: requestString, encoding: .utf8) else {
                return
            }
                
            let isConnected = isSocketConnected()
            if (isConnected) {
                sendData(dataRequestString)
            } else {
                connectWebSocket(dataRequestString)
            }
        } catch _ {
            // error
        }
    }
    
    private func encode(_ data: String) -> LogPayload {
        if _publicKey == nil || !_isSecure {
           return LogPayload(data: data)
       }
        
        let keyRaw = genHexString(length: 32)
        let ivRaw = genHexString(length: 16)
        
        let key = keyRaw.data(using: .utf8)!
        let iv = ivRaw.data(using: .utf8)!
        
        if let encryptedData = aesCBCEncrypt(clearData: data.data(using: .utf8)!,
                                                         key: key,
                                                         iv: iv) {
           let encryptedDataString = encryptedData.base64EncodedString()
           let keyEncode = encrypt(string: "\(keyRaw)\(ivRaw)", publicKey: _publicKey)
           return LogPayload(data: encryptedDataString, encryptionKey: keyEncode)
       }

       return LogPayload(data: data)
    }
    
    private func aesCBCEncrypt(clearData: Data, key: Data, iv: Data) -> Data? {
       let blockSize = kCCBlockSizeAES128
       let encryptedDataCount = clearData.count + blockSize
       var encryptedData = Data(count: encryptedDataCount)
       var encryptedDataLength: size_t = 0
       let status = key.withUnsafeBytes { keyBytes in
           iv.withUnsafeBytes { ivBytes in
               clearData.withUnsafeBytes { clearDataBytes in
                   encryptedData.withUnsafeMutableBytes { encryptedDataBytes in
                       CCCrypt(
                           CCOperation(kCCEncrypt),
                           CCAlgorithm(kCCAlgorithmAES),
                           CCOptions(kCCOptionPKCS7Padding),
                           keyBytes.baseAddress,
                           key.count,
                           ivBytes.baseAddress,
                           clearDataBytes.baseAddress,
                           clearData.count,
                           encryptedDataBytes.baseAddress,
                           encryptedDataBytes.count,
                           &encryptedDataLength
                       )
                   }
               }
           }
       }
       guard status == kCCSuccess else {
           return nil
       }
       encryptedData.removeSubrange(encryptedDataLength..<encryptedData.count)
       return encryptedData
    }
    
    private func encrypt(string: String, publicKey: String?) -> String? {
        guard let publicKey = publicKey else { return nil }

        let keyString = publicKey
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----\n", with: "")
            .replacingOccurrences(of: "\n-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        guard let data = Data(base64Encoded: keyString) else { return nil }

        var attributes: CFDictionary {
            return [kSecAttrKeyType         : kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass        : kSecAttrKeyClassPublic,
                    kSecAttrKeySizeInBits   : 2048,
                    kSecReturnPersistentRef : kCFBooleanTrue] as CFDictionary
        }

        var error: Unmanaged<CFError>? = nil
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            print(error.debugDescription)
            return nil
        }
        return encrypt(string: string, publicKey: secKey)
    }

    private func encrypt(string: String, publicKey: SecKey) -> String? {
        let buffer = [UInt8](string.utf8)

        var keySize   = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)

        guard SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else { return nil }
        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }
}

