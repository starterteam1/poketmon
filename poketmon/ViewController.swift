
import UIKit
import CoreData

class ContactEditViewController: UIViewController {

    var contact: Contact? // 편집할 연락처를 전달받을 변수

    private let nameTextField = UITextField()
    private let phoneTextField = UITextField()
    private let profileImageView = UIImageView()
    private let randomImageButton = UIButton(type: .system)
    private var imageUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        configureForEditing() // 편집 모드일 경우 화면 구성
    }

    private func configureForEditing() {
        if let contact = contact {
            title = "연락처 편집"
            nameTextField.text = contact.name
            phoneTextField.text = contact.phoneNumber
            imageUrl = contact.imageUrl
            if let urlString = contact.imageUrl {
                fetchImage(from: urlString)
            }
        } else {
            title = "새 연락처"
        }
    }

    private func setupUI() {
        view.backgroundColor = .white
        nameTextField.placeholder = "이름"
        phoneTextField.placeholder = "전화번호"
        profileImageView.backgroundColor = .lightGray
        randomImageButton.setTitle("랜덤 이미지 생성", for: .normal)
        randomImageButton.addTarget(self, action: #selector(randomButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [profileImageView, nameTextField, phoneTextField, randomImageButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            nameTextField.widthAnchor.constraint(equalToConstant: 200),
            phoneTextField.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
    }

    @objc private func randomButtonTapped() {
        randomImageButton.isEnabled = false
        randomImageButton.setTitle("이미지 불러오는 중...", for: .disabled)

        APIService.shared.fetchRandomPokemonImage { [weak self] result in
            DispatchQueue.main.async {
                self?.randomImageButton.isEnabled = true
                self?.randomImageButton.setTitle("랜덤 이미지 생성", for: .normal)
                
                switch result {
                case .success(let imageUrl):
                    self?.imageUrl = imageUrl
                    self?.fetchImage(from: imageUrl)
                case .failure(let error):
                    print("Error fetching image URL: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "에러", message: "이미지를 불러오는데 실패했습니다: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func fetchImage(from urlString: String) {
        print("DEBUG: Attempting to fetch image from URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("DEBUG: Invalid image URL: \(urlString)")
            DispatchQueue.main.async {
                self.profileImageView.image = nil
                let alert = UIAlertController(title: "오류", message: "잘못된 이미지 주소입니다. URL 형식을 확인해주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0 // 15초 타임아웃 설정
        let session = URLSession(configuration: config)

        session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("DEBUG: Error downloading image: \(error.localizedDescription)")
                    self?.profileImageView.image = nil
                    let alert = UIAlertController(title: "이미지 다운로드 오류", message: "이미지를 다운로드할 수 없습니다: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("DEBUG: HTTP Status Code: \(httpResponse.statusCode)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("DEBUG: Server returned non-success status code.")
                        self?.profileImageView.image = nil
                        let alert = UIAlertController(title: "네트워크 오류", message: "이미지 서버 응답이 비정상적입니다. (상태 코드: \(httpResponse.statusCode))", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self?.present(alert, animated: true)
                        return
                    }
                }
                
                guard let data = data else {
                    print("DEBUG: No data received from image URL.")
                    self?.profileImageView.image = nil
                    let alert = UIAlertController(title: "이미지 오류", message: "이미지 데이터를 받지 못했습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                    return
                }
                
                print("DEBUG: Data received, size: \(data.count) bytes.")
                
                guard let image = UIImage(data: data) else {
                    print("DEBUG: Failed to create UIImage from data.")
                    self?.profileImageView.image = nil
                    let alert = UIAlertController(title: "이미지 변환 오류", message: "다운로드된 데이터를 이미지로 변환할 수 없습니다. 파일 형식을 확인해주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                    return
                }
                
                self?.profileImageView.image = image
                print("DEBUG: Image successfully loaded and set.")
            }
        }.resume()
    }

    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty,
              let imageUrl = self.imageUrl else {
            let alert = UIAlertController(title: "정보 부족", message: "이름, 전화번호, 프로필 이미지를 모두 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        if let contact = self.contact {
            // 편집 모드: 기존 연락처 업데이트
            CoreDataManager.shared.updateContact(contact: contact, name: name, phoneNumber: phone, imageUrl: imageUrl)
        } else {
            // 생성 모드: 새 연락처 생성
            CoreDataManager.shared.createContact(name: name, phoneNumber: phone, imageUrl: imageUrl)
        }

        navigationController?.popViewController(animated: true)
    }
}
