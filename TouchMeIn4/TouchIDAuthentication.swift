/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit  // change this from Foundation
import LocalAuthentication

class TouchIDAuth {
  
  var context = LAContext()
  
  let localizedReasonString = "we use biometrics to unlock the notes."
  
  var authError: NSError?
  
  func canEvaluatePolicy() -> Bool {
    
    return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:&authError)
  }
  
  func authenticateUser(completion: @escaping (String?) -> ()) { // have to mark it escaping
    
    if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      
      context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                             localizedReason: "Logging in with Touch ID") {
                              (success, evaluateError) in
                              
                              if (success) {
                                DispatchQueue.main.async {
                                  // User authenticated successfully, take appropriate action
                                  completion(nil)
                                }
                              } else {
                                
                                if let error: LAError = evaluateError as! LAError? {
                                  var message: String
                                  
                                  switch error {
                                    
                                  case LAError.authenticationFailed:
                                    message = "There was a problem verifying your identity."
                                  case LAError.userCancel:
                                    message = "You pressed cancel."
                                  case LAError.userFallback:
                                    message = "You pressed password."
                                  default:
                                    message = "Touch ID may not be configured"
                                  }
                                  
                                  completion(message)
                                }
                              }
                     
      }
    } else {
      
      completion("Touch ID not available")
    }
  }
}
