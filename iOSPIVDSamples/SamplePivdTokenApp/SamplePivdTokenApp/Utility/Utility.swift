//
//  CertificateUtility.swift
//  SampleDCUsageApp

import Foundation
import UIKit

//MARK:- Constants
struct Constants {
    static let errorTitle = "Error"
    static let successTitle = "Success"
    static let failureTitle = "Failed"
    static let emptyIdentityTitle = "Select atleast one certificate to perform the operation."
    static let authenticationSupportMessage = "As part of this demo we support single certificate for authentication to demonstrate retries. Please ensure a valid certificate with authentication capablity is selected"
    static let enterPlainTextTitle = "Enter plain text."
    static let decryptUserMessage = "Entered text will be encrypted and decrypted back for verification using selected key(s)"
    static let signUserMessage = "Entered text will be Signed and Verified using selected key(s)"
    static let authFailureMessage = "Please ensure a valid certificate with authentication capablity is selected"
    static let authSuccessMessage = "Authenticated and URL is loaded successfully using selected key(s)"
    static let noIdentityFound = "CryptoTokenKit Keys not found"
    static let okMessage = "Ok"
    static let accessSuspendedTitle = "Access Suspended"
    static let openPIVD = "Open PIV-D"

    #warning("Fill in valid URL for IA")
    static let iaURl = "https://yourcompany.com:port/ia"
}

public extension Data {
    static func randomData(count: Int) -> Data {
        var bytes = [UInt8](repeating: 0x00, count: count)
        let _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        let randData = Data(bytes: bytes, count: count)
        bytes.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> Void  in
            memset(pointer.baseAddress, 0x00, count)
        }
        return randData
    }
}
