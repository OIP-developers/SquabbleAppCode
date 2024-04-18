import Stripe
import FirebaseAuth

protocol MainAPIClientFailureDelegate {
func showFailureMessage(message : String)
}


class MyAPIClient: NSObject, STPCustomerEphemeralKeyProvider {
    
        enum RequestRideError: Error {
            case missingBaseURL
            case invalidResponse
        }
    
        enum CustomerKeyError: Error {
            case missingBaseURL
            case invalidResponse
        }
    var failureDelegate : MainAPIClientFailureDelegate?

    let baseURL = "http://165.22.64.183/api/v1/" + "invoice/ephemeral_key"

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let urlString = URL(string: baseURL)
        var request = URLRequest(url: urlString!)
        request.httpMethod = "POST"
        var uid = ""
        let accessToken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJvaXAuY29tLnBrIiwiYXVkIjoib2lwLmNvbS5wayIsInN1YiI6Ijk3YzRjNzI2LTU3N2MtNDg5MS05OGY2LTBiYmQ2NTgyNTg1NiIsImlhdCI6MTY3NTE2NzUwNywiZXhwIjoxNjc3NzU5NTA3LCJwcm0iOiJmNDM3Y2M2YTQ5NjJhZDI0Yzc1MDA3YTY2NGUyOWQ5YmMyOTA0NjhmOTczMjk1ZjJkODM4OGEzZmM3YWExYmYxNjdlMzE2NmI3NjIxZDRmZTM1YmNkMzc4ZjlmZTA4MGZjYmM0Y2YyNzkxOWYzMDQyNTY3MjMzMjljNjIxMDBkZCJ9.VUXXMt5kNl21CrqPrQNKcrsds8aKu1wo4k6lDBIsEiNDWa933uHt8tvs06XfXYPi87bWzqz_f1RjXZgezTJ8xg"
        if Auth.auth().currentUser != nil {
            uid = Auth.auth().currentUser?.uid ?? ""
            Logs.show(message: "UID: \(uid)")

            
        }
        //request.setValue(accessToken, forHTTPHeaderField: "Authorization")

        request.setValue(uid, forHTTPHeaderField: "firebase-uuid")
        
        let parameterDictionary = ["api_version" : "2019-05-16"]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if error != nil {
                Logs.show(message: "error != nil: \(error!.localizedDescription)")
                //print(error!.localizedDescription)
            }
            else {
                
                if let data = data {
                    //Logs.show(message: "DATA:: \(data)")
                    /*do {
                        let parsedData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                        Logs.show(message: "DATA:: Json: \(parsedData)")
                    }
                    catch let err {
                        print("\n\n===========Error===========")
                        //print("Error Code: \(error._code)")
                        //print("Error Messsage: \(error!.localizedDescription)")
                        let str = String(data: data, encoding: String.Encoding.utf8)
                        Logs.show(message: "Print Server data:- " + (str ?? ""))
                        //Logs.show(message: "Error:: \(String(describing: error)) " )
                        
                        //debugPrint(error)
                        print("===========================\n\n")
                        
                        Logs.show(message: "Err:: \(err)")
                        //debugPrint(err)
                    }*/
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let dict = json as? NSDictionary
                        if let json = dict?.value(forKeyPath: "data.ephemeralKey") as? [AnyHashable: Any] {
                            Logs.show(message: "Data:: json: \(json)")
                            completion(json, nil)
                        }else {
                            if let message = dict?.value(forKey:"message") {
                                if(self.failureDelegate != nil) {
                                    Logs.show(message: "Error:: failureDelegate: \(message)")
                            self.failureDelegate?.showFailureMessage(message: message as! String)
                                }
                            }
                            else{
                                if(self.failureDelegate != nil) {
                                    Logs.show(message: "Error:: failureDelegate")
                                    self.failureDelegate?.showFailureMessage(message: "Oops! Something went wrong")
                                }
                            }
                            Logs.show(message: "Error:: CustomerKeyError.invalidResponse")
                            completion(nil, CustomerKeyError.invalidResponse)
                        }
                    } catch {
                        //print(error)
                        Logs.show(message: "Error:: \(error)")
                    }
                }
            }
        })
        task.resume()
    }
}
            //
            
            
            
            
            
            
         /*   guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??) else {
                completion(nil, error)
                return
            }
            completion(json, nil)
        })
        task.resume()
    }
}*/



//



//
