import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart KYC';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountDesc => 'Please fill in the form to create your account';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String signUpError(String error) {
    return 'Failed to sign up: $error';
  }

  @override
  String get verifyNow => 'I\'ve Verified My Email';

  @override
  String get checking => 'Checking...';

  @override
  String get resendEmail => 'Resend Verification Email';

  @override
  String get sending => 'Sending...';

  @override
  String get dataExtraction => 'Extracting Data ...';

  @override
  String get security => 'Security';

  @override
  String get about => 'About';

  @override
  String get signUpSuccessTitle => 'Account Created Successfully!';

  @override
  String get signUpSuccessMessage => 'Your account has been created. Verification link sent to:';

  @override
  String get continueToSignIn => 'Continue to Sign In';

  @override
  String get passwordLabel => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordDesc => 'Enter your registered email address, and we will send you a link to reset your password.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetLinkSent => 'Reset Link Sent';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get resetLinkSentDesc => 'If an account exists with this email, you will receive a password reset link shortly.';

  @override
  String get signIn => 'Sign In';

  @override
  String get logoutConfirmation => 'Logout Confirmation';

  @override
  String get logoutConfirmationDesc => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Logout';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get uploading => 'Uploading...';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String signInError(String error) {
    return 'Failed to sign in: $error';
  }

  @override
  String get welcomeTitle => 'Welcome to SmartKYC';

  @override
  String get welcomeSubtitle => 'Enter your email to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get continueButton => 'Continue';

  @override
  String get sendingCode => 'Sending code...';

  @override
  String get verifyEmail => 'Verify your email';

  @override
  String verifyEmailDesc(String email) {
    return 'We\'ve sent a verification code to\n$email';
  }

  @override
  String get pleaseWait => 'Please wait for a while ...';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get verificationExpired => 'Verification code expired. Please request a new one.';

  @override
  String get invalidCode => 'Invalid verification code. Please try again.';

  @override
  String verificationFailed(String error) {
    return 'Verification failed: $error';
  }

  @override
  String get verificationSteps => 'Verification Steps';

  @override
  String get languageSwitchWarn => '* Language preference will persist throughout the verification Process';

  @override
  String get verificationStepsDesc => 'Complete these steps to verify your identity';

  @override
  String get documentUploadTip => 'Make sure your ID is clearly visible and all text is readable';

  @override
  String get processingImage => 'Processing image...';

  @override
  String get noDocumentSelected => 'No document selected';

  @override
  String get tapToChangeDocument => 'Tap to change document';

  @override
  String get tapToUploadDocument => 'Tap to upload document';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get captureFromCamera => 'Capture from Camera';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get failedToPickImage => 'Failed to pick image';

  @override
  String get cameraPermissionDenied => 'Camera permission denied';

  @override
  String get failedToCaptureImage => 'Failed to capture image';

  @override
  String get invalidImageFile => 'Invalid image file';

  @override
  String get startVerification => 'Start Verification';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String get emailVerificationDesc => 'Verify your email address';

  @override
  String get documentUpload => 'Document Upload';

  @override
  String get documentUploadDesc => 'Upload your government-issued ID';

  @override
  String get selfieGuidelines => 'Selfie Guidelines';

  @override
  String get lightingTip => 'Make sure you\'re in a well-lit environment before proceeding';

  @override
  String get selfieCapture => 'Selfie Capture';

  @override
  String get selfieCaptureDesc => 'Take a clear photo of your face';

  @override
  String get livenessCheck => 'Liveness Check';

  @override
  String get livenessCheckDesc => 'Verify that you\'re physically present';

  @override
  String get verificationComplete => 'Verification Complete';

  @override
  String get verificationCompleteDesc => 'All steps completed successfully';

  @override
  String get onboardingTitle1 => 'Secure Document Upload';

  @override
  String get onboardingDesc1 => 'Upload or capture your documents with bank-grade security. Your data is encrypted and protected at all times.';

  @override
  String get onboardingTitle2 => 'AI-Powered Verification';

  @override
  String get onboardingDesc2 => 'Experience instant identity verification powered by advanced AI technology. Quick, accurate, and hassle-free.';

  @override
  String get onboardingTitle3 => 'Fast & Reliable Process';

  @override
  String get onboardingDesc3 => 'Complete your KYC verification securely in minutes. Our streamlined process ensures a smooth experience.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get getStarted => 'Get Started';

  @override
  String get uploadId => 'Upload Your ID';

  @override
  String get uploadIdDesc => 'Please upload a clear photo of your government-issued ID (License)';

  @override
  String get chooseUploadMethod => 'Choose Upload Method';

  @override
  String get fromGallery => 'Choose from Gallery';

  @override
  String get fromCamera => 'Capture from Camera';

  @override
  String get noDocument => 'No document selected';

  @override
  String get tapToUpload => 'Tap to upload document';

  @override
  String get tapToChange => 'Tap to change document';

  @override
  String get continue_operation => 'Continue';

  @override
  String get idVisibilityNote => 'Make sure your ID is clearly visible and all text is readable';

  @override
  String get takeSelfie => 'Take Your Selfie';

  @override
  String get selfieGuidelinesTitle => 'Selfie Guidelines';

  @override
  String get goodLighting => 'Good Lighting';

  @override
  String get goodLightingDesc => 'Ensure you are in a well-lit room with natural light';

  @override
  String get facePosition => 'Face Position';

  @override
  String get facePositionDesc => 'Keep your face centered and within the oval guide';

  @override
  String get noFlash => 'No Flash';

  @override
  String get noFlashDesc => 'Avoid using flash, instead use ambient lighting';

  @override
  String get startCamera => 'Start Camera';

  @override
  String get lightingNote => 'Make sure you\'re in a well-lit environment before proceeding';

  @override
  String get reviewSelfie => 'Review Selfie';

  @override
  String get captureError => 'Failed to capture image';

  @override
  String get positionFace => 'Position your face within the oval and ensure good lighting';

  @override
  String get selfieSuccess => 'Selfie captured successfully';

  @override
  String get retake => 'Retake';

  @override
  String get faceVerification => 'Face Verification';

  @override
  String get faceVerificationDesc => 'We need to verify that you\'re a real person to ensure the security of your account.';

  @override
  String get clearView => 'Clear View';

  @override
  String get clearViewDesc => 'Remove glasses, mask or any face coverings';

  @override
  String get cameraReady => 'Camera Ready';

  @override
  String get cameraReadyDesc => 'Position your face within the frame';

  @override
  String get verificationTimeEstimate => 'This process will take less than a minute';

  @override
  String get beginVerification => 'Begin Verification';

  @override
  String get lookUpInstruction => 'Please look up slowly';

  @override
  String get lookDownInstruction => 'Now look down slowly';

  @override
  String get lookLeftInstruction => 'Turn your head to the left';

  @override
  String get lookRightInstruction => 'Finally, turn your head to the right';

  @override
  String get centerHeadInstruction => 'Great! Keep your head centered';

  @override
  String get verificationCompleted => 'Verification completed successfully!';

  @override
  String get verificationSuccess => 'Verification Successful!';

  @override
  String get verificationSuccessTitle => 'Verification Successful!';

  @override
  String get verificationSuccessMessage => 'Your identity has been verified successfully.';

  @override
  String get verificationSuccessDesc => 'Your identity has been verified successfully. You can now proceed with your account.';

  @override
  String get profile => 'Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get documents => 'Documents';

  @override
  String get verificationStatus => 'Verification Status';

  @override
  String get premiumMember => 'Premium Member';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get updateEmail => 'Update Email';

  @override
  String get updateEmailDesc => 'Enter your new email address. A verification link will be sent.';

  @override
  String get updatePhone => 'Update Phone';

  @override
  String get updatePhoneDesc => 'Enter your phone number. A verification code will be sent.';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String get update => 'Update';

  @override
  String get location => 'Location';

  @override
  String get licenseNo => 'License No.';

  @override
  String get passportNo => 'Passport No.';

  @override
  String get idCard => 'ID Card';

  @override
  String get identity => 'Identity';

  @override
  String get verified => 'Verified';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get settings => 'Settings';

  @override
  String get licenseDetails => 'License Details';

  @override
  String get licenseInformation => 'Driver\'s License Information';

  @override
  String get verifyInformation => 'Please verify your information below';

  @override
  String get licenseNumber => 'License Number';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get fatherName => 'Father\'s Name';

  @override
  String get citizenshipNumber => 'Citizenship Number';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get issueDate => 'Date of Issue';

  @override
  String get expiryDate => 'Date of Expiry';

  @override
  String get licenseCategory => 'License Category';

  @override
  String get submit => 'Submit';

  @override
  String pleaseEnter(Object field) {
    return 'Please enter $field';
  }

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidPhoneNumber => 'Please enter a valid phone number';

  @override
  String get invalidCitizenshipNumber => 'Please enter a valid citizenship number';

  @override
  String get invalidLicenseNumber => 'Please enter a valid license number';

  @override
  String get formProgress => 'Form Progress';

  @override
  String step(int current, int total) {
    return 'Step $current of $total';
  }
}
