import Foundation
import Combine

class ConsumeViewModel {
    
    // TODO:  현재 카테고리 리스트 가져오기
    func getCategoryList() -> [CategoryDTO] {
        return GetCategoryListResponse(categories: [CategoryDTO(categoryId: 0, name: "예시", icon: "beauty")]).categories
    }
    
    // TODO: 소비 등록 - 매개변수로 현재 입력받은 값을 받아야 함.
    func createExpense() {
        print("소비등록")
        // 이전 코드 -> 알림 어떤 식으로 줘야 하는지 참고
//        viewModel.createExpense(expenseRequest: expenseRequest)
//            .subscribe(
//            onSuccess: { response in
//                print(response)
//                if let expenseResponse = response.result {
//                    print(expenseResponse)
//                    if let alarms = expenseResponse.alarms {
//                        if alarms.count == 0 {
//                            print("알람이 없음")
//                            self.dismissView()
//                        } else {
//                            for alarm in alarms {
//                                if let alarmTitle = alarm.alarmTitle, let budget = alarm.budget, let excessAmount = alarm.excessAmount {
//                                    print(alarmTitle)
//                                    print(budget)
//                                    print(excessAmount)
//                                    // 여기서 알람을 보여주는 작업을 수행합니다.
//                                    
//                                    if self.presentedViewController == nil {
//                                        let alert = ExpensePopupModalView()
//                                        alert.delegate = self
//                                        self.present(alert, animated: true) {
//                                            if alarmTitle == "DAILY" {
//                                                alert.changeTitle(title: "하루 목표금액을 초과했어요")
//                                                alert.changeContents(content: "목표한 소비 금액 \(budget)원보다 \n \(excessAmount)원 더 썼어요!")
//                                            } else if alarmTitle == "CATEGORY" {
//                                                let category = self.cateogoryTextField.text ?? "카테고리 없음"
//                                                alert.changeTitle(title: "\(category) 목표금액을 초과했어요")
//                                                alert.changeContents(content: "목표한 \(category) 금액 \(budget)원보다 \n \(excessAmount)원 더 썼어요!")
//                                            } else if alarmTitle == "TOTAL" {
//                                                alert.changeTitle(title: "전체 목표금액을 초과했어요")
//                                                alert.changeContents(content: "목표한 금액 \(budget)원보다 \n \(excessAmount)원 더 썼어요!")
//                                            }
//                                        }
//                                    } else {
//                                        // Handle the case where a view is already presented
//                                        print("A view is already being presented. Skipping presentation.")
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                self.sendNotificationEvent(cost: self.expenseRequest.expenseCost)
//            }, onFailure: {error in
//                print(error)
//            }).disposed(by: disposeBag)
    }
}
