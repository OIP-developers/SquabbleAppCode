//
//  APIService.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Saturday05/06/2021.
//

import RxSwift
import Alamofire
import CoreData
import CoreLocation
import UIKit
import MaterialComponents.MaterialSnackbar
import FirebaseFirestore
import FirebaseAuth

class APIService: NSObject {
    
    // MARK: - Properties
    var reachabilityManager = NetworkReachabilityManager()
    var baseUrl: String = ""
    
    // Singleton Instance
    static let singelton = APIService()
    
    // MARK: Initiate
    private override init() {
        super.init()
        
        //baseUrl = "http://3.91.218.114/api/v1"
        baseUrl = "http://165.22.64.183/api/v1"
        Logs.show(message: "SERVER: \(baseUrl)")
        
        self.startMonitoring()
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 3000
    }
    
    // MARK: - Helper Functions
    func startMonitoring() {
        reachabilityManager?.listener = { status in
            print("Network Status Changed: \(status)")
            switch status {
                case .notReachable:
                    print("not reachable")
                    break
                case .unknown, .reachable(.ethernetOrWiFi), .reachable(.wwan):
                    print("reachable")
                    break
            }
        }
        reachabilityManager?.startListening()
    }
    
    func isCheckReachable() -> Bool {
        return (reachabilityManager?.isReachable)!
    }
    
