//
//  AppNetworking.swift
//  FutureNow
//
//  Created by MacMini-iOS on 18/07/19.
//  Copyright © 2019 Quytech. All rights reserved.
//


import Foundation
import SwiftyJSON
import Alamofire
import Photos
import ObjectMapper
import Security
import SwiftUI
import PKHUD


typealias HttpClientSuccess = (Any?) -> ()
typealias HttpClientFailure = (String) -> ()
typealias Completion = (Response) -> ()

typealias JSONDictionary = [String : Any]
typealias JSONDictionaryArray = [JSONDictionary]
typealias SuccessResponse = (_ json : JSON) -> ()
typealias FailureResponse = (NSError) -> (Void)
typealias ResponseMessage = (_ message : String) -> ()
typealias DownloadData = (_ data : Data) -> ()
typealias UploadFileParameter = (fileName: String, key: String, data: Data, mimeType: String)


var manager = SessionManager()

extension Notification.Name {
    static let NotConnectedToInternet = Notification.Name("NotConnectedToInternet")
}

enum AppNetworking {
    
    static let username = "admin"
    static let password = "12345"
    
    static func POST(endPoint : String,
                     parameters : JSONDictionary = [:],
                     parameterArray: JSONDictionaryArray = [],
                     headers : HTTPHeaders = [:],
                     loader : Bool = true,
                     completion : @escaping Completion) {
        
        request(URLString: endPoint, httpMethod: .post, parameters: parameters, parameterArray: parameterArray, headers: headers, loader: loader, completion: completion)
    }
    
    static func POSTWithFiles(endPoint : String,
                              parameters : [String : Any] = [:],
                              files : [UploadFileParameter] = [],
                              headers : HTTPHeaders = [:],
                              loader : Bool = true,
                              completion : @escaping Completion) {
        
        //        upload(URLString: endPoint, httpMethod: .post, parameters: parameters, files: files, headers: headers, loader: loader, completion: completion)
    }
    
    static func GET(endPoint : String,
                    parameters : JSONDictionary = [:],
                    headers : HTTPHeaders = [:],
                    loader : Bool = true,
                    completion : @escaping Completion) {
        
        request(URLString: endPoint, httpMethod: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: headers, loader: loader, completion: completion)
    }
    
    static func UPLOAD(endPoint : String,
                       parameters : JSONDictionary = [:],
                       headers : HTTPHeaders = [:],
                       files: [AttachmentInfo],
                       loader : Bool = true,
                       completion : @escaping Completion) {
        uploadRequest(URLString: endPoint, httpMethod: .post, parameters: parameters, files: files, completion: completion)
    }
    
    //    static func UPLOAD(endPoint : String,
    //                    parameters : JSONDictionary = [:],
    //                    headers : HTTPHeaders = [:],
    //                    files: [AttachmentInfo],
    //                    loader : Bool = true,
    //                    completion : @escaping Completion) {
    //        uploadRequest(URLString: endPoint, httpMethod: .post, parameters: parameters, files: files, loader: loader, completion: completion)
    //    }
    
    static func PUT(endPoint : String,
                    parameters : JSONDictionary = [:],
                    headers : HTTPHeaders = [:],
                    loader : Bool = true,
                    completion : @escaping Completion) {
        
        request(URLString: endPoint, httpMethod: .put, parameters: parameters, headers: headers, loader: loader, completion: completion)
    }
    
    static func PATCH(endPoint : String,
                      parameters : JSONDictionary = [:],
                      encoding: URLEncoding = URLEncoding.httpBody,
                      headers : HTTPHeaders = [:],
                      loader : Bool = true,
                      completion : @escaping Completion) {
        
        request(URLString: endPoint, httpMethod: .patch, parameters: parameters, encoding: encoding, headers: headers, loader: loader, completion: completion)
    }
    
    static func DELETE(endPoint : String,
                       parameters : JSONDictionary = [:],
                       headers : HTTPHeaders = [:],
                       loader : Bool = true,
                       completion : @escaping Completion) {
        
        request(URLString: endPoint, httpMethod: .delete, parameters: parameters, headers: headers, loader: loader, completion: completion)
    }
    
