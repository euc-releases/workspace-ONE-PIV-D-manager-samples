//
//  CertificateObject.swift
//  SamplePivdTokenApp
//
//  Copyright 2023 VMware, Inc.
//  SPDX-License-Identifier: BSD-2-Clause
//

import Foundation

final class CertificateObject {

    /// Provides the certificate common name.
    var commonName : String? {
        guard let cert = self.certificate else {
            return ""
        }

        var cfName: CFString?
        SecCertificateCopyCommonName(cert, &cfName)
        return cfName as String?
    }

    /// certificate data.
    var certData: Data?

    /// x509 certificate detail.
    var certificate: SecCertificate?

    init(certificateData: Data) {
        self.certificate = SecCertificateCreateWithData(kCFAllocatorDefault, certificateData as CFData)
        self.certData = certificateData
    }
}
