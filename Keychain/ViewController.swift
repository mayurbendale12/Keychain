//
//  ViewController.swift
//  Keychain
//
//  Created by Mayur Bendale on 07/12/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var updatePasswordTextField: UITextField!
    @IBOutlet private weak var getPasswordLabel: UILabel!
    
    private let service = "abc.com"

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

    @IBAction private func didTapSaveButton(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showAlert(title: "Failed", message: "Enter UserName")
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Failed", message: "Enter Password")
            return
        }

        do {
            try KeychainManager.save(service: service,
                                     username: usernameTextField.text ?? "",
                                     password: passwordTextField.text ?? "")
        } catch {
            print(error)
        }

        usernameTextField.text = ""
        passwordTextField.text = ""
    }

    @IBAction private func didTapGetButton(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showAlert(title: "Failed", message: "Enter UserName")
            return
        }
        do {
            let password = try KeychainManager.get(service: service, username: usernameTextField.text ?? "")
            getPasswordLabel.text = password
        } catch {
            getPasswordLabel.text = ""
            showAlert(title: "Failed", message: "No Password exist")
            print(error)
        }
    }

    @IBAction private func didTapUpdateButton(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showAlert(title: "Failed", message: "Enter UserName")
            return
        }
        do {
            try KeychainManager.update(service: service,
                                       username: usernameTextField.text ?? "",
                                       password: updatePasswordTextField.text ?? "")
        } catch {
            print(error)
        }
        updatePasswordTextField.text = ""
    }

    @IBAction private func didTapDeleteButton(_ sender: UIButton) {
        do {
            try KeychainManager.delete(service: service)
        } catch {
            print(error)
        }
    }

    @IBAction private func didTapClearKeychainButton(_ sender: UIButton) {
        KeychainManager.clearKeychain()
        usernameTextField.text = ""
        passwordTextField.text = ""
        updatePasswordTextField.text = ""
        getPasswordLabel.text = ""
    }
}