    private static func request(URLString : String,
                                httpMethod : HTTPMethod,
                                parameters : JSONDictionary = [:],
                                parameterArray: JSONDictionaryArray = [],
                                encoding: ParameterEncoding = JSONEncoding.default,
                                headers : HTTPHeaders = [:],
                                loader : Bool = true,
                                completion : @escaping Completion) {
        
        if loader { ProgressHud.showActivityLoader() }
        
        makeRequest(URLString: URLString, httpMethod: httpMethod, parameters: parameters, parameterArray: parameterArray, encoding: encoding, headers: headers, loader: loader, success: { (data) in
            if loader { ProgressHud.hideActivityLoader() }
            guard let response = data else {
                completion(Response.failure(.none))
                return
            }
            
            let json = JSON(response)
            if json[APIConstants.code].stringValue == Validate.invalidAccessToken.rawValue{
                tokenExpired()
                return
            }
            //            if json[APIConstants.code].stringValue == Validate.adminBlocked.rawValue{
            //                adminBlocked()
            //                return
            //            }
            
            let responseType = Validate.link(code: json[APIConstants.code].stringValue)
            
            switch responseType {
            case .success:
                return completion(Response.success(response))
                
            case .failure:
                completion(Response.failure(json[APIConstants.message].stringValue))
                
            default :
                break
            }
        }, failure: { message in
            if loader { ProgressHud.hideActivityLoader() }
            completion(Response.failure(message))
        })
    }
    
    private static func uploadRequest(URLString : String,
                                      httpMethod : HTTPMethod,
                                      parameters : JSONDictionary = [:],
                                      files: [AttachmentInfo],
                                      encoding: ParameterEncoding = JSONEncoding.default,
                                      headers : HTTPHeaders = [:],
                                      loader : Bool = true,
                                      completion : @escaping Completion) {
        
        if loader { ProgressHud.showActivityLoader() }
        
        upload(URLString: URLString, httpMethod: httpMethod, parameters: parameters, files: files, success: { (data) in
            if loader { ProgressHud.hideActivityLoader() }
            guard let response = data else {
                completion(Response.failure(.none))
                return
            }
            
            var json = JSON(response)
            let responsess = Mapper<ResponseData<Initial>>().map(JSONObject:data)
            
            let dataDict = json["data"]
            let errorDict = dataDict["error"]
            let emailError = errorDict["email_id"]
            let mobileError = errorDict["mobile_number"]
            
            
            //  let errorResponse = Mapper<ResponseData<Initial>>().map(JSONObject: error)
            
            if json[APIConstants.code].stringValue == Validate.invalidAccessToken.rawValue{
                tokenExpired()
                return
            }
            if json[APIConstants.code].stringValue == Validate.adminBlocked.rawValue{
                adminBlocked()
                return
            }
            
            //  let responseType = Validate(rawValue: json[APIConstants.code].stringValue) ?? .failure
            
            var responseMessage = Validate(rawValue: json[APIConstants.message].stringValue)
            if emailError.stringValue != ""{
                json[APIConstants.message].stringValue = emailError.stringValue
                //  responseMessage = Validate(rawValue: emailError.stringValue)
            }else if (mobileError.stringValue != ""){
                json[APIConstants.message].stringValue = mobileError.stringValue
                //    responseMessage = Validate(rawValue: emailError.stringValue)
            }
            //  let responseType = Validate(rawValue: emailError.stringValue) ?? .failure
            let responseType = Validate.link(code: json[APIConstants.code].stringValue)
            
            //  let responseType = Validate(rawValue: json[APIConstants.code].stringValue) ?? .failure
            
            
            switch responseType {
            case .success:
                return completion(Response.success(response))
                
            case .failure:
                completion(Response.failure(json[APIConstants.message].stringValue))
            default : break
            }
        }, failure: { message in
            if loader { ProgressHud.hideActivityLoader() }
            completion(Response.failure(message))
        })
        
    }
    
    private static func tokenExpired() {
        let user = AuthManager.shared.loggedInUser
        AuthManager.shared.loggedInUser = user
        AuthManager.shared.loggedInUser = nil
        if let vc = UIStoryboard.auth.get(LoginViewController.self) {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APPDELEGATE.window?.rootViewController = navigationController
        }
    }
    
    private static func adminBlocked() {
        
    }
    
