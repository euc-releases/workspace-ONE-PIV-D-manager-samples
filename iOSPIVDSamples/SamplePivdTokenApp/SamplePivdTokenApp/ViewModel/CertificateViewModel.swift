//
//  CertificateViewModel.swift
//  SamplePivdTokenApp

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
