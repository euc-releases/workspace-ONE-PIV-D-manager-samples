//
//  WelcomeViewController.swift
//  SamplePivdTokenApp
//
//  Copyright (c) 2025 Omnissa, LLC. All rights reserved.
//  This product is protected by copyright and intellectual property laws in the
//  United States and other countries as well as by international treaties.
//  -- Omnissa Public
//

import UIKit

/// This view controller provides a onboarding view to issue CTK certificates.
class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeMessageLabel: UILabel!
    @IBOutlet weak var requestKeysBtn: UIButton!

    private var viewModel: CertificateListingViewModel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.welcomeMessageLabel.text = "This app demonstrates access to certificates through CryptoTokenKit (CTK) and Persistent Device Token extensions. \n\nTap Request Access to send a CTK Consumer request. The request will be received by PIV-D Manager or another CTK Provider on this device and you will be prompted to allow access."

        self.requestKeysBtn.layer.cornerRadius = 5
        self.requestKeysBtn.clipsToBounds = true

        // Do any additional setup after loading the view.
    }

    // MARK: - Button Actions
    @IBAction func requestBtnAction(_ sender: Any) {
        viewModel = CertificateListingViewModel()
        viewModel?.fetchCertificates {
            DispatchQueue.main.async {
                guard (self.viewModel?.allIdentities.count ?? 0) > 0 else {
                    self.presentSimpleAlert(title: Constants.errorTitle, message: Constants.noIdentityFound)
                    return
                }
                self.performSegue(withIdentifier: "showListView", sender: self)
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showListView" {
            if let controller = segue.destination as? CertificateListViewController {
                controller.viewModel = self.viewModel
            }
        }
    }
}