    private static func makeRequest(URLString : String,
                                    httpMethod : HTTPMethod,
                                    parameters : JSONDictionary = [:],
                                    parameterArray: JSONDictionaryArray = [],
                                    encoding: ParameterEncoding = JSONEncoding.default,
                                    headers : HTTPHeaders = [:],
                                    loader : Bool = true,
                                    success : @escaping HttpClientSuccess ,
                                    failure : @escaping HttpClientFailure) {
        
        var header : [String: String] = [:]
        let accessToken = AuthManager.shared.loggedInUser?.auth_token ?? ""
        if !accessToken.isEmpty {
            //  header["Authorization"] = "Bearer \(accessToken)"
            header["Authorization"] = "\(accessToken)"
            header["Content-Type"] = "application/json"
        } else {
            header = headers
        }
        
        Debug.log(("===== HEADERS ===="))
        Debug.log("\(header)")
        let updatedHeaders : HTTPHeaders = header
        
        let serverTrustPolicyWithKey : [String: ServerTrustPolicy] = ["quytech.net" : .pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: true, validateHost: true)]

        /*guard let pathToCert = Bundle.main.path(forResource: "quytech_ssl.cer", ofType: nil) else {
            Debug.log("==== pathToCert not found ====")
            return
        }
            
        guard let localCertificate:NSData = NSData(contentsOfFile: pathToCert)  else {
            Debug.log("==== localCertificate not found ====")
            return
        }
        
        guard let cert = SecCertificateCreateWithData(nil, localCertificate) else {
            Debug.log("==== cert not found ====")
            return
        }
        
        let serverTrustPolicy = ServerTrustPolicy.pinCertificates(certificates: [cert], validateCertificateChain: true, validateHost: true)

        let serverTrustPolicies = [
            "quytech.net": serverTrustPolicy
        ]*/
        manager.session.finishTasksAndInvalidate()
        manager = Alamofire.SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicyWithKey))
        
        manager.session.configuration.timeoutIntervalForRequest = 200//25
        
        if !parameterArray.isEmpty {
            var request: URLRequest
            guard let url = URL(string: URLString) else {
                if loader { ProgressHud.hideActivityLoader() }
                return
            }
            
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = header
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: parameterArray, options: .prettyPrinted)
            
            Alamofire.request(request).responseJSON{ (response) in
                if loader { ProgressHud.hideActivityLoader() }
                
                Debug.log("==== PARAMETERS ====")
                Debug.log("\(parameterArray)")
                Debug.log("Success: \(response)")
                
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    
                    Debug.log("==== RESPONSE ====")
                    Debug.log("\(json)")
                    
                    success(data)
                case .failure(let error):
                    Debug.log("==== FAILURE ====")
                    Debug.log("\(error.localizedDescription)")
                    
                    Debug.log("==== RESPONSE ====")
                    Debug.log((String(data: response.data!, encoding: .utf8) ?? ""))
                    
                    if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        
                        failure("No internet Connection.")
                    } else {
                        failure(error.localizedDescription)
                    }
                }
            }
        }else {
            manager.request(URLString, method: httpMethod, parameters: parameters, encoding: encoding, headers: updatedHeaders).responseJSON { (response:DataResponse<Any>) in
                
                if loader { ProgressHud.hideActivityLoader() }
                
                Debug.log(("===== METHOD ===="))
                Debug.log("\(httpMethod)")
                //            print("==== ENCODING ====")
                //            print(encoding)
                Debug.log(("==== URL STRING ===="))
                Debug.log("\(URLString)")
                
                Debug.log(("==== PARAMETERS ===="))
                Debug.log("\(parameters.description)")
                
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    
                    Debug.log("==== RESPONSE ====")
                    Debug.log("\(json)")
                    
                    success(data)
                case .failure(let error):
                    Debug.log("==== FAILURE ====")
                    Debug.log("\(error.localizedDescription)")
                    
                    Debug.log("==== RESPONSE ====")
                    Debug.log((String(data: response.data!, encoding: .utf8) ?? ""))
                    
                    if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        
                        failure("No internet Connection.")
                    } else {
                        failure(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    private static func upload(URLString : String,
                               httpMethod : HTTPMethod,
                               parameters : JSONDictionary = [:],
                               files : [AttachmentInfo] = [],
                               
                               headers : HTTPHeaders = [:],
                               loader : Bool = true,
                               success : @escaping HttpClientSuccess ,
                               failure : @escaping HttpClientFailure) {
        
        
        var header : [String: String] = [:]
        let accessToken = AuthManager.shared.loggedInUser?.auth_token ?? ""
        if !accessToken.isEmpty {
            //  header["Authorization"] = "Bearer \(accessToken)"
            header["Authorization"] = "\(accessToken)"
            header["Content-Type"] = "application/json"
        } else {
            header = headers
        }
        
        
        guard let url = try? URLRequest(url: URLString, method: httpMethod, headers: header) else { return }
        
        if loader { ProgressHud.showActivityLoader() }
        
        
        Debug.log(("===== HEADERS ===="))
        Debug.log("\(header)")
        
        Debug.log(("===== allhttp ===="))
        Debug.log("\(url.allHTTPHeaderFields)")
        
        
        let manager = Alamofire.SessionManager.default
        
        //                let serverTrustPolicies: [String: ServerTrustPolicy] = ["quytech.net": .pinCertificates(certificates: ServerTrustPolicy.certificates(),
        //                                                                                                                validateCertificateChain: true,
        //                                                                                                                validateHost: true)]
        //
        //                let manager = Alamofire.SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        //
        
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        manager.upload(multipartFormData: { (multipartFormData) in
            
            print("==== METHOD ====")
            
            //            for (i, image) in arrayImages.enumerated() {
            //
            //                guard let image = image?.resize(with: 1200) , let imageData = image.jpegData(compressionQuality: 0.5) else {
            //                    return }
            //                if arrayImages.count == 1{
            //                    multipartFormData.append(imageData, withName: "profile_image", fileName: "image.jpg", mimeType:"image/jpg" )
            //
            //                }else{
            //                    multipartFormData.append(imageData, withName: "image\(i+1)", fileName: "photo\(i+1).png", mimeType: "image/jpg")
            //                }
            //
            //            }
            
            files.forEach({ (file) in
                if let data = file.data {
                    print("\(file.data?.debugDescription ?? "") \(file.fileName), \(file.mimeType)")
                    if(file.mimeType == "video/mp4"){
                        multipartFormData.append(data, withName: file.apiKey, fileName: file.fileName, mimeType: "video/mp4")
                    }else{
                        multipartFormData.append(data, withName: file.apiKey, fileName: "image.jpg", mimeType: "image/jpg" )
                    }
                }
            })
            
            parameters.forEach({ (paramObject) in
                
                if let arr = paramObject.value as? Array<AnyObject> {
                    
                    for (index, item) in arr.enumerated() {
                        if let data = ("\(item)" as AnyObject).data(using : String.Encoding.utf8.rawValue) {
                            multipartFormData.append(data, withName: "\(paramObject.key)[\(index)]")
                            Debug.log("Value::::----\((item as AnyObject))   and value ::::---- \(paramObject.key)[\(index)]")
                        }
                    }
                }else {
                    if let data = ("\(paramObject.value)" as AnyObject).data(using : String.Encoding.utf8.rawValue) {
                        multipartFormData.append(data, withName: paramObject.key)
                    }
                }
            })
        }, with: url, encodingCompletion: { encodingResult in
            
            switch encodingResult{
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                upload.responseJSON(completionHandler: { (response:DataResponse<Any>) in
                    
                    if loader { ProgressHud.hideActivityLoader() }
                    
                    Debug.log(("===== METHOD ===="))
                    Debug.log("\(httpMethod)")
                    
                    Debug.log(("===== HEADERS ===="))
                    Debug.log("\(headers)")
                    
                    Debug.log(("==== URL STRING ===="))
                    Debug.log("\(URLString)")
                    
                    Debug.log(("===== PARAMETERS ===="))
                    Debug.log("\(parameters)")
                    
                    switch response.result {
                    case .success(let value):
                        
                        Debug.log(("==== RESPONSE ===="))
                        Debug.log("\(JSON(value))")
                        
                        success(value)
                        
                    case .failure(let error):
                        
                        Debug.log("==== FAILURE ====")
                        Debug.log("\(error.localizedDescription)")
                        
                        Debug.log("==== RESPONSE ====")
                        Debug.log((String(data: response.data!, encoding: .utf8) ?? ""))
                        
                        if loader { ProgressHud.hideActivityLoader() }
                        if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                            
                            failure("No internet Connection.")
                        } else {
                            failure(error.localizedDescription)
                        }
                    }
                })
                
            case .failure(let error):
                
                if loader { ProgressHud.hideActivityLoader() }
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    
                    failure("No internet Connection.")
                } else {
                    failure(error.localizedDescription)
                }
            }
        })
    }
    
    
    //MARK: - Token Expired
    func tokenExpired() {
        AlertController.alert(title: "Oops", message: AlertMessages.sessionExpired.getLocalizedValue())
        
        
        //        let delegate = UIApplication.shared.delegate as? AppDelegate
        //        delegate?.window?.rootViewController = StoryboardScene.LoginSignup.initialViewController()
        //        UserSingleton.shared.loggedInUser = nil
    }
    
    //MARK: - Admin Blocked
    func adminBlocked(_ message : String){
        AlertController.alert(title: "Oops", message: "")
        //        let delegate = UIApplication.shared.delegate as? AppDelegate
        //        delegate?.window?.rootViewController = StoryboardScene.LoginSignup.initialViewController()
        //        UserSingleton.shared.loggedInUser = nil
    }
    
    static func getCertificates() -> [SecCertificate] {
        let allcerr = Bundle.main.url(forResource: "quytech_ssl", withExtension: "cer")!
        let localUrl = try! Data.init(contentsOf: allcerr) as CFData
        
        guard let certificates = SecCertificateCreateWithData(nil, localUrl) as? [SecCertificate] else {
            return []
        }
        
        return certificates
    }
    
    
}


