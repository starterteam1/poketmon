
import UIKit
import SnapKit
import CoreData
import CoreData

class AddEditViewController: UIViewController {

    var contact: Contact?
    private var randomImageUrl: String?

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 75
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let randomImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("랜덤 이미지 생성", for: .normal)
        return button
    }()

    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이름"
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let phoneNumberTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "전화번호"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .phonePad
        return tf
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtonActions()
        configureForEditing()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = contact == nil ? "새 연락처" : "연락처 편집"

        view.addSubview(profileImageView)
        view.addSubview(randomImageButton)
        view.addSubview(nameTextField)
        view.addSubview(phoneNumberTextField)
        view.addSubview(saveButton)

        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(150)
        }

        randomImageButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(randomImageButton.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(15)
            make.leading.trailing.equalTo(nameTextField)
            make.height.equalTo(44)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(30)
            make.leading.trailing.equalTo(nameTextField)
            make.height.equalTo(50)
        }
    }

    private func setupButtonActions() {
        randomImageButton.addTarget(self, action: #selector(randomButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func configureForEditing() {
        guard let contact = contact else { return }
        nameTextField.text = contact.name
        phoneNumberTextField.text = contact.phoneNumber
        randomImageUrl = contact.imageUrl
        if let urlString = contact.imageUrl, let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    @objc private func randomButtonTapped() {
        APIService.shared.fetchRandomPokemonImage { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageUrl):
                    self?.randomImageUrl = imageUrl
                    if let url = URL(string: imageUrl), let data = try? Data(contentsOf: url) {
                        self?.profileImageView.image = UIImage(data: data)
                    }
                case .failure(let error):
                    print("Error fetching image: \(error)")
                    // 사용자에게 에러 알림 표시 (예: UIAlertController)
                }
            }
        }
    }

    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty,
              let imageUrl = randomImageUrl else {
            // 사용자에게 모든 필드를 채우라는 알림 표시
            return
        }

        if let contact = contact {
            // 편집 모드
            CoreDataManager.shared.updateContact(contact: contact, name: name, phoneNumber: phoneNumber, imageUrl: imageUrl)
        } else {
            // 생성 모드
            CoreDataManager.shared.createContact(name: name, phoneNumber: phoneNumber, imageUrl: imageUrl)
        }

        navigationController?.popViewController(animated: true)
    }
}
