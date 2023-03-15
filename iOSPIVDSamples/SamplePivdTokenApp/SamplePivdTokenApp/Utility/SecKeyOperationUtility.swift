//
//  SecKeyOperationUtility.swift
//  SamplePivdTokenApp
//
//  Copyright 2023 VMware, Inc.
//  SPDX-License-Identifier: BSD-2-Clause
//

import Foundation
import Security

/// This class holds api to communicate with keychain.
final class SecKeyOperationUtility {

    /// get common name for SecIdentity
    /// - Parameter identity: SecIdentity instance
    /// - Returns: certificate common name.
    static func commonNameForIdentity(identity: SecIdentity) -> String? {
        var secCert: SecCertificate? = nil
        var status = SecIdentityCopyCertificate(identity, &secCert)
        guard let cert = secCert else {
            print("[Consumer] Error retrieving public certificate : \(status)")
            return nil
        }

        var commonName: CFString? = nil
        status = SecCertificateCopyCommonName(cert, &commonName)
        return commonName as String?
    }

    /// get Public and Private keys from the SecIdentity instance.
    /// - Parameter identity: SecIdentity instance
    /// - Returns: Public and Private keys
    static func keysFromIdentity(identity: SecIdentity) -> (publicKey: SecKey?, privateKey: SecKey?) {

        // Get public key to encrypt and private key to decrypt.
        var secureKey: SecKey? = nil
        var status = SecIdentityCopyPrivateKey(identity, &secureKey)
        guard status == noErr,
              let privateKey = secureKey else {
           print("[Consumer] Error retrieving private key : \(status)")
            return (nil, nil)
        }

        var secCert: SecCertificate? = nil
        status = SecIdentityCopyCertificate(identity, &secCert)
        guard status == noErr,
              let cert = secCert,
              let publicKey = SecCertificateCopyKey(cert) else {
            print("[Consumer] retrieving private key : \(status)")
            return (nil, nil)
        }
        return(publicKey, privateKey)
    }

    /// Encrypt API
    /// - Parameters:
    ///   - value: Data to be encrypted
    ///   - publicKey: Public key
    ///   - algorithm: Algorithm to encrypt.
    /// - Returns: Encrypted data.
    static func encrypt(value: Data, publicKey: SecKey, algorithm: SecKeyAlgorithm) -> Data? {
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            return nil
        }

        var errorRef: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, value as CFData, &errorRef) else {
            print("[SecKeyOperation] error encrypting: \(String(describing: errorRef?.takeRetainedValue()))")
            return nil
        }
        return encryptedData as Data
    }

    /// Decrypt API
    /// - Parameters:
    ///   - encrypted: Encrypted Data
    ///   - privateKey: Private key
    ///   - algorithm: Algorithm used for encryption.
    /// - Returns: Decrypted data.
    static func decrypt(encrypted: Data, privateKey: SecKey, algorithm: SecKeyAlgorithm) throws -> Data? {
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
            return nil
        }

        var errorRef: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algorithm, encrypted as CFData, &errorRef) as Data? else {
            if let cferror: CFError = errorRef?.takeUnretainedValue() {
                print("[SecKeyOperation] error decrypting: \(String(describing: cferror))")
                throw NSError(domain: CFErrorGetDomain(cferror) as String, code: CFErrorGetCode(cferror), userInfo: [NSLocalizedDescriptionKey : cferror.localizedDescription])
            }
            return nil
        }

        return decryptedData
    }

    /// Sign any information
    /// - Parameters:
    ///   - dataToSign: Data to sign using private key and algorithm
    ///   - privateKey: private key
    ///   - algorithm: Algorithm to be used.
    /// - Returns: Signed data.
    static func sign(dataToSign: Data, privateKey: SecKey, algorithm: SecKeyAlgorithm) throws -> Data? {
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
            return nil
        }

        var errorRef: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, algorithm, dataToSign as CFData, &errorRef) as Data? else {
            if let cferror: CFError = errorRef?.takeUnretainedValue() {
                print("[SecKeyOperation] error signing: \(String(describing: cferror))")
                throw NSError(domain: CFErrorGetDomain(cferror) as String, code: CFErrorGetCode(cferror), userInfo: [NSLocalizedDescriptionKey : cferror.localizedDescription])
            }
            return nil
        }
        return signature as Data
    }

    /// Verify signed information
    /// - Parameters:
    ///   - signedData: The data over which sig is being verified, typically the digest of the actual data.
    ///   - signature: The signature to verify
    ///   - publicKey: public key
    ///   - algorithm: algorithm
    /// - Returns: returns if signed data is verified.
    static func verify(signedData: Data, signature: Data, publicKey: SecKey, algorithm: SecKeyAlgorithm) -> Bool {

        guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm) else {
            return false
        }

        var errorRef: Unmanaged<CFError>?
        guard SecKeyVerifySignature(publicKey,
                                    algorithm,
                                    signedData as CFData,
                                    signature as CFData,
                                    &errorRef)
        else {
            print("[SecKeyOperation] error verifying: \(String(describing: errorRef?.takeRetainedValue() as Error?))")
            return false
        }

        return true
    }
}