class ProgressHud: UIViewController /*\, NVActivityIndicatorViewable*/ {
    
    static let shared = ProgressHud()

    
    /// Show Activity Loader
    static func showActivityLoader() {
        PKHUD.sharedHUD.contentView =  PKHUDProgressView()
        PKHUD.sharedHUD.show()
        /*\DispatchQueue.main.async {
            let object = ProgressHud.shared
            object.startAnimating(nil, message: nil, messageFont: nil, type: .ballClipRotate, color: .white, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil)
        }*/

    }
    static func showActivityLoaderWithTxt(text: String) {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        /*\DispatchQueue.main.async {
         let object = ProgressHud.shared
         object.startAnimating(nil, message: nil, messageFont: nil, type: .ballClipRotate, color: .white, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil)
         }*/

    }
    /// Hide Activity Loader
    static func hideActivityLoader() {
        PKHUD.sharedHUD.hide()
        /*\DispatchQueue.main.async {
            let object = ProgressHud.shared
            object.stopAnimating(NVActivityIndicatorView.DEFAULT_FADE_OUT_ANIMATION)
        }*/
    }
}


public struct AttachmentInfo {
    
    public var fileName: String
    public var apiKey : String
    public var mimeType: String
    public var url: URL? = nil
    public var data: Data? = nil
    
