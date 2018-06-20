# CallKit

**스팸전화는 모든 사람이 피하고 싶은 전화이다!**

위 정의는 모든 사람이 동의할 것입니다. 

모두가 피하고 싶은 스팸전화를 이미 여러 앱에서 모르는 번호에 대한 정보를 알려주는 기능을 제공하고 있습니다.

위 기능은 IOS 10.0 미만에서는 수신자의 번호를 알 수 없어서 구현이 힘들었습니다.

IOS 10.0 이상부터는 callKit을 지원하면서 수신 시 수신자의 번호를 얻어올 수 있도록 하였습니다.

제가 테스트한 앱의 최종 결과 화면을 보면 앱 이름 옆에 미리 설정한 번호에 해당하는 Label을 표시하고 있습니다.

이런 기능은 Call Directory Extension에서 전화번호 일치 유무를 검사하여 누구로부터 전화가 오는지 확인 할 수 있습니다.

제가 구현한 방식과 구현 하면서 어려웠던 점을 나누겠습니다.

<br/>

## callkit 적용 화면

```
[앱 이름] 발신자 정보 : [내용] 
```



![img](https://t1.daumcdn.net/cfile/tistory/99193A4A5A45BC9224)



<br/>

# CallKit Extension 사용하기

CallKit 을 어떻게 적용 할 수 있을 시 하나씩 알아보겠습니다.

<br/>

## **1. Call Directory Extension 생성**

1) Xcode 새 프로젝트 생성 후 [File] - [New] - [Target] 클릭 합니다.

2) Call Directory Extension 클릭 후 [Next] 누릅니다.

![img](https://t1.daumcdn.net/cfile/tistory/99501E405A4587E106)

3) Product Name을 입력 후 [Finish] 누릅니다.

<br/>

##  **2. addIdentificationPhoneNumbers 구현**

1) Call Directory Extension 로 생성한 swift 파일을 열어서 [addIdentificationPhoneNumbers] 함수로 이동합니다.

2) PhoneNumbers[CXCallDirectoryPhoneNumber] 와 labels[String]의 값을 변경합니다. 

  phoneNumbers은 수신 시 catch할 번호이며, label은 해당 catch된 번호의 표시할 이름을 적어줍니다.

  *(순서가 맞아야합니다.)*

<br/>

## **3. 앱 실행**

앱 실행 방식은 1) Xcode로 실행할 프로젝트 2) Call Directory Extension 로 생성한 프로젝트 순으로 실행합니다.

