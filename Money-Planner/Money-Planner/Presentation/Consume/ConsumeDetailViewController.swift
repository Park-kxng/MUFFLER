// 소비 내역 조회 화면
import UIKit
import RxSwift
import RxCocoa

protocol ConsumeDetailViewDelegate : AnyObject {
    func changeDetail()
}

// 소비 수정 및 삭제 컨트롤러
class ConsumeDetailViewController: UIViewController, UITextFieldDelegate, CategorySelectionDelegate,CalendarSelectionDelegate,RepeatModalViewDelegate,AddCategoryViewDelegate {
    func AddCategoryCompleted(_ name: String, iconName: String) {
        print("카테고리 추가 반영 완료\(name)\(iconName)")
        cateogoryTextField.text = name
        cateogoryTextField.changeIcon(iconName: iconName)
        catAdd = true // 카테고리 선택된 것 반영

        view.layoutIfNeeded()
    }
    
    func didSelectCategory(id: Int64, category: String, iconName: String) {
        catAdd = true // 카테고리 선택된 것 반영
        cateogoryTextField.text = category
        cateogoryTextField.changeIcon(iconName: iconName)
        currentCategoryId = id
    }
    
    var expenseId: Int64 = 0
    var initExpense : ResponseExpenseDto.ExpenseDto?
    var currentCategoryId : Int64 = 0
    let StackView = UIStackView()

    // api 연결
    let disposeBag = DisposeBag()
    let viewModel = MufflerViewModel()
    var expenseRequest : UpdateExpenseRequest = UpdateExpenseRequest(expenseId: 0, expenseCost: 0, categoryId: 0, expenseTitle: "", expenseMemo: "", expenseDate: "")
    var currentAmount : Int64 = 0
    var currnetCal : String = ""
    // 반복
    var routineRequest : ExpenseCreateRequest.RoutineRequest?
    //

    func AddCategory() {
        let addCategoryVC = AddCategoryViewController(name: "", icon: "", id: -1)
        addCategoryVC.modalPresentationStyle = .fullScreen
        addCategoryVC.delegate = self
        present(addCategoryVC, animated: true)
    }
    
    
    let resultbutton : UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.setTitleColor(.mpDarkGray, for: .normal)
        button.titleLabel?.font = UIFont.mpFont16M()
        button.tintColor = UIColor.mpMainColor
        //button.backgroundColor = .mpGypsumGray // 수정 - 근영/ 텍스트 필드 배경 색상 F6F6F6
        button.setTitle("", for: .normal)
        button.isEnabled = false

