# 📱 포켓몬 프로필 연락처 앱

UIKit 기반으로 구현된 연락처 관리 iOS 애플리케이션입니다. 각 연락처에 랜덤 포켓몬 이미지를 부여하여 시각적인 재미를 더했습니다.

## ✨ 주요 기능

-   **UIKit + 코드 기반 UI**: 모든 UI는 코드로 구현되었으며, SnapKit 라이브러리를 활용하여 Auto Layout을 설정했습니다.
-   **랜덤 포켓몬 이미지**: `pokeapi.co`를 통해 1부터 1000 사이의 랜덤 포켓몬 이미지를 불러와 프로필 사진으로 사용합니다.
-   **CoreData 연동**: 이름, 전화번호, 이미지 URL을 CoreData에 저장하고 관리합니다.
-   **연락처 목록**: `UITableView`를 사용하여 저장된 연락처 목록을 이름순으로 정렬하여 표시합니다.
-   **연락처 추가/편집**: 새로운 연락처를 추가하거나 기존 연락처 정보를 편집할 수 있는 화면을 제공합니다.
-   **NavigationController 기반 화면 전환**: 화면 간 이동은 `UINavigationController`를 통해 관리됩니다.
-   **이미지 원형 표시**: 프로필 이미지는 원형으로 표시됩니다.

## 🏗️ 아키텍처

본 프로젝트는 **MVC (Model-View-Controller)** 패턴을 기반으로 구조화되었습니다.

-   **Model**: CoreData 엔티티 (`Contact`) 및 API 파싱 모델 (`Pokemon`, `Sprites`).
-   **View**: UI 컴포넌트 (`ContactCell` 등).
-   **Controller**: 뷰 컨트롤러 (`ContactListViewController`, `ContactEditViewController`).
-   **Service**: API 통신 (`APIService`), CoreData 관리 (`CoreDataManager`)를 담당하는 싱글톤 클래스.

## 🛠️ 사용된 기술

-   **Swift 5+**
-   **UIKit**
-   **SnapKit**: Auto Layout을 코드로 쉽게 작성하기 위한 DSL (Domain Specific Language) 라이브러리.
-   **CoreData**: 앱의 데이터를 영구적으로 저장하고 관리하기 위한 프레임워크.
-   **URLSession**: 네트워크 통신을 위한 Apple 프레임워크.

## 🚀 프로젝트 설정 및 실행 방법

1.  **프로젝트 클론**: 이 프로젝트의 소스 코드를 다운로드합니다.

2.  **Xcode 프로젝트 열기**: `poketmon.xcodeproj` 파일을 Xcode로 엽니다.

3.  **SnapKit 설치**:
    *   Xcode 메뉴에서 `File > Add Packages...`를 선택합니다.
    *   검색창에 `https://github.com/SnapKit/SnapKit.git`를 입력하고 검색합니다.
    *   `SnapKit` 패키지를 선택하고 `Add Package` 버튼을 클릭하여 프로젝트에 추가합니다.

4.  **CoreData 모델 설정 (필수)**:
    *   Xcode 프로젝트 네비게이터에서 `File > New > File...`을 선택합니다.
    *   `Core Data` 섹션에서 `Data Model` 템플릿을 선택하고 `Next`를 클릭합니다.
    *   파일 이름을 `PoketmonContact.xcdatamodeld`로 지정하고 `Create`합니다.
    *   생성된 `PoketmonContact.xcdatamodeld` 파일을 클릭합니다.
    *   화면 하단의 `Add Entity` 버튼을 클릭하여 새 엔티티를 추가하고 이름을 `Contact`로 변경합니다.
    *   `Contact` 엔티티를 선택한 상태에서 `Attributes` 섹션의 `+` 버튼을 눌러 다음 세 가지 속성을 추가합니다:
        -   `name`: Type `String`
        -   `phoneNumber`: Type `String`
        -   `imageUrl`: Type `String`
    *   `Contact` 엔티티를 선택한 상태에서 오른쪽 유틸리티 영역(Utility Area)의 데이터 모델 인스펙터(Data Model Inspector)에서 `Codegen`을 **`Class Definition`**으로, `Module`을 **`Current Product Module`**로 설정합니다.

5.  **빌드 및 실행**: `Command + R`을 눌러 시뮬레이터 또는 실제 기기에서 앱을 빌드하고 실행합니다.

## 🌐 API 참조

-   **포켓몬 데이터**: [pokeapi.co](https://pokeapi.co/)
    -   포켓몬 정보 및 이미지 URL을 가져오는 데 사용됩니다.
    -   이미지 URL은 `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{id}.png` 형식입니다.

## ⚠️ 문제 해결 (Troubleshooting)

-   **`Cannot find type 'Contact' in scope` 오류**: CoreData 모델 설정이 올바른지 확인하고, `PoketmonContact.xcdatamodeld` 파일의 `Contact` 엔티티 `Codegen` 설정이 `Class Definition`으로 되어 있는지 확인하십시오. 또한, Xcode의 `Product > Clean Build Folder`를 시도해 보십시오.
-   **네트워크 연결 오류 (`The request timed out`, `The network connection was lost`)**: `pokeapi.co` 서버로의 연결이 불안정하거나 차단될 수 있습니다. 인터넷 연결 상태를 확인하고, 다른 네트워크 환경에서 시도하거나, 브라우저에서 `pokeapi.co`에 직접 접속하여 서버 상태를 확인해 보십시오. (현재 `APIService`는 `raw.githubusercontent.com`에서 직접 이미지를 가져오도록 우회되어 있습니다.)

---