![img](https://t1.daumcdn.net/cfile/tistory/998E4E3F5A45880D2A)

![img](https://t1.daumcdn.net/cfile/tistory/9948473F5A45880D32)

3번까지 적용하면 내가 적용한 번호로 전화올 시 설정한 Label 값으로 화면에 표시하게 됩니다.

참고로 이미 저장된 번호일 경우 표시 안되니, 저장 안된 전호로 테스트 해야 합니다.

여기서 **문제점이 발생**합니다.

Call Directory Extension 로 생성한 프로젝트의 swift파일이 내용 변경 후 업데이트가 안되는 문제가 발생합니다. 

그래서 제가 해결한 방식은 두 가지로 하였습니다.

> 1. **프로젝트 번들 값을 변경**
>
> ​       프로젝트 번들 값을 변경하여 매번 새로운 값으로 로드하는 방식입니다.
>
> ​       일시적은 해결은 되나 앱 배포 시 데이터 업데이트 할 때마다 앱 배포 해야하는 문제점이 발생합니다.
>
> 1. **앱 실행 시 cxcalldirectorymanager 을 통한 reload 방식**
>
> ​      가장 보편적으로 사용하는 방식이고, 앱 배포 없이 앱 실행 시 reload 방식입니다.

AppDelegate 의 `didFinishLaunchingWithOptions()` 에서 다음 코드를 입력합니다.

```swift
let callDirManager = CXCallDirectoryManager.sharedInstancecallDirManager.reloadExtension(withIdentifier: "com.kcs.callkitExamples.CallDirectoryExtensions") {(error) in    
    if (error == nil){
        print("success!")  
    }else{
        print("error")
    }
}  
```

<br/>

# **3. 전화 차단 및 ID 등록**

디바이스에 해당 앱을 백그라운드로 돌려야 합니다.

아이폰 10.0 이상에서는 앱을 등록하여 전화 차단 및 ID을 체크하여 등록된 Label로 보여줍니다.

1.  앱 설치된 iPhone에서 설정 - 전화 - 전화 차단 및 ID  클릭 합니다.
2.  설치한 앱을 활성화 합니다.

![img](https://t1.daumcdn.net/cfile/tistory/9976D64A5A45885B03)

1. 설정한 번호로 전화 걸어 Label이 표시되는 것을 확인합니다.

<br/>

# CallKit 을 json 을 읽어와서 업데이트하는 방식

CallKit 을 json 을 읽어와서 업데이트하는 방식에 대해서 공유하겠습니다.

<br/>

### **1. 3개 이상의 데이터를 CallDirectory에 업데이트하는 방법**

CalDirectory.swift의 addIdentificationEntry(_) 에 등록하는데 있어서 3개 이상 등록하는데 이슈를 쉽게 발견할 수 있습니다.

1.  3개 이상 수신자 확인 데이터 등록
2. 설정 > 전화 > 전화 차단 및 ID 진입
3. 해당앱 On 시도 

위의 방식으로 수행 시 무한 로딩 화면 또는 "알림" 메시지로 "개발자에게 문의하세요." 라는 문구가 나옵니다.

해결 방안으로 두 가지 대안을 생각하였습니다.

```
1) 쓰레드로 별도로 돌려야 하는가? 
2) 데이터 넣을 때 마다 1초 딜레이를 주고 넣어야하는가? 
```

위 두가지 방안을 시도하였으나 문제는 해결되지 않았습니다.

Apple Developer 통해서 Custom 으로 동작하는 방식에 대해서 친절히 적혀있는 글을 발견했습니다.

```swift
class CustomCallDirectoryProvider: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        let labelsKeyedByPhoneNumber: [CXCallDirectoryPhoneNumber: String] = [ … ]
        for (phoneNumber, label) in labelsKeyedByPhoneNumber.sorted(by: <) {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
        }
        context.completeRequest()
    }
```

<br/>

```swift
labelsKeyedByPhoneNumber.sorted(by: <)
```

sorted을 해서 넣어주는 방식으로 3개 이상의 데이터를 넣을 수 있었습니다.

<br/>

### **2. Json 파일을 읽어서 업데이트 하는 방법**

현재 CallDirectiryExtension 은 AppDelegate와 별도의 폴더로 구성되어서 Json 파일 또한 CallDirectiryExtension 폴더 안에 넣어야 합니다.

1) 사용자가 작성한 Json 파일을 CallDirectiryExtension 폴더에 넣습니다.

**PhonDBData.json**

```json
[  
   {  
      "phoneNumber":"8211111111",
      "name":"Type_1"
   },
   {  
      "phoneNumber":"8200000000",
      "name":"Type_2"
   },
   {  
      "phoneNumber":"8233333333",
      "name":"Type_3"
   },
   {  
      "phoneNumber":"8244444444",
      "name":"Type_4"
   }
]
```

2) **CallDirectoryXX.swift**에 있는 `addIdentificationPhoneNumbers(_ CXCallDirectoryExtensionContext)`에서 json File을 가져옵니다.

   [JSON 파일 가져오기 (클릭)](http://faith-developer.tistory.com/entry/SWIFT3-Local-Json-File-%ED%98%B8%EC%B6%9C%ED%95%98%EA%B8%B0)

3) 가져온 json file을 labelsKeyedByPhoneNumber: [CXCallDirectoryPhoneNumber: String] 형태로 저장합니다.

```swift
var labelsKeyedByPhoneNumber: [CXCallDirectoryPhoneNumber: String] = [ : ]
for data in dbData {
    labelsKeyedByPhoneNumber[CXCallDirectoryPhoneNumber.init(data.phoneNumber)!] = data.name.replace(target: "_", withString: " "                                                                                            )}
```

4) 저장한 labelsKeyedByPhoneNumber을 addIdentificationEntry 에 저장하여 데이터를 업로드 합니다.

```swift
for (phoneNumber, label) in labelsKeyedByPhoneNumber.sorted(by: <) {
    context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
} 
```

<br/>