    public init(){
        url = nil
        data = nil
        fileName = ""
        mimeType = ""
        apiKey = Constants.kImage_URL
    }
    
    public init(withFileURL url: URL, apiName: String = "group_picture") {
        self.fileName = url.lastPathComponent
        self.mimeType = url.mimeType()
        self.url = url
        self.apiKey = apiName
        
        if FileManager.default.fileExists(atPath: url.path) {
            let file = NSData.init(contentsOfFile: url.path)
            if (file != nil) {
                self.data = file?.copy() as! Data?
                print("File Exists")
            }
            else {
                print("There is no file")
            }
        }
        
    }
    
    
    public init(withData data: Data? , fileName:String, apiName: String = "video_file") {
        self.fileName = fileName
        self.mimeType = fileName.mimeType()
        self.apiKey = apiName
        //   if let imageData = returnRepresentationUnder1MB(image: image) {
        self.data = data
        //}
    }
    
    
    
    public init(withImage image: UIImage, imageName: String, apiName: String = "group_picture") {
        self.fileName = imageName
        self.mimeType = fileName.mimeType()
        self.apiKey = apiName
        if let imageData = returnRepresentationUnder1MB(image: image) {
            self.data = imageData
        }
    }
    
    func returnRepresentationUnder1MB(image: UIImage) -> Data?{
        //let oneMB = 1024 * 1024
        var finalData: Data?
        if let data = image.jpegData(compressionQuality: 1) {
            //            let ratio = CGFloat(oneMB)/CGFloat(data.count)
            finalData = data
            //            finalData = image.jpegData(compressionQuality: 1)
        }
        
        if finalData == nil {
            print("Image compression failed.")
        }
        return finalData
    }
    
    
}
