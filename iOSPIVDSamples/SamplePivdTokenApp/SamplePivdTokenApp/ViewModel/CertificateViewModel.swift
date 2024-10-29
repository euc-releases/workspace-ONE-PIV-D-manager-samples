//
//  CertificateViewModel.swift
//  SamplePivdTokenApp
//
//  Copyright (c) 2025 Omnissa, LLC. All rights reserved.
//  This product is protected by copyright and intellectual property laws in the
//  United States and other countries as well as by international treaties.
//  -- Omnissa Public
//

import Foundation
import UIKit

public class CertificateViewModel: NSObject {
    private let certObject: CertificateObject

    init(certificate: CertificateObject) {
        self.certObject = certificate
    }

    public var certificateCommonName: String {
        return self.certObject.commonName ?? ""
    }
}
