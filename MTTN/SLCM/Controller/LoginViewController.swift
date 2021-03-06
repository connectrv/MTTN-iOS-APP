//
//  LoginViewController.swift
//  MTTN
//
//  Created by Naman Jain on 05/06/19.
//  Copyright © 2019 Naman Jain. All rights reserved.
//


import UIKit
import AudioToolbox
import Firebase
import RNCryptor

private let critterViewDimension: CGFloat = 160
private let critterViewFrame = CGRect(x: 0, y: 0, width: critterViewDimension, height: critterViewDimension)
private let critterViewTopMargin: CGFloat = 100
private let textFieldHeight: CGFloat = 37
private let textFieldHorizontalMargin: CGFloat = 16.5
private let textFieldSpacing: CGFloat = 18
private let textFieldTopMargin: CGFloat = 18
private let textFieldWidth: CGFloat = 206

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var slcmViewController: SLCMViewController?
    var isSis = false
    
    var sisTextTimer: Timer?
    
//    private let critterView = CritterView(frame: critterViewFrame)
    private let screenSize:CGRect = UIScreen.main.bounds
    
    lazy var eduBuildingView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "edu")
        return iv
    }()
    
    lazy var icBuildingView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "ic")
        return iv
    }()
    
    lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var idTextField: UITextField = {
        let textField = self.createTextField(text: "Registration Number")
        textField.keyboardType = .numberPad
        textField.backgroundColor = #colorLiteral(red: 0.768627451, green: 1, blue: 0.9764705882, alpha: 1)
        textField.returnKeyType = .next
        textField.delegate = self
        return textField
    }()
    
    private lazy var desclaimerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.textAlignment = .center
        label.text = "We do not collect or share any aggregated information. Your ID and Password are stored locally on the device and used to directly interact with our SLCM server."
        label.font = UIFont(name: "HelveticaNeue", size: 10)
        return label
    }()
    
    private lazy var sisMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.textAlignment = .center
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        return label
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 7
        button.setTitle("Cancel", for: UIControl.State())
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = self.createTextField(text: "Password")
        textField.backgroundColor = #colorLiteral(red: 0.768627451, green: 1, blue: 0.9764705882, alpha: 1)
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var dateOfBirthTextField: UITextField = {
        let textField = self.createTextField(text: "Date of Birth")
        textField.backgroundColor = #colorLiteral(red: 0.768627451, green: 1, blue: 0.9764705882, alpha: 1)
        textField.returnKeyType = .done
        textField.alpha = 0
        return textField
    }()
    
    private lazy var loginButton : LoadingButton = {
        let button = LoadingButton()
        button.backgroundColor = #colorLiteral(red: 0.02745098039, green: 0.7450980392, blue: 0.7215686275, alpha: 1)
        button.tintColor = #colorLiteral(red: 0.768627451, green: 1, blue: 0.9764705882, alpha: 1)
        button.layer.cornerRadius = 7
        button.setTitle("Log In", for: UIControl.State())
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let items = ["SLCM", "SIS"]
    
    lazy var segmentedController: UISegmentedControl = {
        let segmentedController = UISegmentedControl(items: items)
        segmentedController.translatesAutoresizingMaskIntoConstraints = false
        segmentedController.addTarget(self, action: #selector(handleSegmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedController
    }()
    
    @objc func handleSegmentedControlValueChanged(_ sender: UISegmentedControl){
        switch sender.selectedSegmentIndex{
        case 0:
            UIView.animate(withDuration: 0.5) {
                self.eduBuildingView.alpha = 0
                self.icBuildingView.alpha = 0.6
                self.dateOfBirthTextField.alpha = 0
                self.passwordTextField.alpha = 1
                self.idTextField.textColor = #colorLiteral(red: 0.02745098039, green: 0.7450980392, blue: 0.7215686275, alpha: 1)
                self.idTextField.backgroundColor = #colorLiteral(red: 0.768627451, green: 1, blue: 0.9764705882, alpha: 1)
                self.loginButton.backgroundColor = #colorLiteral(red: 0.02745098039, green: 0.7450980392, blue: 0.7215686275, alpha: 1)
            }
            self.isSis = false
            print("slcm")
            break
        case 1:
            UIView.animate(withDuration: 0.5) {
                self.eduBuildingView.alpha = 0.6
                self.icBuildingView.alpha = 0
                self.dateOfBirthTextField.alpha = 1
                self.passwordTextField.alpha = 0
                self.idTextField.textColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                self.dateOfBirthTextField.textColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                self.idTextField.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.8206448754, blue: 0.7377076197, alpha: 1)
                self.dateOfBirthTextField.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.8206448754, blue: 0.7377076197, alpha: 1)
                self.loginButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
            }
            self.isSis = true
            print("sis")
            break
        default:
            break
        }
    }
    
    private let notificationCenter: NotificationCenter = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        observeKeyboardNotifications()
        setUpView()
        setupDatePickerView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sisTextTimer?.invalidate()
    }
    
    func setupDatePickerView(){
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        if let sevenDaysAgo = Calendar.current.date(byAdding: .year, value: -20, to: Date()) {
           datePicker.date = sevenDaysAgo
        }
        dateOfBirthTextField.inputView = datePicker
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateOfBirthTextField.text = formatter.string(from: sender.date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        let deadlineTime = DispatchTime.now() + .milliseconds(100)
//
//        if textField == idTextField {
//            DispatchQueue.main.asyncAfter(deadline: deadlineTime) { // 🎩✨ Magic to ensure animation starts
//                let fractionComplete = self.fractionComplete(for: textField)
//                self.critterView.startHeadRotation(startAt: fractionComplete)
//                self.passwordDidResignAsFirstResponder()
//            }
//        }
//        else if textField == passwordTextField || textField == dateOfBirthTextField{
//            DispatchQueue.main.asyncAfter(deadline: deadlineTime) { // 🎩✨ Magic to ensure animation starts
//                self.critterView.isShy = true
//            }
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == idTextField {
            passwordTextField.becomeFirstResponder()
        }
        else {
            passwordTextField.resignFirstResponder()
            dateOfBirthTextField.resignFirstResponder()
//            passwordDidResignAsFirstResponder()
        }
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField == idTextField {
//            critterView.stopHeadRotation()
//        }
//    }
//
//    @objc private func textFieldDidChange(_ textField: UITextField) {
//        guard !critterView.isActiveStartAnimating, textField == idTextField else { return }
//        let fractionComplete = self.fractionComplete(for: textField)
//        critterView.updateHeadRotation(to: fractionComplete)
//
//    }
    
    // MARK: - Private
    
    private func setUpView() {
//        if #available(iOS 13.0, *) {
//            view.backgroundColor = .systemBackground
//        } else {
//            view.backgroundColor = .white
//        }
        
        
        
        view.backgroundColor = .white
        
        segmentedController.selectedSegmentIndex = 0
        
//        view.addSubview(critterView)
//        setUpCritterViewConstraints()
//        critterView.alpha = 0
        
        view.addSubview(icBuildingView)
        icBuildingView.translatesAutoresizingMaskIntoConstraints = false
        icBuildingView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        icBuildingView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64).isActive = true
        icBuildingView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64).isActive = true
        icBuildingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        icBuildingView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -220).isActive = true
        
        icBuildingView.alpha = 0.6
        
        view.addSubview(eduBuildingView)
        eduBuildingView.translatesAutoresizingMaskIntoConstraints = false
        eduBuildingView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        eduBuildingView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64).isActive = true
        eduBuildingView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64).isActive = true
        eduBuildingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        eduBuildingView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -218).isActive = true
        
        eduBuildingView.alpha = 0
        
        view.addSubview(idTextField)
        setUpEmailTextFieldConstraints()
        
        view.addSubview(passwordTextField)
        setUpPasswordTextFieldConstraints()
        
        view.addSubview(dateOfBirthTextField)
        setUpDateOfBirthTextFieldConstraints()
        
        view.addSubview(loginButton)
        setupLoginButtonConstraints()
        
        view.addSubview(dismissButton)
        setupDismissButtonConstraints()
        
        view.addSubview(desclaimerLabel)
        setupDesclaimerLabelConstraints()
        
        view.addSubview(segmentedController)
        _ = segmentedController.anchor(top: nil, left: view.leftAnchor, bottom: desclaimerLabel.topAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 40)
        
        
        view.addSubview(sisMessageLabel)
        _ = sisMessageLabel.anchor(top: nil, left: view.leftAnchor, bottom: eduBuildingView.topAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        
        
        setUpGestures()
    }
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let y: CGFloat = -60
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
//    private func setUpCritterViewConstraints() {
//        critterView.translatesAutoresizingMaskIntoConstraints = false
//        critterView.heightAnchor.constraint(equalToConstant: critterViewDimension).isActive = true
//        critterView.widthAnchor.constraint(equalTo: critterView.heightAnchor).isActive = true
//        critterView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        critterView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -200).isActive = true
//    }
    
    private func setUpEmailTextFieldConstraints() {
        idTextField.translatesAutoresizingMaskIntoConstraints = false
        idTextField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
        idTextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        idTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        idTextField.topAnchor.constraint(equalTo: icBuildingView.bottomAnchor, constant: textFieldTopMargin).isActive = true
    }
    
    private func setUpPasswordTextFieldConstraints() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
        passwordTextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: textFieldSpacing).isActive = true
    }
    
    private func setUpDateOfBirthTextFieldConstraints() {
        dateOfBirthTextField.translatesAutoresizingMaskIntoConstraints = false
        dateOfBirthTextField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
        dateOfBirthTextField.widthAnchor.constraint(equalToConstant: textFieldWidth).isActive = true
        dateOfBirthTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateOfBirthTextField.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: textFieldSpacing).isActive = true
    }
    
    private func setupLoginButtonConstraints() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: textFieldWidth/2).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: textFieldSpacing).isActive = true
    }
    
    private func setupDismissButtonConstraints() {
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: textFieldWidth/2).isActive = true
        dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 0).isActive = true
    }
    
    private func setupDesclaimerLabelConstraints() {
        desclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        _ = desclaimerLabel.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 10, rightConstant: 20, widthConstant: 0, heightConstant: 60)
        
    }
    
    private func fractionComplete(for textField: UITextField) -> Float {
        guard let text = textField.text, let font = textField.font else { return 0 }
        let textFieldWidth = textField.bounds.width - (2 * textFieldHorizontalMargin)
        return min(Float(text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font])).width / textFieldWidth), 1)
    }
    
