import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart KYC'**
  String get appTitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the form to create your account'**
  String get createAccountDesc;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUpError.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign up: {error}'**
  String signUpError(String error);

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified My Email'**
  String get verifyNow;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendEmail;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @dataExtraction.
  ///
  /// In en, this message translates to:
  /// **'Extracting Data ...'**
  String get dataExtraction;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @signUpSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Created Successfully!'**
  String get signUpSuccessTitle;

  /// No description provided for @signUpSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created. Verification link sent to:'**
  String get signUpSuccessMessage;

  /// No description provided for @continueToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue to Sign In'**
  String get continueToSignIn;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address, and we will send you a link to reset your password.'**
  String get forgotPasswordDesc;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Link Sent'**
  String get resetLinkSent;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @resetLinkSentDesc.
  ///
  /// In en, this message translates to:
  /// **'If an account exists with this email, you will receive a password reset link shortly.'**
  String get resetLinkSentDesc;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Logout Confirmation'**
  String get logoutConfirmation;

  /// No description provided for @logoutConfirmationDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmationDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @signInError.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in: {error}'**
  String signInError(String error);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SmartKYC'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to continue'**
  String get welcomeSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @sendingCode.
  ///
  /// In en, this message translates to:
  /// **'Sending code...'**
  String get sendingCode;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmail;

  /// No description provided for @verifyEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification code to\n{email}'**
  String verifyEmailDesc(String email);

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait for a while ...'**
  String get pleaseWait;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @verificationExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification code expired. Please request a new one.'**
  String get verificationExpired;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get invalidCode;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed: {error}'**
  String verificationFailed(String error);

  /// No description provided for @verificationSteps.
  ///
  /// In en, this message translates to:
  /// **'Verification Steps'**
  String get verificationSteps;

  /// No description provided for @languageSwitchWarn.
  ///
  /// In en, this message translates to:
  /// **'* Language preference will persist throughout the verification Process'**
  String get languageSwitchWarn;

  /// No description provided for @verificationStepsDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete these steps to verify your identity'**
  String get verificationStepsDesc;

  /// No description provided for @documentUploadTip.
  ///
  /// In en, this message translates to:
  /// **'Make sure your ID is clearly visible and all text is readable'**
  String get documentUploadTip;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @noDocumentSelected.
  ///
  /// In en, this message translates to:
  /// **'No document selected'**
  String get noDocumentSelected;

  /// No description provided for @tapToChangeDocument.
  ///
  /// In en, this message translates to:
  /// **'Tap to change document'**
  String get tapToChangeDocument;

  /// No description provided for @tapToUploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload document'**
  String get tapToUploadDocument;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @captureFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Capture from Camera'**
  String get captureFromCamera;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedToPickImage;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get cameraPermissionDenied;

  /// No description provided for @failedToCaptureImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image'**
  String get failedToCaptureImage;

  /// No description provided for @invalidImageFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid image file'**
  String get invalidImageFile;

  /// No description provided for @startVerification.
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get startVerification;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @emailVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Verify your email address'**
  String get emailVerificationDesc;

  /// No description provided for @documentUpload.
  ///
  /// In en, this message translates to:
  /// **'Document Upload'**
  String get documentUpload;

  /// No description provided for @documentUploadDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload your government-issued ID'**
  String get documentUploadDesc;

  /// No description provided for @selfieGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Selfie Guidelines'**
  String get selfieGuidelines;

  /// No description provided for @lightingTip.
  ///
  /// In en, this message translates to:
  /// **'Make sure you\'re in a well-lit environment before proceeding'**
  String get lightingTip;

  /// No description provided for @selfieCapture.
  ///
  /// In en, this message translates to:
  /// **'Selfie Capture'**
  String get selfieCapture;

  /// No description provided for @selfieCaptureDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of your face'**
  String get selfieCaptureDesc;

  /// No description provided for @livenessCheck.
  ///
  /// In en, this message translates to:
  /// **'Liveness Check'**
  String get livenessCheck;

  /// No description provided for @livenessCheckDesc.
  ///
  /// In en, this message translates to:
  /// **'Verify that you\'re physically present'**
  String get livenessCheckDesc;

  /// No description provided for @verificationComplete.
  ///
  /// In en, this message translates to:
  /// **'Verification Complete'**
  String get verificationComplete;

  /// No description provided for @verificationCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'All steps completed successfully'**
  String get verificationCompleteDesc;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Secure Document Upload'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Upload or capture your documents with bank-grade security. Your data is encrypted and protected at all times.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Verification'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Experience instant identity verification powered by advanced AI technology. Quick, accurate, and hassle-free.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Fast & Reliable Process'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Complete your KYC verification securely in minutes. Our streamlined process ensures a smooth experience.'**
  String get onboardingDesc3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @uploadId.
  ///
  /// In en, this message translates to:
  /// **'Upload Your ID'**
  String get uploadId;

  /// No description provided for @uploadIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Please upload a clear photo of your government-issued ID (License)'**
  String get uploadIdDesc;

  /// No description provided for @chooseUploadMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose Upload Method'**
  String get chooseUploadMethod;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get fromGallery;

  /// No description provided for @fromCamera.
  ///
  /// In en, this message translates to:
  /// **'Capture from Camera'**
  String get fromCamera;

  /// No description provided for @noDocument.
  ///
  /// In en, this message translates to:
  /// **'No document selected'**
  String get noDocument;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload document'**
  String get tapToUpload;

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change document'**
  String get tapToChange;

  /// No description provided for @continue_operation.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_operation;

  /// No description provided for @idVisibilityNote.
  ///
  /// In en, this message translates to:
  /// **'Make sure your ID is clearly visible and all text is readable'**
  String get idVisibilityNote;

  /// No description provided for @takeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Take Your Selfie'**
  String get takeSelfie;

  /// No description provided for @selfieGuidelinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Selfie Guidelines'**
  String get selfieGuidelinesTitle;

  /// No description provided for @goodLighting.
  ///
  /// In en, this message translates to:
  /// **'Good Lighting'**
  String get goodLighting;

  /// No description provided for @goodLightingDesc.
  ///
  /// In en, this message translates to:
  /// **'Ensure you are in a well-lit room with natural light'**
  String get goodLightingDesc;

  /// No description provided for @facePosition.
  ///
  /// In en, this message translates to:
  /// **'Face Position'**
  String get facePosition;

  /// No description provided for @facePositionDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your face centered and within the oval guide'**
  String get facePositionDesc;

  /// No description provided for @noFlash.
  ///
  /// In en, this message translates to:
  /// **'No Flash'**
  String get noFlash;

  /// No description provided for @noFlashDesc.
  ///
  /// In en, this message translates to:
  /// **'Avoid using flash, instead use ambient lighting'**
  String get noFlashDesc;

  /// No description provided for @startCamera.
  ///
  /// In en, this message translates to:
  /// **'Start Camera'**
  String get startCamera;

  /// No description provided for @lightingNote.
  ///
  /// In en, this message translates to:
  /// **'Make sure you\'re in a well-lit environment before proceeding'**
  String get lightingNote;

  /// No description provided for @reviewSelfie.
  ///
  /// In en, this message translates to:
  /// **'Review Selfie'**
  String get reviewSelfie;

  /// No description provided for @captureError.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image'**
  String get captureError;

  /// No description provided for @positionFace.
  ///
  /// In en, this message translates to:
  /// **'Position your face within the oval and ensure good lighting'**
  String get positionFace;

  /// No description provided for @selfieSuccess.
  ///
  /// In en, this message translates to:
  /// **'Selfie captured successfully'**
  String get selfieSuccess;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @faceVerification.
  ///
  /// In en, this message translates to:
  /// **'Face Verification'**
  String get faceVerification;

  /// No description provided for @faceVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'We need to verify that you\'re a real person to ensure the security of your account.'**
  String get faceVerificationDesc;

  /// No description provided for @clearView.
  ///
  /// In en, this message translates to:
  /// **'Clear View'**
  String get clearView;

  /// No description provided for @clearViewDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove glasses, mask or any face coverings'**
  String get clearViewDesc;

  /// No description provided for @cameraReady.
  ///
  /// In en, this message translates to:
  /// **'Camera Ready'**
  String get cameraReady;

  /// No description provided for @cameraReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Position your face within the frame'**
  String get cameraReadyDesc;

  /// No description provided for @verificationTimeEstimate.
  ///
  /// In en, this message translates to:
  /// **'This process will take less than a minute'**
  String get verificationTimeEstimate;

  /// No description provided for @beginVerification.
  ///
  /// In en, this message translates to:
  /// **'Begin Verification'**
  String get beginVerification;

  /// No description provided for @lookUpInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please look up slowly'**
  String get lookUpInstruction;

  /// No description provided for @lookDownInstruction.
  ///
  /// In en, this message translates to:
  /// **'Now look down slowly'**
  String get lookDownInstruction;

  /// No description provided for @lookLeftInstruction.
  ///
  /// In en, this message translates to:
  /// **'Turn your head to the left'**
  String get lookLeftInstruction;

  /// No description provided for @lookRightInstruction.
  ///
  /// In en, this message translates to:
  /// **'Finally, turn your head to the right'**
  String get lookRightInstruction;

  /// No description provided for @centerHeadInstruction.
  ///
  /// In en, this message translates to:
  /// **'Great! Keep your head centered'**
  String get centerHeadInstruction;

  /// No description provided for @verificationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Verification completed successfully!'**
  String get verificationCompleted;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification Successful!'**
  String get verificationSuccess;

  /// No description provided for @verificationSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Successful!'**
  String get verificationSuccessTitle;

  /// No description provided for @verificationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified successfully.'**
  String get verificationSuccessMessage;

  /// No description provided for @verificationSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified successfully. You can now proceed with your account.'**
  String get verificationSuccessDesc;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get verificationStatus;

  /// No description provided for @premiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get premiumMember;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @updateEmail.
  ///
  /// In en, this message translates to:
  /// **'Update Email'**
  String get updateEmail;

  /// No description provided for @updateEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your new email address. A verification link will be sent.'**
  String get updateEmailDesc;

  /// No description provided for @updatePhone.
  ///
  /// In en, this message translates to:
  /// **'Update Phone'**
  String get updatePhone;

  /// No description provided for @updatePhoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number. A verification code will be sent.'**
  String get updatePhoneDesc;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @licenseNo.
  ///
  /// In en, this message translates to:
  /// **'License No.'**
  String get licenseNo;

  /// No description provided for @passportNo.
  ///
  /// In en, this message translates to:
  /// **'Passport No.'**
  String get passportNo;

  /// No description provided for @idCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get idCard;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @licenseDetails.
  ///
  /// In en, this message translates to:
  /// **'License Details'**
  String get licenseDetails;

  /// No description provided for @licenseInformation.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License Information'**
  String get licenseInformation;

  /// No description provided for @verifyInformation.
  ///
  /// In en, this message translates to:
  /// **'Please verify your information below'**
  String get verifyInformation;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get fatherName;

  /// No description provided for @citizenshipNumber.
  ///
  /// In en, this message translates to:
  /// **'Citizenship Number'**
  String get citizenshipNumber;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Issue'**
  String get issueDate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Expiry'**
  String get expiryDate;

  /// No description provided for @licenseCategory.
  ///
  /// In en, this message translates to:
  /// **'License Category'**
  String get licenseCategory;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String pleaseEnter(Object field);

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @invalidCitizenshipNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid citizenship number'**
  String get invalidCitizenshipNumber;

  /// No description provided for @invalidLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid license number'**
  String get invalidLicenseNumber;

  /// No description provided for @formProgress.
  ///
  /// In en, this message translates to:
  /// **'Form Progress'**
  String get formProgress;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String step(int current, int total);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ne': return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
