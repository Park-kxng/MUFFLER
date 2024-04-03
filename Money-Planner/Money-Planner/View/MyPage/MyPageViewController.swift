//  MyPageViewController.swift
//  Money-Planner
//
//  Created by p_kxn_g on 1/30/24.
//
import Foundation
import UIKit


class MyPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProfileViewDelegate {
    var tempUserName : String = ""
    var tempProfileImage: UIImage?

    var user = User()
    // 테이블 뷰 데이터 소스
    let myPageData = [
        Section(title: "프로필", items: ["프로필"]),
        Section(title: "설정", items: ["알림 설정"]),
        Section(title: "앱 정보 및 문의", items: ["앱 버전", "개인정보 처리 방침", "1:1 문의하기"]),
        Section(title: "계정", items: ["로그아웃", "탈퇴하기"])
    ]

    // UITableView 인스턴스
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        return table
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        tempUserName = user.userNameString
        navigationController?.isNavigationBarHidden = true // 네비게이션 바 숨김

        // 커스텀 UITableViewCell 등록
        tableView.register(MyPageTableViewCell.self, forCellReuseIdentifier: "myPageCell")


        // 테이블 뷰의 델리게이트와 데이터 소스 설정
        tableView.delegate = self
        tableView.dataSource = self

        // 테이블 뷰를 뷰 계층에 추가
        view.addSubview(tableView)

        // 테이블 뷰에 대한 제약 조건 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - UITableViewDataSource 메서드

