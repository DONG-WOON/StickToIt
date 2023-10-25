# 작심 삼일

## 앱 소개 및 기능
> 해야지~ 생각만하고 못이룬 목표들을 오늘부터 3일만이라도 당장 실행하세요!

 - 목표 설정, 3일 이상의 목표 달성 기록 앱</br>
 - 사진 인증, 이미지에 문장 추가 편집기능</br>
 - 다크모드 지원

## 호환성
iOS 15.0 ~

## 기간
2023.09.25 ~ 

## 업데이트 예정
- 사용자 커뮤니티
- 태그 기능
- 푸시 알림
- 위젯

## 스크린 샷
|<img src="https://github.com/DONG-WOON/StickToIt/assets/80871083/6465b944-28b3-47a7-b768-9f2eaf477346" width=220>|<img src="https://github.com/DONG-WOON/StickToIt/assets/80871083/48646356-450b-46f6-9fb8-31bc1d318b69" width=220>|<img src="https://github.com/DONG-WOON/StickToIt/assets/80871083/da2daa46-cf56-49e9-b034-6180915635e1" width=220>|
|:-:|:-:|:-:|
|홈 화면|목표 생성|캘린더|
</br>

|<img src="https://github.com/DONG-WOON/StickToIt/assets/80871083/91458add-2819-4401-8f04-438d35238965" width=220>|<img src="https://github.com/DONG-WOON/StickToIt/assets/80871083/debbd251-332d-422b-9af6-66d1c9b401c0" width=220>|<img src="https://github.com/DONG-WOON/StickToIt/assets/80871083/7fd17ffe-46fe-49c1-8b44-4cdfdbf446e2" width=220>|
|:-:|:-:|:-:|
|목표달성률|인증화면|이미지 편집|


## 핵심 기능
- 일일 목표 데이터 관리 | Realm CRUD
- 사용자 사진 업로드 | PhotoKit
- 사용자 사진 편집 | UIGestureRecognizer

## 기술스택 
|          아키텍처            |   프레임워크  |       라이브러리        |
|            --              |     --     |     --               |
|     Clean Architecture     |   UIKit    |      FSCalendar     |
|           MVVM             |   PhotoKit |       Realm          | 
|                            |            |        MKRingProgressView    |
|                            |            |           RxSwift           |
|                            |            |           SnapKit           |
+ CompositionalLayout + DiffableDataSource
+ UIVisualEffectView
+ protocol을 associatedtype을 사용하여 generic하게 추상화

## 트러블 슈팅

### [ImageManager로 CollectionView에 사용자 선택 이미지 업데이트](https://github.com/DONG-WOON/StickToIt/commit/7d824089d35b5d5184f96c28808fedb68bc9305a)
- 상황: Snapshot, apply시 모델을 갱신해주지 않아서 Index out of range처럼 supplied item identifiers are not unique 런타임 에러 발생
- 이유: Data타입을 사용, 모델이 Hashable 하지 않고, 동일한 data를 받아왔기 때문에 발생
- 해결: 애플이 내부적으로 Image Asset의 ID로 사용하고 있는 localIdentifier를 사용, ViewModel의 imageData의 타입을 PHAsset으로 수정
- 
### [FSCalendar의 선택된 날짜와 요일 비교 불가](https://github.com/DONG-WOON/StickToIt/commit/a60bcc0582c6d1ad0fb86df33fc78f944620f89b)
- 상황: FSCalendar 사용시 출력되는 날짜가 현재 실제 날짜와 불일치
- 이유: Date는 달력이나 시간대와 무관하게 특정 시점이기때문
- 해결: DateFormatter의 convertDate(:)함수를 사용하여 필요한 부분에서는 format하도록 처리

### [다중 백그라운드 작업 직렬화](https://github.com/DONG-WOON/StickToIt/commit/0d9c88e46a30826d2ddfde0f1a515755c3485948)
- 상황
    1. aync/awit를 활용한 비동기 작업을 진행, 인증과 동시에 사진업로드, 업로드한 파일 URL Entity에 저장
    2. 중간에 문제가 생기면 사용자가 나중에 다시 돌아왔을때 인증은했으나 사진이 없는 경우처럼 엣지케이스 존재
- 해결
    1. Error Case를 나누고 UserDefaults로 어느 시점에서 실패했는지 저장
    2. 해당 화면으로 돌아올 경우, 그대로 작업 할 수 있도록 변경</br>
    `+` 에러 처리는 Error Branch에서 따로 정리예정    
## 회고
[배운점]
1. usecase, repository에 protocol을 적용하여 인터페이스로 의존성 역전, where(Conditionally Conforming)을 사용하여 특정한 프로토콜로 제한
2. CRUD 기능별 Service protocol 정의, 필요에 따라 채택하여 usecase 사용
3. RXSwift와 Input/Output 패턴으로 코드의 가독성 향상, 비동기 데이터 처리

[아쉬운점]
1. MVVM + clean architecture로 설계하면서 UseCase의 분리 기준과 목적의 부재로 작업 시간 딜레이</br>
2. 초기 DB테이블 세팅과 다르게 앱의 기능 추가/삭제로 빈번한 수정

