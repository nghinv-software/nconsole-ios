//
//  CryptoError.swift
//  nconsole
//
//  Created by NghiNV on 13/04/2024.
//

import CommonCrypto

enum CryptoError: Error {
    case encryptionFailed(CCStatus)
}
