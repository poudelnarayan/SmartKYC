import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'पहिचान प्रमाणीकरण';

  @override
  String get createAccount => 'खाता सिर्जना गर्नुहोस्';

  @override
  String get createAccountDesc => 'कृपया आफ्नो खाता सिर्जना गर्न फारम भर्नुहोस्';

  @override
  String get confirmPassword => 'पासवर्ड पुष्टि गर्नुहोस्';

  @override
  String get confirmPasswordRequired => 'कृपया पासवर्ड पुष्टि गर्नुहोस्';

  @override
  String get passwordsDoNotMatch => 'पासवर्डहरू मेल खाँदैनन्';

  @override
  String get alreadyHaveAccount => 'पहिले नै खाता छ?';

  @override
  String signUpError(String error) {
    return 'साइन अप गर्न असफल: $error';
  }

  @override
  String get verifyNow => 'इमेल प्रमाणित गर्नुहोस्';

  @override
  String get checking => 'जाँच गर्दै...';

  @override
  String get resendEmail => 'पुन: प्रमाणिकरण इमेल पठाउनुहोस्';

  @override
  String get sending => 'पठाउँदै...';

  @override
  String get dataExtraction => 'डेटा निकाल्दै...';

  @override
  String get security => 'सुरक्षा';

  @override
  String get about => 'बारेमा';

  @override
  String get signUpSuccessTitle => 'खाता सफलतापूर्वक सिर्जना गरियो!';

  @override
  String get signUpSuccessMessage => 'तपाईंको खाता सिर्जना गरिएको छ। प्रमाणिकरण लिङ्क तपाईंको इमेलमा पठाइएको छ।';

  @override
  String get continueToSignIn => 'साइन इन मा जानुहोस्';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get rememberMe => 'मलाई सम्झनुहोस्';

  @override
  String get forgotPassword => 'पासवर्ड बिर्सनुभयो?';

  @override
  String get forgotPasswordDesc => 'कृपया आफ्नो दर्ता गरिएको इमेल ठेगाना प्रविष्ट गर्नुहोस्, हामी तपाईंलाई पासवर्ड रिसेट गर्न लिङ्क पठाउनेछौं।';

  @override
  String get resetPassword => 'पासवर्ड पुनः सेट गर्नुहोस्';

  @override
  String get resetLinkSent => 'रिसेट लिंक पठाइयो';

  @override
  String get backToSignIn => 'साइन इन मा फर्कनुहोस्';

  @override
  String get resetLinkSentDesc => 'यदि यो इमेलसँग खाता छ भने, तपाईंले छिट्टै पासवर्ड रिसेट लिंक प्राप्त गर्नुहुनेछ।';

  @override
  String get signIn => 'साइन इन';

  @override
  String get logoutConfirmation => 'लगआउट पुष्टिकरण';

  @override
  String get logoutConfirmationDesc => 'के तपाईं लगआउट गर्न निश्चित हुनुहुन्छ?';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get logout => 'लगआउट';

  @override
  String get noAccount => 'खाता छैन?';

  @override
  String get signUp => 'साइन अप';

  @override
  String get uploading => 'अपलोड गर्दै...';

  @override
  String get passwordRequired => 'कृपया आफ्नो पासवर्ड प्रविष्ट गर्नुहोस्';

  @override
  String get passwordTooShort => 'पासवर्ड कम्तिमा 8 वर्णको हुनुपर्छ';

  @override
  String get invalidCredentials => 'अमान्य इमेल वा पासवर्ड';

  @override
  String signInError(String error) {
    return 'साइन इन गर्न असफल: $error';
  }

  @override
  String get welcomeTitle => 'Smart Kyc मा स्वागत छ';

  @override
  String get welcomeSubtitle => 'जारी राख्न आफ्नो इमेल प्रविष्ट गर्नुहोस्';

  @override
  String get emailLabel => 'इमेल';

  @override
  String get continueButton => 'जारी राख्नुहोस्';

  @override
  String get sendingCode => 'कोड पठाउँदै...';

  @override
  String get verifyEmail => 'तपाईंको इमेल प्रमाणित गर्नुहोस्';

  @override
  String verifyEmailDesc(String email) {
    return 'हामीले $email मा प्रमाणीकरण कोड पठाएका छौं';
  }

  @override
  String get pleaseWait => 'कृपया केही समय प्रतीक्षा गर्नुहोस् ...';

  @override
  String get resendCode => 'कोड पुन: पठाउनुहोस्';

  @override
  String get invalidEmail => 'कृपया मान्य इमेल प्रविष्ट गर्नुहोस्';

  @override
  String get emailRequired => 'कृपया आफ्नो इमेल प्रविष्ट गर्नुहोस्';

  @override
  String get verificationExpired => 'प्रमाणीकरण कोड समाप्त भयो। कृपया नयाँ अनुरोध गर्नुहोस्।';

  @override
  String get invalidCode => 'अमान्य प्रमाणीकरण कोड। कृपया पुन: प्रयास गर्नुहोस्।';

  @override
  String verificationFailed(String error) {
    return 'प्रमाणीकरण असफल: $error';
  }

  @override
  String get verificationSteps => 'प्रमाणीकरण चरणहरू';

  @override
  String get languageSwitchWarn => '* भाषा प्राथमिकता प्रमाणीकरण प्रक्रियाभर कायम रहनेछ।';

  @override
  String get verificationStepsDesc => 'आफ्नो पहिचान प्रमाणित गर्न यी चरणहरू पूरा गर्नुहोस्';

  @override
  String get documentUploadTip => 'आईडी स्पष्ट रूपमा देखिने र सबै पाठ पढ्न सकिने छ भनी सुनिश्चित गर्नुहोस्';

  @override
  String get processingImage => 'तस्बिर प्रशोधन गर्दै...';

  @override
  String get noDocumentSelected => 'कुनै कागजात चयन गरिएको छैन';

  @override
  String get tapToChangeDocument => 'कागजात परिवर्तन गर्न ट्याप गर्नुहोस्';

  @override
  String get tapToUploadDocument => 'कागजात अपलोड गर्न ट्याप गर्नुहोस्';

  @override
  String get chooseFromGallery => 'ग्यालरीबाट छान्नुहोस्';

  @override
  String get captureFromCamera => 'क्यामेराबाट खिच्नुहोस्';

  @override
  String get noImageSelected => 'कुनै तस्बिर चयन गरिएको छैन';

  @override
  String get failedToPickImage => 'तस्बिर चयन गर्न असफल';

  @override
  String get cameraPermissionDenied => 'क्यामेरा अनुमति अस्वीकृत';

  @override
  String get failedToCaptureImage => 'तस्बिर खिच्न असफल';

  @override
  String get invalidImageFile => 'अमान्य तस्बिर फाइल';

  @override
  String get startVerification => 'प्रमाणीकरण सुरु गर्नुहोस्';

  @override
  String get emailVerification => 'इमेल प्रमाणीकरण';

  @override
  String get emailVerificationDesc => 'आफ्नो इमेल ठेगाना प्रमाणित गर्नुहोस्';

  @override
  String get documentUpload => 'कागजात अपलोड';

  @override
  String get documentUploadDesc => 'आफ्नो सरकारी-जारी आईडी अपलोड गर्नुहोस्';

  @override
  String get selfieGuidelines => 'सेल्फी निर्देशिका';

  @override
  String get lightingTip => 'अगाडि बढ्नु अघि राम्रो प्रकाश भएको वातावरणमा रहेको सुनिश्चित गर्नुहोस्';

  @override
  String get selfieCapture => 'Selfie Capture';

  @override
  String get selfieCaptureDesc => 'Take a clear photo of your face';

  @override
  String get livenessCheck => 'लाइभनेस जाँच';

  @override
  String get livenessCheckDesc => 'तपाईं भौतिक रूपमा उपस्थित हुनुहुन्छ भनी प्रमाणित गर्नुहोस्';

  @override
  String get verificationComplete => 'प्रमाणीकरण पूरा भयो';

  @override
  String get verificationCompleteDesc => 'सबै चरणहरू सफलतापूर्वक पूरा भए';

  @override
  String get onboardingTitle1 => 'सुरक्षित कागजात अपलोड';

  @override
  String get onboardingDesc1 => 'बैंक-ग्रेड सुरक्षाको साथ आफ्ना कागजातहरू अपलोड वा क्याप्चर गर्नुहोस्। तपाईंको डाटा एन्क्रिप्ट र सुरक्षित छ।';

  @override
  String get onboardingTitle2 => 'एआई-संचालित प्रमाणीकरण';

  @override
  String get onboardingDesc2 => 'उन्नत एआई प्रविधिद्वारा संचालित तत्काल पहिचान प्रमाणीकरण अनुभव गर्नुहोस्। छिटो, सटीक र झन्झट-मुक्त।';

  @override
  String get onboardingTitle3 => 'छिटो र भरपर्दो प्रक्रिया';

  @override
  String get onboardingDesc3 => 'मिनेटमा आफ्नो केवाईसी प्रमाणीकरण सुरक्षित रूपमा पूरा गर्नुहोस्। हाम्रो सरल प्रक्रियाले सहज अनुभव सुनिश्चित गर्छ।';

  @override
  String get skip => 'छोड्नुहोस्';

  @override
  String get next => 'अर्को';

  @override
  String get back => 'पछाडि';

  @override
  String get getStarted => 'सुरु गर्नुहोस्';

  @override
  String get uploadId => 'आफ्नो आईडी अपलोड गर्नुहोस्';

  @override
  String get uploadIdDesc => 'कृपया आफ्नो सरकारी-जारी आईडी (लाइसेन्स) को स्पष्ट फोटो अपलोड गर्नुहोस्';

  @override
  String get chooseUploadMethod => 'अपलोड विधि छान्नुहोस्';

  @override
  String get fromGallery => 'ग्यालरीबाट छान्नुहोस्';

  @override
  String get fromCamera => 'क्यामेराबाट क्याप्चर गर्नुहोस्';

  @override
  String get noDocument => 'कुनै कागजात छानिएको छैन';

  @override
  String get tapToUpload => 'अपलोड गर्न ट्याप गर्नुहोस्';

  @override
  String get tapToChange => 'परिवर्तन गर्न ट्याप गर्नुहोस्';

  @override
  String get continue_operation => 'जारी राख्नुहोस्';

  @override
  String get idVisibilityNote => 'आईडी स्पष्ट देखिएको र सबै पाठ पढ्न योग्य छ भनी सुनिश्चित गर्नुहोस्';

  @override
  String get takeSelfie => 'सेल्फी लिनुहोस्';

  @override
  String get selfieGuidelinesTitle => 'सेल्फी दिशानिर्देशहरू';

  @override
  String get goodLighting => 'राम्रो प्रकाश';

  @override
  String get goodLightingDesc => 'प्राकृतिक प्रकाश भएको कोठामा रहेको सुनिश्चित गर्नुहोस्';

  @override
  String get facePosition => 'अनुहारको स्थिति';

  @override
  String get facePositionDesc => 'आफ्नो अनुहार अण्डाकार गाइडभित्र केन्द्रित राख्नुहोस्';

  @override
  String get noFlash => 'फ्ल्यास छैन';

  @override
  String get noFlashDesc => 'फ्ल्यास प्रयोग नगर्नुहोस्, बरु वरिपरिको प्रकाश प्रयोग गर्नुहोस्';

  @override
  String get startCamera => 'क्यामेरा सुरु गर्नुहोस्';

  @override
  String get lightingNote => 'अगाडि बढ्नु अघि तपाईं राम्रो प्रकाश भएको वातावरणमा हुनुहुन्छ भनी सुनिश्चित गर्नुहोस्';

  @override
  String get reviewSelfie => 'सेल्फी समीक्षा';

  @override
  String get captureError => 'तस्बिर खिच्न असफल';

  @override
  String get positionFace => 'आफ्नो अनुहार अण्डाकार भित्र राख्नुहोस् र राम्रो प्रकाश सुनिश्चित गर्नुहोस्';

  @override
  String get selfieSuccess => 'सेल्फी सफलतापूर्वक खिचियो';

  @override
  String get retake => 'पुन: खिच्नुहोस्';

  @override
  String get faceVerification => 'अनुहार प्रमाणीकरण';

  @override
  String get faceVerificationDesc => 'तपाईंको खाताको सुरक्षा सुनिश्चित गर्न हामीलाई तपाईं वास्तविक व्यक्ति हो भनी प्रमाणित गर्न आवश्यक छ।';

  @override
  String get clearView => 'स्पष्ट दृश्य';

  @override
  String get clearViewDesc => 'चश्मा, मास्क वा कुनै अनुहार ढाक्ने वस्तुहरू हटाउनुहोस्';

  @override
  String get cameraReady => 'क्यामेरा तयार';

  @override
  String get cameraReadyDesc => 'फ्रेम भित्र आफ्नो अनुहार राख्नुहोस्';

  @override
  String get verificationTimeEstimate => 'यो प्रक्रियाले एक मिनेट भन्दा कम समय लिनेछ';

  @override
  String get beginVerification => 'प्रमाणीकरण सुरु गर्नुहोस्';

  @override
  String get lookUpInstruction => 'कृपया बिस्तारै माथि हेर्नुहोस्';

  @override
  String get lookDownInstruction => 'अब बिस्तारै तल हेर्नुहोस्';

  @override
  String get lookLeftInstruction => 'आफ्नो टाउको बायाँतिर घुमाउनुहोस्';

  @override
  String get lookRightInstruction => 'अन्तमा, आफ्नो टाउको दायाँतिर घुमाउनुहोस्';

  @override
  String get centerHeadInstruction => 'राम्रो! आफ्नो टाउको बीचमा राख्नुहोस्';

  @override
  String get verificationCompleted => 'प्रमाणीकरण सफलतापूर्वक पूरा भयो!';

  @override
  String get verificationSuccess => 'प्रमाणीकरण सफल!';

  @override
  String get verificationSuccessTitle => 'प्रमाणीकरण सफल!';

  @override
  String get verificationSuccessMessage => 'तपाईंको पहिचान सफलतापूर्वक प्रमाणित भएको छ। तपाईं अब आफ्नो खातामा अगाडि बढ्न सक्नुहुन्छ।';

  @override
  String get verificationSuccessDesc => 'तपाईंको पहिचान सफलतापूर्वक प्रमाणित भएको छ। तपाईं अब आफ्नो खातामा अगाडि बढ्न सक्नुहुन्छ।';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get personalInformation => 'व्यक्तिगत जानकारी';

  @override
  String get documents => 'कागजातहरू';

  @override
  String get verificationStatus => 'प्रमाणीकरण स्थिति';

  @override
  String get premiumMember => 'प्रिमियम सदस्य';

  @override
  String get email => 'इमेल';

  @override
  String get phone => 'फोन';

  @override
  String get updateEmail => 'इमेल अपडेट गर्नुहोस्';

  @override
  String get updateEmailDesc => 'नयाँ इमेल ठेगाना प्रविष्ट गर्नुहोस्। प्रमाणीकरण लिंक पठाइनेछ।';

  @override
  String get updatePhone => 'फोन अपडेट गर्नुहोस्';

  @override
  String get updatePhoneDesc => 'फोन नम्बर प्रविष्ट गर्नुहोस्। प्रमाणीकरण कोड पठाइनेछ।';

  @override
  String get phoneLabel => 'फोन नम्बर';

  @override
  String get fieldRequired => 'यो फिल्ड आवश्यक छ';

  @override
  String get invalidPhone => 'कृपया मान्य फोन नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get update => 'अपडेट गर्नुहोस्';

  @override
  String get location => 'स्थान';

  @override
  String get licenseNo => 'लाइसेन्स नं.';

  @override
  String get passportNo => 'राहदानी नं.';

  @override
  String get idCard => 'परिचय पत्र';

  @override
  String get identity => 'पहिचान';

  @override
  String get verified => 'प्रमाणित';

  @override
  String get editProfile => 'प्रोफाइल सम्पादन';

  @override
  String get settings => 'सेटिङहरू';

  @override
  String get licenseDetails => 'लाइसेन्स विवरण';

  @override
  String get licenseInformation => 'चालक अनुमतिपत्र जानकारी';

  @override
  String get verifyInformation => 'कृपया तलको जानकारी रुजु गर्नुहोस्';

  @override
  String get licenseNumber => 'लाइसेन्स नम्बर';

  @override
  String get firstName => 'पहिलो नाम';

  @override
  String get lastName => 'थर';

  @override
  String get dateOfBirth => 'जन्म मिति';

  @override
  String get fatherName => 'बुवाको नाम';

  @override
  String get citizenshipNumber => 'नागरिकता नम्बर';

  @override
  String get phoneNumber => 'फोन नम्बर';

  @override
  String get issueDate => 'जारी मिति';

  @override
  String get expiryDate => 'समाप्ति मिति';

  @override
  String get licenseCategory => 'लाइसेन्स वर्ग';

  @override
  String get submit => 'पेश गर्नुहोस्';

  @override
  String pleaseEnter(Object field) {
    return '$field प्रविष्ट गर्नुहोस्';
  }

  @override
  String get requiredField => 'यो फिल्ड आवश्यक छ';

  @override
  String get invalidPhoneNumber => 'कृपया मान्य फोन नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get invalidCitizenshipNumber => 'कृपया मान्य नागरिकता नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get invalidLicenseNumber => 'कृपया मान्य लाइसेन्स नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get formProgress => 'फारम प्रगति';

  @override
  String step(int current, int total) {
    return '$total मध्ये $current चरण';
  }
}
