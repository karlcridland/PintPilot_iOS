//
//  ViewController.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import UIKit
import Stripe
import Alamofire
import PassKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, STPAuthenticationContext {
    
    
    // Variables for image picker.
    
    let pickerController = UIImagePickerController()
    var target: UIImageView?
    var extra: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemGray5
        Settings.shared.home = self

        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }

        pickerController.allowsEditing = false
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            if let layout = self.view.superview?.layoutMargins{
                Settings.shared.upper_bound = layout.top
                Settings.shared.lower_bound = layout.bottom
            }
            self.startUp()
        })

    }
    
//    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
//        print("test")
//    }
//
    func startUp(){
        view.removeAll()
        if !Authentication.shared.isSignedIn(){
            self.startUpAuthOptions()
        }
        else{
            self.isSignedIn()
            Control.shared.reloadDaTing()
            
        }
    }
    
    func startUpAuthOptions(){
        
        let logo = UIImageView(frame: CGRect(x: 20, y: 351, width: 374, height: 194))
        logo.image = UIImage(named: "logo")
        logo.center = self.view.center
        logo.contentMode = .scaleAspectFit
        
        let drinkResponsibly = UILabel(frame: CGRect(x: 20, y: 636, width: self.view.frame.width-40, height: 133))
        drinkResponsibly.text = "DRINK RESPONSIBLY"
        drinkResponsibly.font = UIFont.boldSystemFont(ofSize: 17)
        drinkResponsibly.textAlignment = .center
        
        let signIn = UIButton(frame: CGRect(x: self.view.frame.width/4-30, y: Settings.shared.upper_bound+50, width: 100, height: 40))
        signIn.setTitle("sign in", for: .normal)
        signIn.addTarget(self, action: #selector(signInClicked), for: .touchUpInside)
        
        let signUp = UIButton(frame: CGRect(x: 3*self.view.frame.width/4-70, y: Settings.shared.upper_bound+50, width: 100, height: 40))
        signUp.setTitle("sign up", for: .normal)
        signUp.addTarget(self, action: #selector(signUpClicked), for: .touchUpInside)
        
        for button in [signIn,signUp]{
            button.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: UIFont.Weight(0.3))
            button.backgroundColor = .systemGray6
            button.layer.borderWidth = 2
            button.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
            button.layer.cornerRadius = 10
        }
        
        
        view.addSubview([logo,drinkResponsibly,signUp,signIn])
        
    }
    
    @objc func signInClicked(){
        if let auth = self.storyboard?.instantiateViewController(withIdentifier: "Authentication") as? AuthViewController {
            auth.sign_in()
            self.present(auth, animated: true, completion: {
            })
        }
    }
    
    @objc func signUpClicked(){
        if let auth = self.storyboard?.instantiateViewController(withIdentifier: "Authentication") as? AuthViewController {
            auth.sign_up()
            self.present(auth, animated: true, completion: {
            })
        }
    }

    func isSignedIn() {
        Control.shared.open( .home)
        setupUI()
        
        Firebase.shared.getCheckIns()
        Firebase.shared.getCardInfo()
        Firebase.shared.preloadQRCodes()
    }
    
    func openImagePicker(_ imageView: UIImageView, _ extra: Any?){
        
        // Makes a UIImageView the target for the Image Picker to delegate to and opens the picker, dismisses any
        // view controller if present.
        
        self.target = imageView
        self.extra = extra
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // When an image is picked it is displayed on the target.

        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let target = self.target{
                target.image = pickedImage
            }
        }
        
        if let extra = extra as? SettingsView{
            extra.save.isHidden = false
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Removes the Image Picker.
        
        dismiss(animated: true, completion: nil)
    }
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super .dismiss(animated: flag, completion: completion)
        
    }
    
    
    // MARK: Stripe set up
    
    private let paymentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    public var productStackView = UIStackView()
    private var paymentStackView = UIStackView()
    private var productLabel = UILabel()
    private var payButton = UIButton()
    private var loadingSpinner = UIActivityIndicatorView()
    private var outputTextView = UITextView()
    public var paymentTextField = STPPaymentCardTextField()
    private var loading: UIImageView?
    
    private var load: UIView?
    
    private let backendURL : String = "https://pintpilot.herokuapp.com"
    
    private func setupUI(){
        
        setupProductLabel()
        setupLoadingSpinner()
        setupPaymentTextField()
        setupPayButton()
        setupOutputTextView()
        
        
        self.productStackView.frame  = CGRect(x: 0, y: 70, width: 330, height: 150)
        self.productStackView.center.x = self.view.center.x
        self.productStackView.alignment = .center
        self.productStackView.axis = .vertical
        self.productStackView.distribution = .equalSpacing
        
        self.paymentView.addSubview(self.productLabel)
        
        self.paymentView.addSubview(self.productStackView)
        
        self.paymentStackView.frame = CGRect(x: 0, y: 260, width: 300, height: 100)
        self.paymentStackView.center.x = self.view.center.x
        self.paymentStackView.alignment = .fill
        self.paymentStackView.axis = .vertical
        self.paymentStackView.distribution = .equalSpacing
        
        self.paymentStackView.addArrangedSubview(self.paymentTextField)
        self.paymentStackView.addArrangedSubview(self.payButton)
        
        self.paymentView.addSubview(self.paymentStackView)
        
    }
    
    private func setupProductLabel(){
        self.productLabel.frame = CGRect(x: 0, y: 190, width: self.view.frame.width, height: 50)
        self.productLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        self.productLabel.textAlignment = .center
    }
    
    
    
    private var total = 0
    
    func createPayment(_ total: Int, _ load: UIView) -> UIView{
        self.load = load
        self.load?.isHidden = true
        self.total = total
        self.productLabel.text = "Total: \(total.price(currency: .GBP))"
        if let cards = Settings.shared.cards{
            if let n = Settings.shared.getCard(){
                let card = cards[n]
                
                let cardParams = STPPaymentMethodCardParams()
                
                cardParams.number = String(card.number)
                cardParams.expMonth = NSNumber(value: card.exp_month) // this data type is UInt and *not* Int
                cardParams.expYear = NSNumber(value: card.exp_year) // this data type is UInt and *not* Int
                cardParams.cvc = String(card.security)
                
                self.paymentTextField.cardParams = cardParams
                
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
                    self.paymentTextField.resignFirstResponder()
                    self.paymentTextField.resignFirstResponder()
                    
                })
            }
        }
        return paymentView
    }
    
    private func setupLoadingSpinner(){
        self.loadingSpinner.color = UIColor.darkGray
        self.loadingSpinner.frame = CGRect(x: 0, y: 380, width: 25, height: 25)
        self.loadingSpinner.center.x = self.view.center.x
        
        self.paymentView.addSubview(self.loadingSpinner)
    }
    
    private func setupPaymentTextField(){
        self.paymentTextField.frame = CGRect(x: 0, y: 0, width: 330, height: 60)
        self.paymentTextField.backgroundColor = .white
        self.paymentTextField.postalCodeEntryEnabled = false
        
        self.paymentTextField.backgroundColor = .systemGray6
        self.paymentTextField.layer.borderWidth = 2
        self.paymentTextField.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        self.paymentTextField.layer.cornerRadius = 10
        
        
    }
    
    private func setupPayButton(){
        self.payButton.frame = CGRect(x: 60, y: 480, width: 150, height: 60)
        self.payButton.setTitle("Submit Payment", for: .normal)
        self.payButton.setTitleColor(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), for: .normal)
        self.payButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(0.3))
        self.payButton.backgroundColor = .systemGray6
        self.payButton.layer.borderWidth = 2
        self.payButton.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).withAlphaComponent(0.6).cgColor
        self.payButton.layer.cornerRadius = 10
        self.payButton.addTarget(self, action: #selector(pay), for: .touchUpInside)
    }
    
    private func setupOutputTextView(){
        self.outputTextView.frame = CGRect(x: 0, y: 420, width: self.view.frame.width-50, height: 100)
        self.outputTextView.center.x = self.view.center.x
        self.outputTextView.textAlignment = .left
        self.outputTextView.font = UIFont.systemFont(ofSize: 18)
        self.outputTextView.text = ""
        self.outputTextView.layer.borderColor = UIColor.purple.cgColor
        self.outputTextView.layer.borderWidth = 1.0
        self.outputTextView.isEditable = false
        self.outputTextView.isHidden = true
        self.paymentView.addSubview(self.outputTextView)
    }
    
    private func startLoading(){
        DispatchQueue.main.async {
            self.loadingSpinner.startAnimating()
            self.loadingSpinner.isHidden = true
            
            Control.shared.paymentStarted(true)
            self.load?.isHidden = false
        }
    }
    
    private func stopLoading(){
        DispatchQueue.main.async {
            self.loadingSpinner.stopAnimating()
            self.loadingSpinner.isHidden = true
            
            Control.shared.paymentStarted(false)
            self.load?.isHidden = true
        }
    }
    
    private func displayStatus(_ message: String){
        print(message)
        DispatchQueue.main.async {
            self.outputTextView.text! += message + "\n"
            
            self.outputTextView.scrollRangeToVisible(NSMakeRange(self.outputTextView.text.count - 1, 1))
        }
    }
    
    private func complete(_ percent: CGFloat){
        
//        if let load = load{
//            let width = (CGFloat(load.tag)/CGFloat(100))*percent
//
//            UIView.animate(withDuration: 0.3, animations: {
//                load.frame = CGRect(x: load.frame.minX, y: load.frame.minY, width: width, height: load.frame.height)
//            })
//        }
    }
    
    var transactionStarted = false
    
    @objc private func pay(){
        
        if transactionStarted{
            return
        }
        
        self.paymentTextField.isUserInteractionEnabled = false
        self.transactionStarted = true
        self.payButton.alpha = 0.6
        
        self.startLoading()
        self.displayStatus("Creating PaymentIntent")
        self.complete(33)
        
        createPaymentIntent { (paymentIntentResponse, error) in
            if let error = error{
                self.stopLoading()
                self.displayStatus(error.localizedDescription)
                return
            }
            else{
                guard let responseDictionary = paymentIntentResponse as? [String:AnyObject] else {
                    return
                }
                let clientSecret = responseDictionary["secret"] as! String
                
                print(responseDictionary)
                
                self.displayStatus("Created Payment Intent")
                self.complete(66)
                
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                
                let paymentMethodParams = STPPaymentMethodParams(card: self.paymentTextField.cardParams, billingDetails: nil, metadata: nil)
                
                paymentIntentParams.paymentMethodParams = paymentMethodParams
                
                STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
                    
                    var resultString = ""
                    
                    switch (responseDictionary["status"]?.lowercased){
                        
                    case "succeeded":
                        resultString = "payment successful"
                        self.complete(100)
                        self.stopLoading()
                        self.transactionStarted = false
                        self.payButton.alpha = 1.0
                        self.paymentTextField.isUserInteractionEnabled = false
                        self.paymentTextField.resignFirstResponder()
                        self.paymentTextField.resignFirstResponder()
                        
                        let _ = PageOrderPlaced()
                        
                        break
                        
                    default:
                        resultString = "payment failed - please try another card"
                        self.complete(100)
                        self.stopLoading()
                        self.transactionStarted = false
                        self.payButton.alpha = 1.0
                        self.paymentTextField.isUserInteractionEnabled = true
                        self.load?.isHidden = true
                        break
                        
                    }
                    
                    self.displayStatus(resultString)
                }
            }
        }
    }
    
    private func createPaymentIntent(completion: @escaping STPJSONResponseCompletionBlock){
        
        
        var url = URL(string: backendURL)!
        url.appendPathComponent("create_payment_intent")
        
        Authentication.shared.setName {
            let parameters: [String: Any] = [
                "amount": self.total,
                "country": "gb",
                "customer_id": Authentication.shared.get()!,
                "order_id": Basket.shared.id!,
                "payment_method": ["card"],
                "email": Authentication.shared.email()!,
                "source": "ios_card",
                "number": self.paymentTextField.cardParams.number as Any,
                "exp_month": self.paymentTextField.cardParams.expMonth as Any,
                "exp_year": self.paymentTextField.cardParams.expYear as Any,
                "cvc": self.paymentTextField.cardParams.cvc as Any,
                "name": Authentication.shared.getName()
            ]
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    switch(response.result){
                    
                    case .failure(let error):
                        completion(nil, error)
                        self.stopLoading()
                        self.transactionStarted = false
                        self.payButton.alpha = 1.0
                        self.paymentTextField.isUserInteractionEnabled = true
                        
                    case .success(let json):
                        completion(json as? [String:Any], nil)
                    }
                }
        }
        
    }
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
}
