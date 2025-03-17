import UIKit
import Contacts
import MessageUI

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.tintColor = .black
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    let contactStore = CNContactStore()
    var contacts: [(name: String, number: String)] = []
    
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkContactsPermission()
    }
    
    func setupUI() {
        title = "Local Contacts"
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    func checkContactsPermission() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .notDetermined:
            requestContactsPermission()
        case .authorized:
            fetchContacts()
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    func requestContactsPermission() {
        contactStore.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.fetchContacts()
                } else {
                    self.showPermissionAlert()
                }
            }
        }
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "Permission Required",
                                      message: "Please enable contacts access in settings.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func fetchContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            var fetchedContacts: [(String, String)] = []
            
            do {
                try self.contactStore.enumerateContacts(with: request) { contact, _ in
                    if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                        let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                        fetchedContacts.append((fullName, phoneNumber))
                    }
                }
            } catch {
                print("Failed to fetch contacts: \(error)")
            }
            
            DispatchQueue.main.async {
                self.contacts = fetchedContacts.sorted(by: { $0.0 < $1.0 }) // Sort by name (index 0)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableView Methods -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = contact.number
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        openMessages(number: contact.number)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Open Messages -
    
    func openMessages(number: String) {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.messageComposeDelegate = self
            messageVC.recipients = [number]
            present(messageVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Messaging is not available on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: - MessageCompose Delegate -
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}
