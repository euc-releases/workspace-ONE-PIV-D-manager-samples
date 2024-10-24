//
//  CertificateListViewController.swift
//  SamplePivdTokenApp
//
//  Copyright (c) 2025 Omnissa, LLC. All rights reserved.
//  This product is protected by copyright and intellectual property laws in the
//  United States and other countries as well as by international treaties.
//  -- Omnissa Public
//

import UIKit
import CryptoTokenKit

class CertificateListViewController: UIViewController {
    var credential:URLCredential?

    @IBOutlet weak var tableView: UITableView!

    var viewModel: CertificateListingViewModel? = nil

    private var dataSource: [CertificateObject] = []

    private var enableWebView: Bool = true
    private var requestOption: RequestOption = .wkwebview

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableView.automaticDimension
        setupBarButtonItems()
        self.viewModel?.cleanupSelectedIdentities()
        self.viewModel?.updateSelectedIdentities(dataSourceIndex: 0)
        tableView.reloadData()
    }

    //MARK:- Bar button actions
    @objc func encryptAndDecrypt() {
        guard viewModel?.selectedIdentities.count ?? 0 > 0 else {
            self.presentSimpleAlert(title: Constants.errorTitle, message: Constants.emptyIdentityTitle)
            return
        }
        let alert = UIAlertController(title: Constants.enterPlainTextTitle, message: Constants.decryptUserMessage, preferredStyle: .alert)
        alert.addTextField { (text) in }
        alert.addAction(UIAlertAction(title: Constants.okMessage, style: .default, handler: { (action) in
            if let text = alert.textFields?.first?.text {
                self.performOperation(operation: .encryptAndDecrypt, message: text)
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    @objc func signAndVerifyCert() {
        guard viewModel?.selectedIdentities.count ?? 0 > 0 else {
            self.presentSimpleAlert(title: Constants.errorTitle, message: Constants.emptyIdentityTitle)
            return
        }
        let alert = UIAlertController(title: Constants.enterPlainTextTitle, message: Constants.signUserMessage, preferredStyle: .alert)
        alert.addTextField { (text) in

        }
        alert.addAction(UIAlertAction(title: Constants.okMessage, style: .default, handler: { (action) in
            if let text = alert.textFields?.first?.text {
                self.performOperation(operation: .signAndVerify, message: text)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showOptions(sender: UIBarButtonItem) {
        
        let actionsheet = UIAlertController(title: "Choose One option:", message: "", preferredStyle: .actionSheet)

        actionsheet.addAction(UIAlertAction(title: "WKWebView", style: .default , handler:{_ in
            self.requestOption = .wkwebview
            self.authentication()
        }))

        actionsheet.addAction(UIAlertAction(title: "URLSession", style: .default , handler:{_ in
            self.requestOption = .urlsession
            self.authentication()
        }))

        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{_ in
            print("User click Dismiss button")
        }))

        if UIDevice.current.isIPad {
            actionsheet.popoverPresentationController?.barButtonItem = sender
            actionsheet.popoverPresentationController?.sourceView = self.view
        }
        self.present(actionsheet, animated: true)
    }

    @objc func authentication() {
        guard viewModel?.selectedIdentities.count == 1 else {
            self.presentSimpleAlert(title: Constants.errorTitle, message: Constants.authenticationSupportMessage)
            return
        }

        guard ((viewModel?.selectedIdentities.first) != nil) else {
            self.presentSimpleAlert(title: Constants.errorTitle, message: Constants.emptyIdentityTitle)
            return
        }

        if requestOption == .urlsession {
            self.performSegue(withIdentifier: "urlsessionAuth", sender: self)
        } else {
            self.performSegue(withIdentifier: "webAuth", sender: self)
        }
        
    }

    func updateLeftBarButton(isSelectState: Bool) {
        self.navigationItem.leftBarButtonItem?.title = isSelectState ? "Select" : "Reset"
    }

    // MARK: - Private methods
    func setupBarButtonItems() {
        let auth = UIBarButtonItem(title: "Auth", style: .plain, target: self, action: #selector(showOptions(sender:)))
        let sign = UIBarButtonItem(title: "Sign", style: .plain, target: self, action: #selector(signAndVerifyCert))
        let decrypt = UIBarButtonItem(title: "Decrypt", style: .plain, target: self, action: #selector(encryptAndDecrypt))

        self.navigationItem.rightBarButtonItems = [auth, sign, decrypt]
    }

    func performOperation(operation: KeyOperation, message: String) {
        var publicCertCommonName = ""
        var dataSource = viewModel?.allIdentities
        if (viewModel?.selectedIdentities.count ?? 0) > 0 {
            dataSource = viewModel?.selectedIdentities
        }

        guard let dataSourc = dataSource else {
            print("[Consumer] Datasource is empty")
            return
        }

        for (_,identity) in dataSourc.enumerated() {
            var result: Result<String?, ErrorTypes>?

            var algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
            if operation == .signAndVerify {
                algorithm = .rsaSignatureMessagePKCS1v15SHA512
            }

            result = viewModel?.performOperation(operation: operation, identity: identity, string: message, usingAlogorithm: algorithm)

            switch result {
            case .success(let response):
                print("[Consumer] signAndVerifyCert operation : \(String(describing: response))")
                publicCertCommonName = response ?? ""

            case .failure(let error):
                print("[Consumer] signAndVerifyCert operation failed : \(error.localizedDescription)")
                    switch error {
                    case .pivdAppLaunchNeeded(let description):
                        self.userErrorPrompt(errorMessage: description, isOpenInPivd: true)
                        return
                    case .decryptionError(let description), .signingError(let description):
                        self.userErrorPrompt(errorMessage: description)
                        return
                    default:
                        break
                    }
                self.userErrorPrompt(errorMessage: error.localizedDescription)
                return
            case .none:
                break
            }
            if publicCertCommonName.count > 0 { break }
        }

        let operationString = operation.description
        let title = publicCertCommonName.count > 0 ? Constants.successTitle : Constants.failureTitle
        let message = publicCertCommonName.count > 0 ? "\(operationString) successful for message: \(message)\n using key: \(publicCertCommonName)" : "Please ensure a valid identity with \(operationString) capability is selected. Refer logs for more details"
        self.presentSimpleAlert(title: title, message: message)
    }
}

extension CertificateListViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfCertificates ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CertificateCell", for: indexPath)
        // set cell selection style to none
        cell.selectionStyle = .none

        if (viewModel?.isIdentityAlreadySelected(dataSourceIndex: indexPath.row) ?? false) {
            cell.accessoryType = .checkmark
        }
        else {
            //cell.accessoryType = .disclosureIndicator
            cell.accessoryType = .none
        }

        if let certificateCell = cell as? CertificateCell,
           let certViewModel = viewModel?.certificateViewModelForIndex(index: indexPath.row) {
            certificateCell.nameLabel?.text = certViewModel.certificateCommonName
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.updateSelectedIdentities(dataSourceIndex: indexPath.row)
        tableView.reloadData()
    }
}

// Navigation
extension CertificateListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webAuth", let destination = segue.destination as? WebAuthViewController {
            if let identity = viewModel?.selectedIdentities.first {
                destination.selectedIdentity = identity
            }
        } else if segue.identifier == "urlsessionAuth", let destination = segue.destination as? URLSessionAuthViewController {
                if let identity = viewModel?.selectedIdentities.first {
                    destination.selectedIdentity = identity
                }
            }
    }
}

extension CertificateListViewController {
    func userErrorPrompt(errorMessage: String, isOpenInPivd: Bool = false) {
        let errorTitle = isOpenInPivd ? Constants.accessSuspendedTitle : Constants.errorTitle
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        if isOpenInPivd {
            alert.addAction(UIAlertAction(title: Constants.openPIVD, style: .default, handler: { (action) in
                if let url = URL(string: "vmwarepivd://") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in

        }))
        present(alert, animated: true, completion: nil)
    }
}

internal extension String {
    func containsIgnoringCase(_ find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

extension UIViewController {
    func presentSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.okMessage, style: .default, handler: { (action) in

        }))
        present(alert, animated: true, completion: nil)
    }
}
