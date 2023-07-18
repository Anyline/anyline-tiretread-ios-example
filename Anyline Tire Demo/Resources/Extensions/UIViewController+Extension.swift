import UIKit

extension UIViewController {
    func displayAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func displayErrorAlert(for errorCode: Int) {
           var errorTitle, errorMessage: String
           
           switch errorCode {
           case 400:
               errorTitle = "Bad Request"
               errorMessage = "The server could not understand the request. Please try again with a valid request."
           case 401:
               errorTitle = "Unauthorized"
               errorMessage = "You are not authorized to access this resource. Please check your login credentials and try again."
           case 403:
               errorTitle = "Forbidden"
               errorMessage = "You do not have permission to access this resource. Please contact the administrator for assistance."
           case 404:
               errorTitle = "Not Found"
               errorMessage = "The requested resource could not be found. Please check the URL and try again."
           case 405:
               errorTitle = "Method Not Allowed"
               errorMessage = "The requested method is not supported for this resource. Please try a different method or check if you have the necessary permissions to perform the requested action."
           case 500:
               errorTitle = "Internal Server Error"
               errorMessage = "An unexpected error has occurred on the server. Please try again later or contact the administrator for assistance."
           case 503:
               errorTitle = "Service Unavailable"
               errorMessage = "The server is currently unavailable. Please try again later or contact the administrator for assistance."
           default:
               errorTitle = "An error occurred"
               errorMessage = "Something went wrong!"
           }
           
           let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
}