    func numberOfSections(in tableView: UITableView) -> Int {
        return myPageData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPageData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPageCell", for: indexPath) as! MyPageTableViewCell
        let item = myPageData[indexPath.section].items[indexPath.row]
        var text = item
 
        if item == "프로필"{
            text = "프로필 설정"
            cell.optionalLabel.text = text
            tempProfileImage = UIImage(named: "add-05")
            cell.addProfile(user.userNameString, image : tempProfileImage)

            // 프로필인 경우 프로필 띄우기
        }
        else{
            cell.textLabel?.text = item
            cell.textLabel?.font = UIFont.mpFont16M()

        }
        
            // 각 셀에 대한 추가 작업을 수행할 수 있습니다.
            return cell
        }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if myPageData[section].title == "프로필"{
            return nil // 부제목을 표시하지 않음
        }
        return myPageData[section].title
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = myPageData[indexPath.section].items[indexPath.row]
        if item == "프로필"{
            return 128.0 // 프로필인 경우 높이 120

        }else{
            return 60.0 //프로필이 아닌 경우 높이 60
        }
        
    }

    // MARK: - UITableViewDelegate 메서드

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 셀 선택 처리
        let selectedItem = myPageData[indexPath.section].items[indexPath.row]

        switch selectedItem {
        case "프로필":
            // 프로필 뷰로 이동
            print("프로필 선택됨")
            // 프로필 설정 화면으로 이동
            settingProfile()
            
        case "알림 설정":
            // 알림 설정 뷰로 이동
            print("알림 설정 선택됨")
            let alarmVC = NotificationSettingViewController()
            self.navigationController?.pushViewController(alarmVC, animated: true)

        case "앱 버전":
            // 앱 버전 뷰로 이동
            let appVersionVC = AppVersionViewController()
            self.navigationController?.pushViewController(appVersionVC, animated: true)
            print("앱 버전 선택됨")
        
        case "개인정보 처리 방침":
            // 개인정보 처리 방침 뷰로 이동
            let privacyVC = PrivacyPolicyViewController()
            self.navigationController?.pushViewController(privacyVC, animated: true)
            print("개인정보 처리 방침 선택됨")
        case "1:1 문의하기":
            // 1:1 문의하기 뷰로 이동
            Ask()
            print("1:1 문의하기 선택됨")
        case "로그아웃":
            // 로그아웃 처리
            print("로그아웃 선택됨")
            // 로그아웃 모달로 이동
            let logoutVC = PopupViewController() // 로그아웃 완료 팝업 띄우기
            present(logoutVC, animated: true)
            
            
        case "탈퇴하기":
            // 계정 탈퇴 처리
            print("탈퇴하기 선택됨")
            Unregister()
        default:
            break
        }
    }

    // 섹션과 아이템을 나타내는 데이터 구조
    struct Section {
        var title: String
        var items: [String]
    }
    
    func profileNameChanged(_ userName: String, _ profileImage : UIImage?) {
        user.changeUserName(userName)
        tempUserName = userName
        tempProfileImage = profileImage // Set the profile image in your User model

        // Reload only the cell representing the profile
        if let indexPath = indexPathForProfileCell() {
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        print("프로필 이름이 변경되었습니다")
        print(user.userNameString)
        view.layoutIfNeeded()
    }

    private func indexPathForProfileCell() -> IndexPath? {
        for (sectionIndex, section) in myPageData.enumerated() {
            if let rowIndex = section.items.firstIndex(of: "프로필") {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    func settingProfile() {
        let profileVC = ProfileViewController(tempUserName: tempUserName) // 프로필 설정 화면으로 이동
        profileVC.modalPresentationStyle = .fullScreen
        profileVC.delegate = self
        present(profileVC, animated: true)
    }
    func Ask(){
        let askVC = AskViewController() // 프로필 설정 화면으로 이동
        askVC.modalPresentationStyle = .fullScreen
        //askVC.delegate = self
        present(askVC, animated: true)
        
    }
    func Unregister(){
        let unregisterVC = UnregisterViewController() // 프로필 설정 화면으로 이동
        unregisterVC.modalPresentationStyle = .fullScreen
        //askVC.delegate = self
        present(unregisterVC, animated: true)
        
    }
    // 네비게이션 바 숨김 설정 - 라이프 사이클 이용
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // 네비게이션 바 숨김 설정
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // 다른 뷰로 이동할 때 네비게이션 바 보이도록 설정
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
}

class AppVersionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let label = UILabel()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "알 수 없음"

        label.text = "앱 버전은 \(version)입니다."
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}



class PrivacyPolicyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "개인정보 처리 방침"
        let scrollView = UIScrollView()
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .mpFont14M()
        label.textColor = .darkGray
        label.text =
        """
        < 머플러 >은(는) 「개인정보 보호법」 제30조에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.
        
        **제1장 총칙**

        **제1조 （이용약관）**

        1. 머플러앱(이하, ‘본 앱’이라고 함)을 이용할 때는 이 머플러앱의 이용규약(이하, ‘본 규약’이라고 함)에 동의한 후에 본 앱을 다운로드 받고, 본 규약을 준수해야 합니다. 본 규약은 본 앱을 이용하는 분들(이하, ‘이용자’라고 함)이 본 앱을 이용할 때 적용됩니다. 만약 동의하실 수 없다면 대단히 죄송하지만 이용을 삼가 주십시오.
        2. 본 규약 및 당사가 본 앱에 관해 본 앱상에 게시하거나 직접 이용자에게 개별적으로 연락하는 알림 등은 모두 본 규약과 통합된 것으로서 이용자는 이를 준수할 의무를 지닙니다.

        **제2조 （본 규약의 변경）**

        1. 당사는 스스로 필요하다고 판단될 경우, 이용자의 동의를 얻지 않고 수시로 본 규약을 추가, 변경 및 삭제(이하, 총칭하여 ‘변경 등’이라고 함)할 수 있습니다.
        2. 본 규약이 변경된 후에 이용자가 본 앱을 이용한 경우, 변경된 이후의 본 규약에 동의하신 것으로 간주합니다.

        **제2장 본 앱 및 이용자 등**

        **제3조 （정의）**

        1. 본 규약에서 ‘본 앱 콘텐츠’란 이용자 자신이 소유한 스마트폰 등의 휴대 정보 단말기에 당사가 제공하는 본 앱을 설치했을 때, 당사가 해당 휴대 정보 단말기에 제공하는 각종 정보(이하, ‘본 앱 관련 정보’라고 함)를 말합니다.
        2. 이용자 전송 정보란 이용자가 본 앱상에서 당사에 전송하는 각종 정보 및 본 앱을 통해 이용자로부터 제공된 정보를 말합니다.

         **제4조 (본 앱의 다운로드)**

        1. 본 앱의 이용을 희망하는 개인은 본 규약에 동의한 후, 본 앱을 자신이 소유한 휴대 정보 단말기에 본 앱 다운로드하기를 실행해야 합니다.

         **제5조 （본 앱 이용에 관한 여러 조건）**

        1. 이용자는 본 규약의 각 조항에 따라 본 앱을 위해 본 앱을 무상으로 사용할 독점적인 권리를 취득합니다.
        2. 이용자는 본 앱을 제삼자에게 사용 허락, 대여 또는 리스할 수 없습니다.
        3. 이용자는 본 앱의 전부 또는 일부를 복제, 변경 등을 할 수 없습니다.
        4. 이용자는 본 앱의 리버스 엔지니어링, 역컴파일 또는 역어셈블을 할 수 없습니다.
        5. 본 앱의 등록, 이용, 변경 및 이용 정지로 발생하는 통신비에 대해서는 이용자가 지불하며, 당사는 일체 부담하지 않습니다.
        6. 본 앱에 게재되어 있는 캠페인 정보는 캠페인을 기획하고 있는 당사가 제공 또는 당사가 승인한 제삼자 기업의 캠페인 기획을 제공하고 있습니다.

        **제6조 （본 앱의 콘텐츠 변경）**

        1. 당사는 본 앱 콘텐츠의 내용 등을 변경할 수 있습니다. 또한, 변경 효력은 당사가 별도로 규정한 경우를 제외하고, 당사가 본 앱상에서 해당하는 본 앱 콘텐츠를 변경한 시점부터 발생합니다.
        2. 전항에 의거하여 본 앱 콘텐츠의 내용 등이 변경된 경우, 이로 인해 발생한 이용자의 손해에 관해 당사는 일절 책임을 지지 않습니다.

        **제7조 （본 앱의 이용 중단）**

        1. 당사는 이하의 각호 중 어느 하나에 해당하는 사유가 발생한 것으로 판단한 경우, 이용자에게 사전 통보 없이, 본 앱의 전부 또는 일부 이용을 중단, 정지, 폐지 등(이하, 총칭하여 ‘중단 등’이라고 함)을 할 수 있습니다.

        (1) 본 앱용 설비 등의 유지보수를 정기적 또는 긴급으로 실시할 경우

        (2) 화재, 정전, 기타 불의의 사고 등으로 본 앱을 이용할 수 없게 된 경우

        (3) 지진, 분화, 홍수, 해일 등의 자연재해로 본 앱을 이용할 수 없게 된 경우

        (4) 전쟁, 동란, 폭동, 내전, 노동 쟁의, 통상 금지, 파업, 물자 및 수송 시설의 확보 불능 또는 정부 당국의 개입 등으로 본 앱을 이용할 수 없게 된 경우

        (5) 기타 운용상 또는 기술상 본 앱의 중단 등이 필요하다고 당사가 판단한 경우

        1. 여러 사정으로 본 앱을 지속적으로 제공하기 어려울 경우, 당사는 당사의 판단에 의해 이용자의 허가를 얻지 않고, 본 앱의 전부 또는 일부의 이용을 폐지할 수 있습니다.
        2. 당사는 전 2항 중 어느 하나 또는 그것과 유사한 사유로 인해 본 앱의 이용 중단 등으로 이용자 또는 제삼자가 입은 손해에 대해 일절 책임을 지지 않습니다.

        **제8조 （본 앱의 이용 정지）**

        본 앱의 이용 정지를 원하는 이용자는 본 앱 내의 메뉴 또는 소정의 방법으로 본 앱을 제거함으로써, 이용을 정지할 수 있습니다.

        **제3장 이용자의 책임과 의무**

        **제9조 （자기책임의 원칙）**

        1. 이용자는 본 규약을 준수하고 타인을 존중하며 법률과 도덕, 예의를 지키고 자신의 책임으로 본 앱을 이용합니다.
        2. 이용자는 본 앱의 이용과 관련하여 당사와 본 앱에 게재되는 점포, 또는 그 이외의 제삼자에게 손해를 입힌 경우(이용자가 본 규약상의 의무를 준수하지 않아서 당사나 게재 점포 또는 제삼자가 손해를 본 경우를 포함), 자신이 책임지고 비용을 부담함으로써 그에 따른 모든 손해를 배상(소송 비용 및 변호사 비용 포함)합니다.

        **제10조 （금지 사항）**

        1. 이용자는 전조에서 규정한 행위 외에 아래의 각호 중 어느 하나에 해당하는 행위를 해서는 안 됩니다.

        (1)본 앱용 설비(당사 또는 당사가 지정한 본 앱을 제공하기 위해 준비하는 통신 설비, 통신 회선, 전자계산기, 기타 기기 및 소프트웨어를 포함)에 부정하게 접근하거나 이용 또는 운영에 지장을 주는 행위(이용의 통상 범위를 넘어서 서버에 부담을 주는 행위 포함)

        (2)휴대 정보 단말기를 부정하게 사용하거나 제삼자에게 부정한 사용을 유발시키는 행위

        (3)본 앱에 컴퓨터 바이러스 및 기타 유해한 컴퓨터 프로그램이 포함된 정보를 전송, 글쓰기 또는 게재하는 행위

        (4)다른 이용자 행세를 하여 본 앱을 이용하는 행위

        (5)본 앱을 부정하게 변경하는 행위

        (6)그 밖에 당사가 부적절, 부적당하다고 판단하는 행위

        **제4장 지식재산권**

        **제11조 （지식재산권）**

        1. 이용자는 본 앱상에서 당사가 제공 또는 게재하는 정보 등(본 앱 관련 정보를 포함)에 대해서는 해당 정보에 관한 저작권, 특허권, 실용신안권, 상표권 및 의장권, 기타 모든 지식재산권(그것들의 권리를 취득하거나 그것들의 권리에 대한 등록 등을 출원하는 권리를 포함)이 당사 또는 제삼자에게 귀속되는 것을 납득하고, 이용자는 당사 및 당사에 대해 사용을 허락한 해당 제삼자의 허락을 얻었을 경우 또는 저작권법 제30조에 규정된 사적 사용의 범위에서 사용하는 경우를 제외하고, 해당 정보를 직접 사용 또는 제삼자에게 개시 또는 사용하게 할 수 없습니다.
        2. 이용자가 본 앱상에서 제공한 이용자 전송 정보의 저작권 및 기타 모든 지식재산권은 이용자에게 귀속됩니다. 단, 이용자는 당사 및 당사가 지정한 제삼자에게 해당 이용자 전송 정보를 일본 국내외에서 무기한 및 무상으로 비독점적인 사용 권리(복제권, 자동공중송신권, 상영권, 배포권, 양도권, 대여권, 번역권, 번안권, 유상 또는 무상에 관계없이 물품으로 제작하여 제삼자에게 판매하는 권리가 포함되지만, 이에 한정되지 않음)를 허락(재허락권을 부여하는 권리를 포함)한 것으로 간주합니다. 이용자는 당사 및 당사가 지정한 제삼자에게 저작자 인격권을 일절 행사하지 않습니다. 또한, 이용자는 본 항에 의해 이용자에게 귀속되는 지식재산권을 제삼자에게 양도할 경우, 해당 지식재산권을 승계받는 제삼자에게 이용자가 책임지고 본 항의 규정을 승낙하게 합니다.

        **제12조 （본 앱에 관한 권리）**

        1. 본 앱에 관한 저작권 등의 지식재산권은 당사에 귀속되며, 본 앱은 일본의 저작권법, 기타 관련하여 적용되는 법률 등으로 보호받고 있습니다. 따라서 이용자는 본 앱을 다른 저작물과 동일하게 취급해야 합니다.
        2. 본 앱상에 표시되는 상표, 로고 및 서비스 마크 등(이하, 총칭하여 ‘상표 등’이라고 함)은 당사의 등록 또는 미등록 상표입니다. 당사는 본 규약에 의해 이용자 또는 기타 제삼자에게 어떠한 상표 등을 양도 또는 사용을 허락하지 않습니다.

        **제5장 운영**

        **제13조 （당사의 권리）**

        1. 당사는 본 앱상에 당사가 지정하는 제삼자가 취급하는 광고 등을 자유롭게 게재할 수 있습니다.
        2. 당사는 본 앱상에서 이용자로부터 정보를 수집(이용자 전송 정보 등을 포함하지만, 이에 한정되지 않음)할 수 있습니다. 당사는 수집한 정보에 대해서는 다음 조에 규정된 보안 정책에 따라 엄중하게 관리합니다.

        **제14조 （보안 정책）**

        1. 당사는 본 앱의 시스템 정보 기반(이하, ‘본 시스템’이라고 함)의 운영에서 다음 사항을 준수합니다.

        (1)본 시스템에 대한 접속 및 조작은 당사 내에서 규정된 담당자 및 시스템 관리자로 제한한다.

        (2)본 시스템의 기능이 정상적으로 작동하도록 바이러스나 외부 침입에 대해 통상적으로 입수할 수 있는 적절한 보안 시스템을 도입 및 운용하여 대응한다.

        (3)본 시스템의 업무 운영을 외부 사업자에게 위탁할 경우에도 전 2호를 철저히 준수한다.

        1. 당사의 개인정보 처리 전반에 관한 것은 당사 홈페이지에 있는 개인정보 보호방침을 따릅니다.

        **제15조 （면책 및 손해 배상）**

        1. 당사는 본 앱의 이용과 관련해 발생한 이용자의 손실 및 손해에 대해 당사에 고의 또는 중대 과실이 있는 경우를 제외하고, 일절 책임을 지지 않습니다.
        2. 당사는 본 앱상에서 당사 이외의 제삼자가 운영하는 웹사이트로 링크가 걸려 있는 경우, 이용자가 해당 링크의 웹사이트를 이용(과금, 물품 구입 등을 포함하지만, 이에 한정되지 않음)하면서 발생한 손해에 대해 일절 책임을 지지 않습니다.
        3. 당사는 본 앱을 제공하는 기기의 고장, 트러블, 정전 등 또는 통신 회선의 이상 등 당사가 예측하지 못한 사유 또는 시스템 장애 등으로 인한 이용자의 본 앱 관련 정보 및 이용자 전송 정보가 소실된 경우, 이로 인한 손해에 대해 일절 책임을 지지 않습니다.
        4. 당사는 이용자가 본 규약을 위반 또는 본 앱의 적절한 이용을 벗어난 행위로 발생한 사회적, 정신적, 육체적, 금전적 손해에 대해 일절 책임을 지지 않습니다.
        5. 당사는 이용자의 개인 인증을 거친 본 앱의 이용 또는 그에 따른 모든 행위는 해당 이용 및 행위가 해당 이용자 본인에 의한 것인지의 여부와 관계없이 해당 이용자로 인한 이용 및 행위로 간주하고, 해당 이용 및 행위의 결과로 발생한 손해에 대해 일절 책임을 지지 않습니다.
        6. 당사는 본 앱의 이용 중단 등에 따라 이용자가 부담한 모든 비용(통신비 등을 포함하지만, 이에 한정되지 않음)에 대해 이용자에 대한 배상 책임을 지지 않습니다.
        7. 당사는 본 앱의 이용 방법 등에서 이용자의 불찰이 있었을 경우, 그 결과로 이용자에게 발생한 불이익 또는 손해에 대해 일절 책임을 지지 않습니다.
        8. 본 앱은 당사가 이용자에 대해 본 앱을 실행하는 시점에서 당사에게 있어 제공 가능한 내용이며, 본 앱에 대해 하자가 없는 것임을 보증하지는 않습니다.
        9. 당사는 이용자가 본 앱을 이용하면서 얻은 본 앱 관련된 정보를 포함한 정보 등에 대해 그 내용의 진위, 유익성, 완전성, 적법성, 타당성, 신뢰성, 유용성, 정확성 등에 대해 일절 보증하지 않습니다.
        10. 당사는 이용자가 본 앱용 설비에 축적된 데이터 등(이용자 제공 정보를 포함)이 소실(이용자 본인에 의한 삭제도 포함)되거나 제삼자에 의해 변경되었더라도 해당 데이터를 복구할 의무를 포함하여, 일절 책임을 지지 않습니다. 또한, 다른 이용자가 다운로드한 이용자 제공 정보에 대해 발생한 행위(변경, 열람 등을 포함)에 대해 당사는 일절 책임을 지지 않습니다.
        11. 제1항부터 제10항의 규정에도 불구하고 적용 법령 또는 법원의 확정판결 등으로 본 규약에서 규정한 당사의 면책이 인정되지 않을 경우, 당사는 이용자가 직접적이고 현실적으로 입은 통상적인 손해에 한하여, 그에 따른 배상 책임을 집니다.

        **제16조(정보주체의 권익침해에 대한 구제방법)**

        정보주체는 개인정보침해로 인한 구제를 받기 위하여 개인정보분쟁조정위원회, 한국인터넷진흥원 개인정보침해신고센터 등에 분쟁해결이나 상담 등을 신청할 수 있습니다. 이 밖에 기타 개인정보침해의 신고, 상담에 대하여는 아래의 기관에 문의하시기 바랍니다.
        1. 개인정보분쟁조정위원회 : (국번없이) 1833-6972 ([www.kopico.go.kr](http://www.kopico.go.kr/))
        2. 개인정보침해신고센터 : (국번없이) 118 ([privacy.kisa.or.kr](http://privacy.kisa.or.kr/))
        3. 대검찰청 : (국번없이) 1301 ([www.spo.go.kr](http://www.spo.go.kr/))
        4. 경찰청 : (국번없이) 182 ([ecrm.cyber.go.kr](http://ecrm.cyber.go.kr/))
        「개인정보보호법」제35조(개인정보의 열람), 제36조(개인정보의 정정·삭제), 제37조(개인정보의 처리정지 등)의 규정에 의한 요구에 대 하여 공공기관의 장이 행한 처분 또는 부작위로 인하여 권리 또는 이익의 침해를 받은 자는 행정심판법이 정하는 바에 따라 행정심판을
        청구할 수 있습니다.
        ※ 행정심판에 대해 자세한 사항은 중앙행정심판위원회([www.simpan.go.kr](http://www.simpan.go.kr/)) 홈페이지를 참고하시기 바랍니다.

        **제17조(개인정보 처리방침 변경)**

        ① 이 개인정보처리방침은 2023년 9월 2부터 적용됩니다.
        """
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(label)
        NSLayoutConstraint.activate([
                   scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                   scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                   scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                   label.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
                   label.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
                   label.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
                   label.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
                   label.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40) // Ensures the label's width matches the scroll view's width with padding
               ])
    }
}
