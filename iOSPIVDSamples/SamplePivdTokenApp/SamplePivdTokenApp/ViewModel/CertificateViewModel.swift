//
//  CertificateViewModel.swift
//  SamplePivdTokenApp
//
//  Copyright 2023 VMware, Inc.
//  SPDX-License-Identifier: BSD-2-Clause
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