//    private func stopHeadRotation() {
//        idTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
//        critterView.stopHeadRotation()
//        passwordDidResignAsFirstResponder()
//    }
    
//    private func passwordDidResignAsFirstResponder() {
//        critterView.isPeeking = false
//        critterView.isShy = false
//        passwordTextField.isSecureTextEntry = true
//    }
    
    private func createTextField(text: String) -> UITextField {
        let view = UITextField(frame: CGRect(x: 0, y: 0, width: textFieldWidth, height: textFieldHeight))
        view.backgroundColor = .white
        view.layer.cornerRadius = 7
        view.tintColor = .dark
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.spellCheckingType = .no
        view.delegate = self
//        view.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let frame = CGRect(x: 0, y: 0, width: textFieldHorizontalMargin, height: textFieldHeight)
        view.leftView = UIView(frame: frame)
        view.leftViewMode = .always
        
        view.rightView = UIView(frame: frame)
        view.rightViewMode = .always
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        view.textColor = .text
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.lightGray
        view.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
        
        return view
    }
    
    // MARK: - Gestures
    
    private func setUpGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func handleTap() {
//        stopHeadRotation()
    }
    
    // MARK: - Notifications
    
    private func setUpNotification() {
        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func applicationDidEnterBackground() {
//        stopHeadRotation()
    }
    
    @objc private func handleDismiss() {
        view.endEditing(true)
        self.dismiss(animated: true)
        
    }
    
    @objc func handleLogin() {
        if idTextField.text == ""{
            FloatingMessage().floatingMessage(Message: "Enter Registration Number", onPresentation: {
                self.idTextField.becomeFirstResponder()
            }, onDismiss: {
                
            })
            return
        }
        
        if idTextField.text?.count != 9{
            FloatingMessage().floatingMessage(Message: "Invalid Registration Number", onPresentation: {
                self.idTextField.becomeFirstResponder()
            }, onDismiss: {
                
            })
            return
        }
        
        if self.isSis{
            if dateOfBirthTextField.text == "" {
                FloatingMessage().floatingMessage(Message: "Enter Date of Birth", onPresentation: {
                    self.dateOfBirthTextField.becomeFirstResponder()
                }, onDismiss: {
                    
                })
                return
            }
        }else{
            if passwordTextField.text == "" {
                FloatingMessage().floatingMessage(Message: "Enter Enter Password", onPresentation: {
                    self.passwordTextField.becomeFirstResponder()
                }, onDismiss: {
                    
                })
                return
            }
        }

        
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1519)
//            self.critterView.isEcstatic = true
//            self.critterView.isShy = false
//            self.critterView.isPeeking = false
            self.loginButton.showLoading()
        }
        
        if self.isSis{
            self.runSisTextTimer()
            let parameters = ["username": idTextField.text!, "password": dateOfBirthTextField.text!] as [String: String]
            view.endEditing(true)
            Networking.sharedInstance.fetchSISData(Parameters: parameters, dataCompletion: {
             (fetchAttendance) in
                DispatchQueue.main.async {
                    // sort fetchedAttendance here in case
//                    self.slcmViewController?.sisAttendance = fetchAttendance
                    self.slcmViewController?.sisAllSemestersAttendance = fetchAttendance
//                    self.slcmViewController?.marks = fetchMarks
                    self.slcmViewController?.isSis = true
                    self.slcmViewController?.noAttendance = false
                    self.successfullyAuthenticatedUser(Parameters: parameters)
                }
            }) { (SLCMError) in
                print("reached here in error: \(SLCMError)")
                DispatchQueue.main.async {
                    self.sisMessageLabel.text = ""
                    self.sisMessageLabel.alpha = 0
                }
                
                switch SLCMError{
                case .incorrectUserPassword:
                    self.handleInvalidMessage(Message: "Invalid Credentials")
                    break
                case .userNotLoggedIn:
                    break
                case .cannotFindSLCMUrl:
                    break
                case .connectionToSLCMFailed:
                    break
                case .noAttendanceData:
                    DispatchQueue.main.async {
                        self.slcmViewController?.attendance = []
                        self.successfullyAuthenticatedUser(Parameters: parameters)
                        self.slcmViewController?.noAttendance = true
                        self.slcmViewController?.isSis = true
                    }
                    break
                case .userLoggedOutDuringFetch:
                    break
                case .internalServerError:
                    break
                case .serverOffline:
                    self.handleInvalidMessage(Message: "Internal Server Offline")
                    break
                }
            }
        }else{
            let parameters = ["username": idTextField.text!, "password": passwordTextField.text!] as [String: String]
            view.endEditing(true)
            
            Networking.sharedInstance.fetchSLCMData(Parameters: parameters, dataCompletion: { (fetchAttendance, fetchMarks) in
                DispatchQueue.main.async {
                    // sort fetchedAttendance here in case
                    self.slcmViewController?.attendance = fetchAttendance
                    self.slcmViewController?.marks = fetchMarks
                    self.slcmViewController?.noAttendance = false
                    self.slcmViewController?.isSis = false
                    self.successfullyAuthenticatedUser(Parameters: parameters)
                }
            }) { (SLCMError) in
                print("reached here in error: \(SLCMError)")
                switch SLCMError{
                case .incorrectUserPassword:
                    self.handleInvalidMessage(Message: "Invalid Credentials")
                    break
                case .userNotLoggedIn:
                    break
                case .cannotFindSLCMUrl:
                    break
                case .connectionToSLCMFailed:
                    break
                case .noAttendanceData:
                    self.slcmViewController?.attendance = []
                    self.successfullyAuthenticatedUser(Parameters: parameters)
                    self.slcmViewController?.noAttendance = true
                    break
                case .userLoggedOutDuringFetch:
                    break
                case .internalServerError:
                    break
                case .serverOffline:
                    self.handleInvalidMessage(Message: "Internal Server Offline")
                    break
                }
            }
        }
        
    }
    
    
    @objc func runSisTextTimer (){
        self.sisMessageLabel.alpha = 1
        self.sisMessageLabel.text = ""
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.sisMessageLabel.text = "Connecting to SIS Portal.."
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.sisMessageLabel.text = "Solving Captcha.."
            }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.5) {
                self.sisMessageLabel.text = "Authenticating User.."
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 7) {
                self.sisMessageLabel.text = "Finding Semesters.."
            }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8.5) {
                self.sisMessageLabel.text = "Opening Attendance.."
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 11) {
                self.sisMessageLabel.text = "Fetching Data..."
            }
        }
    
    func handleInvalidMessage(Message: String){
        DispatchQueue.main.async {
            FloatingMessage().floatingMessage(Message: Message, onPresentation: {
                AudioServicesPlaySystemSound(1521)
                self.loginButton.hideLoading()
//                self.critterView.isEcstatic = false
//                self.critterView.isShy = false
//                self.critterView.isPeeking = true
            }, onDismiss: {
                self.idTextField.becomeFirstResponder()
            })
        }
    }
    
    func successfullyAuthenticatedUser(Parameters: [String: String]){
        if self.isSis{
            UserDefaults.standard.set(true, forKey: "isSis")
        }else{
            UserDefaults.standard.set(false, forKey: "isSis")
        }
        UserDefaults.standard.setIsLoggedIn(value: true)
        UserDefaults.standard.set(Parameters, forKey: "parameter")
        UserDefaults.standard.synchronize()
        self.slcmViewController?.reload()
        self.slcmViewController?.activateSLCMInterface()
        self.slcmViewController?.setupNavigationBar()
        writeFCMTokenToFirebase(Parameters: Parameters)
        self.dismiss(animated: true, completion: nil)
    }
    
    func writeFCMTokenToFirebase(Parameters: [String: String]){
        
        do {
            let hash = try encryptMessage(message: Parameters["password"]!, encryptionKey: "hash")
            
            let ref = Database.database().reference()

            var name = "N/A"
            if self.isSis{
                name = UserDefaults.standard.string(forKey: "SISUser") ?? ""
            }else{
                name = UserDefaults.standard.string(forKey: "SLCMUser") ?? ""
            }
            
            let token = UserDefaults.standard.string(forKey: "fcmToken")
            let device = UIDevice.modelName
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            
            let values = ["name": name, "fcmToken": token, "device": device, "appVersion": appVersion, "hash": hash]
            
            if let regNumber = Parameters["username"]{
                let childRef = ref.child("users_ios").child(regNumber)
                childRef.updateChildValues(values as [AnyHashable : Any])
            }
            
        }catch let error{
            print(error)
        }
    }
    
    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }
}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