# 다양한 데이터를 CallKit 적용 하는 방법

<br/>

## **1. App Group 설정**

프로젝트 파일 > 앱(Callkit 각각) **TARGETS** 클릭 > Capablities > App Groups

**[그림1] Group Name 추가 방법**

![img](https://t1.daumcdn.net/cfile/tistory/995B7B445A45964019)

1. [그림1]에 보이는 화면으로 이동 하여 App Groups을  "On"으로 변경합니다.
2. App Groups의 '+ 버튼'이 보입니다. '+' 버튼을 클릭하여 App Group에 사용할 이름을 추가 합니다.

**[그림 2] CallKit Group 설정 화면** 

![img](https://t1.daumcdn.net/cfile/tistory/9962D7485A45964F26)

**[그림3] App Group  설정 화면**

![img](https://t1.daumcdn.net/cfile/tistory/99E3594D5A45965E26)

[그림2]과 [그림3]처럼 App Groups을 App과 Callkit 둘다 적용합니다.

<br/>

## **2. Groups ID 을 이용한 UserDefault**

UserDefaults을 suiteName에 Groups ID을 넣게 된다면 Groups으로 연결된 앱에서는 UserDefaults을 공동으로 사용할 수 있습니다.

```swift
UserDefaults(suiteName: "group.com.kcs.samepleCallkit")
```

샘플소스에서 사용한 방식은 json 파일을 class로 변경한 다음 class을 encode 하여 UserDefaults 에 넣어 CallKit 과 통신하도록 하였습니다.

```
Json > Class로 변경 > Archive > UserDefaults 에 넣음 > CallKit Project 
```

### **1. UserDefaults 저장 (App)**

```swift
// Group의 UserDefaults에 DB 데이터를 저장합니다.func saveUserData(){
let userDefaults = UserDefaults(suiteName: "group.com.kcs.samepleCallkit")
let userData = loadJsonFile()
try? userDefaults?.set(PropertyListEncoder().encode(userData), forKey: "dbData")}
// DB Data load Json File
func loadJsonFile() -> Array<UserData>{
    var dbData: Array<UserData> = Array<UserData>()
    do {
        if let file  = Bundle.main.url(forResource: "DBData", withExtension: "json"){
            let data  = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let objects = json as? [Any]{
                for object in objects {
                    dbData.append(UserData.dataFormJSONObject(json: object as! [String : AnyObject])!)
                }
            } else{
                print("JSON is invalid")
            }
        }else{
            print("no file")
        }
    }  catch {
        print(error.localizedDescription)
    }
    return dbData
} 
```

<br/>

### **2. UserDefaults 사용 (CallKit)**

```swift
//UserData는 보내는 부분과 받는 부분에 둘다 생성해줘야하는 문제가 있습니다.
//프레임워크로 설정을 하는 방식 또는 이번 샘플 소스처럼 두개를 만들어서 관리해야하는 방식 두가지로 나눠집니다.
if let data = userDefaults?.object(forKey:"dbData") as? Data {
    if let userData = try? PropertyListDecoder().decode([UserData].self, from: data) {
        for data in userData {
            //실직적인 데이터를 넣어주는 부분
            labelsKeyedByPhoneNumber[CXCallDirectoryPhoneNumber.init(data.phoneNumber)!] = data.name        }
    }}
//3개 이상으로 구성된 것은 다음과 같은 방식으로 sort 하여 설정합니다.
for (phoneNumber, label) in labelsKeyedByPhoneNumber.sorted(by: <) {
    context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)} 
```

> **PropertyListEncoder().encode**
>     Class Data를 UserDefault에서 Encode 할 때 사용
>
> **PropertyListDecoder().decode** 
>     Class Data를 UserDefault에서 Decode 할 때 사용

AppGroups 한 곳에서 UserDefault 을 공용으로 사용할 수 있기에 데이터 갱신을 실시간으로 할 수 있습니다. 위와 같은 Group 기능으로 "Widget" 도 데이터 통신으로 실시간 데이터로 업데이트 하고 있습니다. 

<br/>

# **정리**

CallKit 을 사용하는 방법에 대해서 알아봤습니다. 전체 소스코드는 [소스코드](https://github.com/FaithDeveloper/CallKit-iOS)에서 확인 할 수 있습니다.