        return button
    }()
    // 소비 등록 여부 확인 (메모 제외)
    var amountAdd = false
    var catAdd = false
    var titleAdd = false
    
    weak var delegate : ConsumeDetailViewDelegate?
    
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    lazy var todayDate: String = {
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: currentDate)
    }()
    private lazy var headerView = HeaderView(title: "소비내역 조회")
    private var completeButton = MainBottomBtn(title: "확인")
    //소비금액 입력필드 추가
    
    private let amountTextField: UITextField = MainTextField(placeholder: "소비금액을 입력하세요", iconName: "icon_Wallet", keyboardType: .numberPad)

    // 소비금액 실시간 금액 표시
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "0원"
        label.font = UIFont.mpFont14M()
        label.textColor = UIColor.mpDarkGray
        return label
    }()
    // 제목 에러 표시
    private let titleErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "\t 최대 16글자로 입력해주세요"
        label.font = .mpFont14M()
        label.textColor = UIColor.mpRed
        return label
    }()


    let catContainerView = TextFieldContainerView()
    let calContainerView = TextFieldContainerView()
    
    let titleDeleteContainer : UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .leading
        return v
    }()
    let memoDeleteContainer : UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .leading
        return v
    }()
    let cateogoryTextField = MainTextField(placeholder: "카테고리를 입력해주세요", iconName: "icon_category" , keyboardType: .default)
    
    // 카테고리 선택 버튼 추가
    lazy var categoryChooseButton: UIButton = {
        let button = UIButton()
        let arrowImage = UIImage(systemName:"chevron.down")?.withTintColor(.mpBlack, renderingMode: .alwaysOriginal)
        button.setImage(arrowImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true  // 클릭 활성화
        //button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(showCategoryModal), for: .touchUpInside) //클릭시 모달 띄우기
        return button
        
    }()
    
    @objc
    private func showCategoryModal() {
        print("클릭 : 카테고리 선택을 위해 카테고리 선택 모달로 이동합니다")
        // 카테고리 조회 하기
        viewModel.getCategoryFilter()
            .subscribe(onNext: { [weak self] repos in
                guard let self = self else { return }
                // 네트워크 응답에 대한 처리
                let categories = repos.result.categories
                let categoryModalVC = CategoryModalViewController(categories: categories)
                categoryModalVC.delegate = self
                self.present(categoryModalVC, animated: true)
            }, onError: { error in
                // 에러 처리
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
 
    let deleteButton: UIButton = {
        let arrowImage = UIImage(systemName: "xmark")?.withTintColor(.mpWhite, renderingMode: .alwaysOriginal)
        let button = UIButton()
        button.setImage(arrowImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.backgroundColor = .mpMidGray
        button.layer.cornerRadius = 9
        button.layer.masksToBounds = true
        
        return button
    }()
    
    @objc
    private func deleteTitle() {
        print("제목의 내용을 삭제합니다")
        titleTextField.text = ""
        titleDeleteContainer.removeArrangedSubview(deleteButton)
        deleteButton.removeFromSuperview()
        StackView.removeArrangedSubview(titleErrorLabel)
        titleErrorLabel.removeFromSuperview()
        titleTextField.layer.borderColor = UIColor.clear.cgColor
        titleTextField.layer.borderWidth = 0.0
    }
    let deleteButton2 : UIButton = {
        let arrowImage = UIImage(systemName: "xmark")?.withTintColor(.mpWhite, renderingMode: .alwaysOriginal)
        let button = UIButton()
        button.setImage(arrowImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.backgroundColor = .mpMidGray
        button.layer.cornerRadius = 9
        button.layer.masksToBounds = true
        //button.addTarget(self, action: #selector(delete), for: .touchUpInside)
        return button
    }()
    @objc
    private func deleteTitle2() {
        print("메모의 내용을 삭제합니다")
        memoTextField.text = ""
        memoDeleteContainer.removeArrangedSubview(deleteButton2)
        deleteButton2.removeFromSuperview()
    }
    private let titleTextField = MainTextField(placeholder: "제목", iconName: "icon_Paper", keyboardType: .default)
    private let memoTextField = MainTextField(placeholder: "메모", iconName: "icon_Edit", keyboardType: .default)
    private let calTextField = MainTextField(placeholder: "", iconName: "icon_date", keyboardType: .default)
    // 카테고리 선택 버튼 추가
    lazy var calChooseButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("오늘", for: .normal)
        button.titleLabel?.font = UIFont.mpFont20M()
        button.setTitleColor(UIColor.mpMainColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true  //클릭 활성화
        //button.backgroundColor = .red
        button.addTarget(self, action: #selector(showCalModal), for: .touchUpInside) //클릭시 모달 띄우기
        return button
        
    }()
    private lazy var checkButton : CheckBtn = {
        let checkButton = CheckBtn()
        checkButton.addTarget(self, action: #selector(showRepeatModal), for: .touchUpInside)
        return checkButton
    }()
    
    let containerview: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    
    let repeatLabel : UILabel = {
        let label = UILabel()
        label.text = "반복"
        label.font = UIFont.mpFont16R()
        label.textColor = UIColor.mpDarkGray
        return label
    }()
    
    
    
    @objc
    private func showCalModal() {
        print("클릭 : 소비날짜 버튼 클리")
        let calModalVC = CalendartModalViewController()
        calModalVC.delegate = self
        present(calModalVC, animated: true)
    }
    
    @objc
    private func showRepeatModal() {
        print(checkButton.isChecked)
        if checkButton.isChecked {
            print("반복 모달로 이동합니다")
            let repeatModalVC = RepeatModalViewController(currCal: currnetCal)
            repeatModalVC.delegate = self
            present(repeatModalVC, animated: true)
        }
        else{
            checkButton.isChecked = false
            resultbutton.isHidden = false
            resultbutton.setTitle("", for: .normal)
            resultbutton.backgroundColor = .clear
        }
    }
    
    @objc private func showRepeatModalResult() {
        print("반복 모달로 이동합니다")
        let repeatModalVC = RepeatModalViewController(currCal: currnetCal)
        repeatModalVC.routineRequest = routineRequest
        repeatModalVC.delegate = self
        present(repeatModalVC, animated: true)
    
    }
    
    func didSelectCalendarDate(_ date: String , api : String) {
        print("Selected Date in YourPresentingViewController: \(date)")
        calTextField.text = date
        currnetCal = api
        // 선택한 날짜가 오늘이 아닌 경우, 선택으로 달력 버튼 텍스트 변경
        // 오늘인 경우에는 오늘로 세팅
        if date == todayDate {
            // 선택한 날짜가 오늘인 경우
            calChooseButton.setTitle("오늘", for: .normal)
        }else{
            // 선택한 날짜가 오늘이 아닌 경우
            calChooseButton.setTitle("선택", for: .normal)
        }
    }
    
    
    
    // 이니셜라이저를 정의하여 expenseId를 전달 받을 수 있도록 합니다.
    init(expenseId: Int64) {
        self.expenseId = expenseId
        super.init(nibName: nil, bundle: nil)
        // 네트워크 요청을 통해 초기 데이터를 가져옵니다.
        viewModel.getExpense(expenseId: expenseId)
            .subscribe(onNext: { [weak self] expense in
                // 네트워크 응답에 대한 처리
                print("소비 내역 불러오기 성공!")
                print(expense)
                self?.initExpense = expense.result
                if let iconName = self?.initExpense?.categoryIcon {
                    self?.cateogoryTextField.changeIcon(iconName:iconName)

                }
                // 데이터를 설정하고 UI를 업데이트합니다.
                self?.setupData()
            }, onError: { error in
                // 에러 처리
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupUI()
    }
    
    private func setupUI() {
        // 배경색상 추가
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mpWhite")
        view.backgroundColor = .systemBackground
        hideKeyboardWhenTappedAround()
        
        // 완료 버튼 추가
        setupCompleteButton()
        setupLayout()
        // 헤더
        setupHeader()
        // 소비금액
        setupAmountTextField()
        // 카테고리
        setupCategoryTextField()
        // 제목
        setuptitleTextField()
        // 메모
        setupMemoTextField()
        // 날짜
        setupcalTextField()
        // 반복
        //setupRepeatButton()
        setupAmountLabel()
        setupData()
        deleteButton.addTarget(self, action: #selector(deleteTitle), for: .touchUpInside)
        deleteButton2.addTarget(self, action: #selector(deleteTitle2), for: .touchUpInside)

        memoTextField.delegate = self

        
    }
    // 세팅 : 초기 데이터 설정 및 UI 업데이트
    private func setupData() {
        if let expense = initExpense {
            currentAmount = expense.cost
            amountTextField.text = formatAmount(String(expense.cost))
            cateogoryTextField.text = expense.categoryName
            titleTextField.text = expense.title
            memoTextField.text = expense.memo
            currentCategoryId = expense.categoryId
            let dateString = expense.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                let convertedDateString = dateFormatter.string(from: date)
                if todayDate != convertedDateString {
                    calChooseButton.setTitle("선택", for: .normal)
                }
                calTextField.text = convertedDateString
          
            } else {
                print("날짜 변환 실패")
            }
        } else {
            amountTextField.text = ""
            cateogoryTextField.text = ""
            titleTextField.text = ""
            memoTextField.text = ""
            calTextField.text = ""
        }
       
        
    }
    
    // 세팅 : 헤더
    private func setupHeader(){
        //headerView.backgroundColor = .red
        headerView.addRightButton() // 오
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addBackButtonTarget(target: self, action: #selector(previousScreen), for: .touchUpInside)  // 이전 화면으로 돌아가기
        headerView.addRightButtonTarget(target: self, action: #selector(deleteExpense), for: .touchUpInside) // 소비 내역 삭제하기
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: StackView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: StackView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    @objc private func previousScreen(){
        dismiss(animated: true)
    }
    @objc private func deleteExpense(){
        print("소비 내역 삭제하기")
        // 네트워크 요청을 통해 초기 데이터를 가져옵니다.
        viewModel.deleteExpense(expenseId: expenseId)
            .subscribe(onNext: { repos in
                // 네트워크 응답에 대한 처리
                print("소비 내역 삭제하기 성공!")
                print(repos)
                
                NotificationCenter.default.post(name: Notification.Name("deleteExpense"), object: nil, userInfo: [
                    "expenseId" : Int(self.expenseId)])
                
            }, onError: { error in
                // 에러 처리
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
        dismiss(animated: true)
    }
   
    // 세팅 : 소비금액 추가
    private func setupAmountTextField() {
        if let expense = initExpense {
            amountTextField.text = String(expense.cost)
        } else {
            amountTextField.text = ""
        }
        NSLayoutConstraint.activate([
            amountTextField.heightAnchor.constraint(equalToConstant: 64),
            amountTextField.leadingAnchor.constraint(equalTo: StackView.leadingAnchor),
            amountTextField.trailingAnchor.constraint(equalTo: StackView.trailingAnchor)
        ])
        
        amountTextField.delegate = self
        amountTextField.translatesAutoresizingMaskIntoConstraints = false

        // 원 추가
        let infoLabel: UILabel = {
            let label = UILabel()
            label.text = "원"
            label.textColor = UIColor.mpDarkGray
            label.font = UIFont.mpFont20M()
            return label
        }()
        
        let wonContainerView = UIStackView()

        NSLayoutConstraint.activate([
   
            wonContainerView.widthAnchor.constraint(equalToConstant: 45),
            wonContainerView.heightAnchor.constraint(equalToConstant: 50),
        ])
        wonContainerView.addSubview(infoLabel)

        // Set the frame for infoLabel relative to wonContainerView
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
   
            infoLabel.leadingAnchor.constraint(equalTo: wonContainerView.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: wonContainerView.trailingAnchor),
            infoLabel.topAnchor.constraint(equalTo: wonContainerView.topAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: wonContainerView.bottomAnchor),
        ])
        // amountTextField의 rightAnchor를 이용하여 wonContainerView의 위치를 설정합니다.
        // 여백을 조절하여 텍스트 필드에서 원을 떨어뜨립니다.
        amountTextField.rightView = wonContainerView
        amountTextField.rightViewMode = .always
    
    }

    private func setupAmountLabel(){
       
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            amountLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    // 세팅 : 카테고리 텍스트 필트
    private func setupCategoryTextField(){
                NSLayoutConstraint.activate([
            
//            catContainerView.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 10),
                    catContainerView.leadingAnchor.constraint(equalTo: StackView.leadingAnchor),
                    catContainerView.trailingAnchor.constraint(equalTo: StackView.trailingAnchor),
            catContainerView.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        catContainerView.addSubview(buttonContainerView)
        
        NSLayoutConstraint.activate([
            buttonContainerView.widthAnchor.constraint(equalToConstant: 40),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 40),
            buttonContainerView.centerYAnchor.constraint(equalTo: catContainerView.centerYAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: catContainerView.trailingAnchor, constant: -16)
            
            
            
        ])
        buttonContainerView.addSubview(categoryChooseButton)
        
        // 클릭 되게 하려고.... 시도 중
        buttonContainerView.isUserInteractionEnabled = true
        self.view.bringSubviewToFront(categoryChooseButton)
        categoryChooseButton.isUserInteractionEnabled = true
        buttonContainerView.layer.zPosition = 999
        
        
        NSLayoutConstraint.activate([
            categoryChooseButton.widthAnchor.constraint(equalToConstant: 40),  // 버튼의 폭 제약 조건 추가
            categoryChooseButton.heightAnchor.constraint(equalToConstant: 40), // 버튼의 높이 제약 조건 추가
            categoryChooseButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            categoryChooseButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            categoryChooseButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            categoryChooseButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
        ])
        
        buttonContainerView.addSubview(cateogoryTextField)
        cateogoryTextField.translatesAutoresizingMaskIntoConstraints = false
        cateogoryTextField.isUserInteractionEnabled = false // 수정 불가능하도록 설정
        cateogoryTextField.textColor = UIColor.mpBlack
        cateogoryTextField.text = initExpense?.categoryName
        cateogoryTextField.backgroundColor = .clear
        NSLayoutConstraint.activate([
            
            cateogoryTextField.topAnchor.constraint(equalTo: catContainerView.topAnchor),
            cateogoryTextField.bottomAnchor.constraint(equalTo: catContainerView.bottomAnchor),
            cateogoryTextField.leadingAnchor.constraint(equalTo: catContainerView.leadingAnchor),
            cateogoryTextField.trailingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            
            
        ])
        
        
        
        
    }
    
    // 세팅 : 제목 텍스트 필트
    private func setuptitleTextField(){
        titleTextField.text = initExpense?.title
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.delegate = self
        
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: StackView.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: StackView.trailingAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 64)
        ])
        // 삭제 버튼 추가
        NSLayoutConstraint.activate([
   
            titleDeleteContainer.widthAnchor.constraint(equalToConstant: 45),
            titleDeleteContainer.heightAnchor.constraint(equalToConstant: 18),
        ])

        // Set the frame for infoLabel relative to wonContainerView
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //deleteButton.centerYAnchor.constraint(equalTo: titleDeleteContainer.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 18),
            deleteButton.heightAnchor.constraint(equalToConstant: 18),
           
        ])
        // amountTextField의 rightAnchor를 이용하여 wonContainerView의 위치를 설정합니다.
        // 여백을 조절하여 텍스트 필드에서 원을 떨어뜨립니다.
        titleTextField.rightView = titleDeleteContainer
        titleTextField.rightViewMode = .always
        
    }
    
    
    // 세팅 : 메모 텍스트 필트
    private func setupMemoTextField() {
        memoTextField.text = initExpense?.memo
        memoTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            memoTextField.leadingAnchor.constraint(equalTo: StackView.leadingAnchor),
            memoTextField.trailingAnchor.constraint(equalTo: StackView.trailingAnchor),
            memoTextField.heightAnchor.constraint(equalToConstant: 64)
        ])
        // 삭제 버튼 추가
        NSLayoutConstraint.activate([
   
            memoDeleteContainer.widthAnchor.constraint(equalToConstant: 45),
            memoDeleteContainer.heightAnchor.constraint(equalToConstant: 18),
        ])

        // Set the frame for infoLabel relative to wonContainerView
        deleteButton2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //deleteButton.centerYAnchor.constraint(equalTo: titleDeleteContainer.centerYAnchor),
            deleteButton2.widthAnchor.constraint(equalToConstant: 18),
            deleteButton2.heightAnchor.constraint(equalToConstant: 18),
           
        ])
        // amountTextField의 rightAnchor를 이용하여 wonContainerView의 위치를 설정합니다.
        // 여백을 조절하여 텍스트 필드에서 원을 떨어뜨립니다.
        memoTextField.rightView = memoDeleteContainer
        memoTextField.rightViewMode = .always
    }
    // 세팅 : 달력 텍스트 필트
    private func setupcalTextField(){
        NSLayoutConstraint.activate([
            
            calContainerView.leadingAnchor.constraint(equalTo: StackView.leadingAnchor),
            calContainerView.trailingAnchor.constraint(equalTo: StackView.trailingAnchor),
            calContainerView.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        let calbuttonContainerView = UIView()
        calbuttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        calContainerView.addSubview(calbuttonContainerView)
        
        NSLayoutConstraint.activate([
            calbuttonContainerView.widthAnchor.constraint(equalToConstant: 40),
            calbuttonContainerView.heightAnchor.constraint(equalToConstant: 40),
            calbuttonContainerView.centerYAnchor.constraint(equalTo: calContainerView.centerYAnchor),
            calbuttonContainerView.trailingAnchor.constraint(equalTo: catContainerView.trailingAnchor, constant: -16)
            
            
            
        ])
        calbuttonContainerView.addSubview(calChooseButton)
        
        // 클릭 가능하게 함
        calbuttonContainerView.isUserInteractionEnabled = true
        calChooseButton.isUserInteractionEnabled = true
        calbuttonContainerView.layer.zPosition = 999
        
        
        NSLayoutConstraint.activate([
            calChooseButton.widthAnchor.constraint(equalToConstant: 40),  // 버튼의 폭 제약 조건 추가
            calChooseButton.heightAnchor.constraint(equalToConstant: 40), // 버튼의 높이 제약 조건 추가
            calChooseButton.leadingAnchor.constraint(equalTo: calbuttonContainerView.leadingAnchor),
            calChooseButton.trailingAnchor.constraint(equalTo: calbuttonContainerView.trailingAnchor),
            calChooseButton.topAnchor.constraint(equalTo: calbuttonContainerView.topAnchor),
            calChooseButton.bottomAnchor.constraint(equalTo: calbuttonContainerView.bottomAnchor)
        ])
        
        calContainerView.addSubview(calTextField)
        calTextField.translatesAutoresizingMaskIntoConstraints = false
        calTextField.isUserInteractionEnabled = false // 수정 불가능하도록 설정
        calTextField.textColor = UIColor.mpBlack
        
        
        
        NSLayoutConstraint.activate([
            
            calTextField.topAnchor.constraint(equalTo: calContainerView.topAnchor),
            calTextField.bottomAnchor.constraint(equalTo: calContainerView.bottomAnchor),
            calTextField.leadingAnchor.constraint(equalTo: calContainerView.leadingAnchor),
            calTextField.trailingAnchor.constraint(equalTo: calbuttonContainerView.leadingAnchor),
            
            
        ])
      
    }
    
    private func setupLayout(){
        StackView.axis = .vertical
        StackView.distribution = .fill
        StackView.alignment = .leading
        StackView.spacing = 12
        
        view.addSubview(StackView)
        StackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            StackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            StackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            StackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            StackView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: 10)
        ])
        StackView.addArrangedSubview(headerView)
        StackView.addArrangedSubview(amountTextField)
        StackView.addArrangedSubview(catContainerView)
        StackView.addArrangedSubview(titleTextField)
        StackView.addArrangedSubview(memoTextField)
        StackView.addArrangedSubview(calContainerView)

        let blank = UIView()
        StackView.addArrangedSubview(blank)


    }
    // 세팅 : 완료 버튼
    private func setupCompleteButton(){
        completeButton.isEnabled = true
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)    }
    // UITextFieldDelegate 메서드 구현
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if the current text field is amountTextField
        if textField == amountTextField {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal // 1,000,000
            formatter.locale = Locale.current
            formatter.maximumFractionDigits = 0 // 허용하는 소숫점 자리수
            // 입력 중인 금액 업데이트
            // formatter.groupingSeparator // .decimal -> ,
            
            
            
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            print(newText)
            amountTextField.layer.borderColor = UIColor.clear.cgColor
            amountTextField.layer.borderWidth = 0.0
            // 입력된 것이 없는 경우
            if newText.isEmpty{
                StackView.removeArrangedSubview(amountLabel)
                amountLabel.removeFromSuperview()
            }
            // 입력된 금액이 있는 경우
            else{
                // amountLabel
                StackView.insertArrangedSubview(amountLabel, at: 2)
                amountAdd = true // 입력된 것이 있는 것 확인

                // 유효한 숫자인 경우
                amountLabel.textColor = UIColor.mpDarkGray
                // 소비금액 텍스트필드에 에러 표시 취소 - 빨간색 스트로크
                amountTextField.layer.borderColor = UIColor.clear.cgColor
                amountTextField.layer.borderWidth = 0.0
                
                if let removeAllSeprator = textField.text?.replacingOccurrences(of: formatter.groupingSeparator, with: "") {
                    let beforeForemattedString = removeAllSeprator + string
                    // api 연결을 위한 소비금액 저장
                    if let amount = Int64(beforeForemattedString) {
                        currentAmount = amount
                    } else {
                        // Handle the case where the conversion fails
                        print("Failed to convert string to Int64")
                    }
                    // 입력된 문자열이 숫자가 아닌 경우
                    if !beforeForemattedString.isEmpty && !beforeForemattedString.allSatisfy({ $0.isNumber }) {
                        
                        print("유효한 숫자가 아님 : ")
                        amountLabel.text = "    유효한 숫자가 아닙니다."
                        amountLabel.textColor = UIColor.mpRed
                        // 소비금액 텍스트필드에 에러 표시 - 빨간색 스트로크
                        amountTextField.layer.borderColor = UIColor.mpRed.cgColor
                        amountTextField.layer.borderWidth = 1.0
                        return false
                    }
                    let digitOfAmount = String(describing: beforeForemattedString).count
                    // 소비금액 텍스트필드에 에러 표시 취소 - 빨간색 스트로크
                    
                    
                    // 입력할 수 있는 범위를 초과한 경우
                    if digitOfAmount > 16 {
                        // 소비금액 보여주는 곳에 에러 메세지 표시
                        amountLabel.text = "\t입력할 수 있는 범위를 초과했습니다."
                        amountLabel.textColor = .red
                        // 소비금액 텍스트필드에 에러 표시 - 빨간색 스트로크
                        amountTextField.layer.borderColor = UIColor.mpRed.cgColor
                        amountTextField.layer.borderWidth = 1.0
                        
                        return false // 더 이상 입력할 수 없도록 함
                        
                        // 입력할 수 있는 범위인 경우
                    } else {
                        
                        amountLabel.text = "\t\(numberToKorean(Int(beforeForemattedString)!))원" // 숫자 -> 한국어로 변경하여 입력함
                        // 소비금액 텍스트필드에 에러 표시 취소 - 빨간색 스트로크
                        amountTextField.layer.borderColor = UIColor.clear.cgColor
                        amountTextField.layer.borderWidth = 0.0
                        if let removeAllSeprator = textField.text?.replacingOccurrences(of: formatter.groupingSeparator, with: ""){
                            var beforeForemattedString = removeAllSeprator + string
                            if formatter.number(from: string) != nil {
                                if let formattedNumber = formatter.number(from: beforeForemattedString), let formattedString = formatter.string(from: formattedNumber){
                                    textField.text = formattedString
                                    return false
                                }
                            }else{ // 숫자가 아닐 때먽
                                if string == "" { // 백스페이스일때
                                    let lastIndex = beforeForemattedString.index(beforeForemattedString.endIndex, offsetBy: -1)
                                    beforeForemattedString = String(beforeForemattedString[..<lastIndex])
                                    if let formattedNumber = formatter.number(from: beforeForemattedString), let formattedString = formatter.string(from: formattedNumber){
                                        textField.text = formattedString
                                        return false
                                    }
                                }else{ // 문자일 때
                                    return false
                                }
                            }
                            
                        }
                    }
                }
                
                return true
            }
        } else if textField == titleTextField {
            // Handle character count limit for titleTextField
            // Calculate the resulting text after replacement
            guard let text = textField.text else { return false }
            let newText = (text as NSString).replacingCharacters(in: range, with: string)
            
            if !newText.isEmpty {
                titleAdd = true // 입력된 것이 있는 것 확인
                if titleDeleteContainer.arrangedSubviews.contains(deleteButton) == false {
                    print("추가 완료")
                           titleDeleteContainer.addArrangedSubview(deleteButton)
                       }
            }
            else{
                titleDeleteContainer.removeArrangedSubview(deleteButton)
                deleteButton.removeFromSuperview()
            }

            
            // Apply character count limit
            if newText.count > 16 {
                // 소비금액 텍스트필드에 에러 표시 - 빨간색 스트로크
                titleTextField.layer.borderColor = UIColor.mpRed.cgColor
                titleTextField.layer.borderWidth = 1.0
                view.addSubview(titleErrorLabel)
                titleErrorLabel.translatesAutoresizingMaskIntoConstraints = false
                // titleErrorLabel 레이아웃에 추가
                // 제목 텍스트 필드의 인덱스 찾기222
                if let index = indexOfLabel(text : titleTextField) {
                    StackView.insertArrangedSubview(titleErrorLabel, at: 2)
                }
                
                return false
            }else{
                
                StackView.removeArrangedSubview(titleErrorLabel)
                titleErrorLabel.removeFromSuperview()
                titleTextField.layer.borderColor = UIColor.clear.cgColor
                titleTextField.layer.borderWidth = 0.0
                return true
            }
            
        }else if textField == memoTextField {
            guard let text = textField.text else { return false }
            let newText = (text as NSString).replacingCharacters(in: range, with: string)
            
            if !newText.isEmpty {
                if memoDeleteContainer.arrangedSubviews.contains(deleteButton2) == false {
                    print("추가 완료")
                    memoDeleteContainer.addArrangedSubview(deleteButton2)
                }
            }
            else{
                memoDeleteContainer.removeArrangedSubview(deleteButton2)
                deleteButton2.removeFromSuperview()
            }
            return true
        }
        
        return true
    }
    // 인덱스 찾아내는 함수
    func indexOfLabel(text : MainTextField) -> Int? {
            return StackView.arrangedSubviews.firstIndex { view in
                if let i = view as? MainTextField, i == titleTextField {
                    return true
                }
                return false
            }
        }
    // 숫자 천단위로 끊는 함수
    func formatAmount(_ amountString: String) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if let number = formatter.number(from: amountString)?.intValue {
            let formattedAmount = formatter.string(from: NSNumber(value: number))
            return formattedAmount
        }

        return nil
    }
    
    //숫자를 한글로 표현하는 함수(2000 -> 0부터 9999999999999999까지가능)
    func numberToKorean(_ number: Int) -> String {
        let unitLarge = ["", "만", "억", "조"]
        
        var result = ""
        var num = number
        var unitIndex = 0
        
        while num > 0 {
            let segment = num % 10000
            if segment != 0 {
                result = "\((segment))\(unitLarge[unitIndex]) \(result)"
            }
            num /= 10000
            unitIndex += 1
        }
        
        return result.isEmpty ? "0" : result
    }
    
    func GetResultofInterval(_ result: String, api : ExpenseCreateRequest.RoutineRequest?) {
        print("버튼에 데이터 반영합니다 \(result)")
        let repeatResult = result
        resultbutton.setTitle("  \(repeatResult)  ", for: .normal)
        resultbutton.backgroundColor = .mpGypsumGray
        resultbutton.isEnabled = true
        view.layoutIfNeeded()
        routineRequest = api
    }
    
    

    
    @objc
    private func completeButtonTapped(){
        print("수정이 완료되었습니다")
        print(expenseId)
        let currDay : String
        // 제로데이인지 확인
    
        // api 연결
        expenseRequest.expenseId = expenseId
        expenseRequest.categoryId = currentCategoryId
        expenseRequest.expenseCost = currentAmount
        expenseRequest.expenseDate = currnetCal
    
        struct ZeroDayRequest{
            var dailyPlanDate : String
        }
        print(expenseRequest)
        do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted // JSON을 읽기 쉽게 출력하기 위해 prettyPrinted를 사용합니다.
                let jsonData = try encoder.encode(expenseRequest)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            } catch {
                print("Error encoding JSON: \(error)")
            }
        // 제로데이 확인
        dismiss()
        
        
        
    }
    private func dismiss(){
        viewModel.updateExpense(expenseRequest: expenseRequest)
            .subscribe(
            onSuccess: { response in
                print(response)
                self.delegate?.changeDetail()
            }, onFailure: {error in
                print(error)
            }).disposed(by: disposeBag)
        
        dismiss(animated: true)
    }
    
}
// 키보드 숨기기
extension ConsumeDetailViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ConsumeDetailViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