    private func getRequestHeader(isConfirmCall: Bool = false) -> HTTPHeaders {
        
        //let token = AppFunctions.getToken()
        
        var token = ""
        var  headers: HTTPHeaders = ["":""]
        if isConfirmCall {
            token = AppFunctions.getUserToken()
            headers = ["Authorization":"Bearer "+token+"", "Content-Type" :"application/json"]
        } else {
            var uid = ""
            if Auth.auth().currentUser != nil {
                uid = Auth.auth().currentUser?.uid ?? ""
            }
            token = AppFunctions.getUserToken()
            headers = ["Authorization":"Bearer "+token+"", "Content-Type" :"application/json", "firebase-uuid": uid] //"c4333c7b-e5c2-404b-b692-980b4e08039f"]
        }
        
        
        
        Logs.show(message: "TOKEN: // \(headers)")
        return headers
    }
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    
    //MARK: GENERAL WEB CALLS
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    func getCategory() -> Observable<[CategoriesModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/categories", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.categories)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    func getBanners() -> Observable<[BannersModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/banner-ads", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.banners)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    func getChalenges() -> Observable<[ChallengesModel]> { 
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/challenges", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.challenges)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getMyProfile() -> Observable<UserAPIModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/auth/me", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.user)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func updateUserProfile(id: String, pram : Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/auth/users/\(id)", method:.put, parameters: pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    func getUserProfile(id: String) -> Observable<UserAPIModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/auth/users/\(id)", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.user)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getActiveChalengesHome() -> Observable<[ChallengesModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/challenges/active/voting", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.challenges)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getChalengeById(id: String) -> Observable<ChallengesModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/challenges/\(id)", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.challenge)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getWinnings() -> Observable<[ChallengesModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/auth/winners", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.winners)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getAllVideos() -> Observable<[VideosModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/videos/get/all", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.videos)
                                    AppFunctions.saveLike(val: ["":"nil"])
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getfilterdVideos() -> Observable<[VideosModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/videos/get/all?key=\(filterKey)", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.videos)
                                    AppFunctions.saveLike(val: ["":"nil"])
                                    filterKey = ""
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getMyVideos() -> Observable<[VideosModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/videos/my/profile", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.videos)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getSubscriptions() -> Observable<[SubscriptionModel]> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/subscriptions", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.subscriptions)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func getBankDetails() -> Observable<BankModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/invoice/bank", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.bankData)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func likeVideo(videoId: String) -> Observable<String> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                Alamofire.request("\(self?.baseUrl ?? "")/videos/like/\(videoId)", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    if genResponse.body.like.contains("UnLike") {
                                        observer.onNext("unlike")
                                        observer.onCompleted()
                                    } else {
                                        observer.onNext("like")
                                        observer.onCompleted()
                                    }
                                    
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func followUnFollowUser(userId: String) -> Observable<String> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                Alamofire.request("\(self?.baseUrl ?? "")/auth/send/request/\(userId)", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    observer.onNext(genResponse.body.follow)
                                    observer.onCompleted()
                                    
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func sendGift(Pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                Alamofire.request("\(self?.baseUrl ?? "")/transection", method:.post, parameters: Pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    observer.onNext(true)
                                    observer.onCompleted()
                                    
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func payoutUser(Pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                Alamofire.request("\(self?.baseUrl ?? "")/invoice/payout/gift", method:.post, parameters: Pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    observer.onNext(true)
                                    observer.onCompleted()
                                    
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func addBankDetails(Pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                Alamofire.request("\(self?.baseUrl ?? "")/invoice/bank_token", method:.post, parameters: Pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    observer.onNext(true)
                                    observer.onCompleted()
                                    
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func deletebankDetails() -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                Alamofire.request("\(self?.baseUrl ?? "")/invoice/delete_bank", method:.delete, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    AppFunctions.showSnackBar(str: genResponse.message)
                                    observer.onNext(true)
                                    observer.onCompleted()
                                    
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    
    func searchInApp(searchStr: String) -> Observable<Body> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                Alamofire.request("\(self?.baseUrl ?? "")/challenges/search/name?search=\(searchStr)", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body)

                                    observer.onCompleted()
                                    
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    
    func participateInChallenge(Pram: Parameters, vidId: String) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/videos/participate/\(vidId)", method:.post, parameters: Pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func userSignIn(Pram: Parameters) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/auth/signin", method:.post, parameters: Pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    AppFunctions.saveUserToken(id: genResponse.body.tokens.refreshToken)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func userSignUp(id: String) {
        
        let pram : [String : Any] = ["id": id]
        
        Logs.show(message: "SKILLS PRAM: \(pram) ")
        
            if (self.isCheckReachable()) {
                
                Alamofire.request("\(self.baseUrl )/auth/signup", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: nil)
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    _ = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                } catch {
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                }
                        }
                    }
            } else {
                
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
    }
    
    func saveNotifToken(id: String, token: String) {
        
        let pram : [String : Any] = ["user": id,
                                     "token": token]
        
        Logs.show(message: "SKILLS PRAM: \(pram) ")
        
        if (self.isCheckReachable()) {
            
            Alamofire.request("\(self.baseUrl )/notification/save/token", method:.post, parameters: pram, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseData{ response in
                    Logs.show(message: "URL: \(response.debugDescription)")
                    guard let data = response.data else {
                        AppFunctions.showSnackBar(str: "Server Request Error")
                        Logs.show(message: "Error on Response.data\(response.error!)")
                        return
                    }
                    switch response.result {
                        case .success:
                            do {
                                _ = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                Logs.show(message: "SUCCESS IN \(#function)")
                            } catch {
                                AppFunctions.showSnackBar(str: "Server Parsing Error")
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                            }
                        case .failure(let error):
                            do {
                                let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                AppFunctions.showSnackBar(str: responce.message)
                            }catch {
                                Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                AppFunctions.showSnackBar(str: "Server Request Error")
                            }
                    }
                }
        } else {
            
            AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
        }
    }
    
    
    
    func uploadVideo(Pram: Parameters) -> Observable<VideosModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/videos", method:.post, parameters: Pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.video)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(VideosModel())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func applyForSubs(Pram: Parameters) -> Observable<PaymentModel> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/invoice/payment_intents", method:.post, parameters: Pram, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(genResponse.body.payment)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(PaymentModel())
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func confirmSubs(id: String) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/invoice/payment_intents/confirm/\(id)", method:.get, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader(isConfirmCall: false))
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func removeVideoFromProfile(vidId: String) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")/videos/mobile/\(vidId)", method:.delete, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    func blockUser(userId: String) -> Observable<Bool> {
        
        return Observable.create{[weak self] observer -> Disposable in
            if (self?.isCheckReachable())! {
                
                Alamofire.request("\(self?.baseUrl ?? "")auth/block/\(userId)", method:.post, parameters: nil, encoding: JSONEncoding.default, headers: self?.getRequestHeader())
                    .validate()
                    .responseData{ response in
                        Logs.show(message: "URL: \(response.debugDescription)")
                        guard let data = response.data else {
                            observer.onError(response.error!)
                            AppFunctions.showSnackBar(str: "Server Request Error")
                            Logs.show(message: "Error on Response.data\(response.error!)")
                            return
                        }
                        switch response.result {
                            case .success:
                                do {
                                    let genResponse = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    Logs.show(message: "SUCCESS IN \(#function)")
                                    observer.onNext(true)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: "Server Parsing Error")
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                }
                            case .failure(let error):
                                do {
                                    let responce = try JSONDecoder().decode(GeneralResponse.self, from: data)
                                    observer.onError(error)
                                    AppFunctions.showSnackBar(str: responce.message)
                                }catch {
                                    Logs.show(isLogTrue: true, message: "Error on observer.onError - \(error)")
                                    AppFunctions.showSnackBar(str: "Server Request Error")
                                    observer.onError(error)
                                }
                        }
                    }
            } else {
                observer.onNext(false)
                observer.onCompleted()
                AppFunctions.showSnackBar(str: "No Internet! Please Check your Connection.")
            }
            return Disposables.create()
        }
    }
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
    ///////////////////*********************////////////////////////********************////////////////////////*********************///////////////////////
    
}

