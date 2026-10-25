// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sessionExpired => 'Your session expired. Sign in again.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabVocabulary => 'Vocabulary';

  @override
  String get tabInbox => 'Inbox';

  @override
  String get tabProfile => 'Profile';

  @override
  String get captureMenuTitle => 'What did you hear today?';

  @override
  String get captureMenuSubtitle =>
      'Snap, record or type. The analysis goes to your Inbox.';

  @override
  String get captureCamera => 'Camera';

  @override
  String get captureAudio => 'Audio';

  @override
  String get captureText => 'Text';

  @override
  String get color => 'Color';

  @override
  String accentName(String accent) {
    String _temp0 = intl.Intl.selectLogic(accent, {
      'violet': 'Violet',
      'coral': 'Coral',
      'mint': 'Mint',
      'mango': 'Mango',
      'sky': 'Sky',
      'pink': 'Pink',
      'grape': 'Grape',
      'cocoa': 'Cocoa',
      'lime': 'Lime',
      'gold': 'Gold',
      'teal': 'Teal',
      'slate': 'Slate',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get loading => 'Loading';

  @override
  String codeFieldLabel(int length) {
    return '$length-digit code';
  }

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get closeMenu => 'Close menu';

  @override
  String get addTerm => 'Add term';

  @override
  String get loadFailedTitle => 'Couldn\'t load';

  @override
  String get loadFailedMessage => 'Check your connection and try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get icon => 'Icon';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String iconPage(String page) {
    return 'Icon page $page';
  }

  @override
  String levelOf(int level, int max) {
    return 'Level $level of $max';
  }

  @override
  String removeItem(String label) {
    return 'Remove $label';
  }

  @override
  String get close => 'Close';

  @override
  String get authOffline => 'Can\'t reach the server. Try again.';

  @override
  String authFailure(String failure) {
    String _temp0 = intl.Intl.selectLogic(failure, {
      'unavailable': 'This sign-in isn\'t available right now.',
      'tooManyAttempts': 'Too many attempts. Wait a bit and try again.',
      'expired': 'This step expired. Start over.',
      'unknown': 'Something went wrong. Try again.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get googleFailed => 'Couldn\'t sign in with Google. Try again.';

  @override
  String get appleFailed => 'Couldn\'t sign in with Apple. Try again.';

  @override
  String get signIn => 'Sign in';

  @override
  String get loginWelcome => 'Good to see you again.';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@email.com';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get forgotPassword => 'Forgot my password';

  @override
  String get newHere => 'New here?';

  @override
  String get createAccount => 'Create account';

  @override
  String get tagline => 'Real English, taken from your everyday conversations.';

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String get forgotSubtitle => 'It happens. We\'ve got you.';

  @override
  String get forgotBody =>
      'Enter your account email. We\'ll send you a code to create a new password.';

  @override
  String get sendCode => 'Send code';

  @override
  String get rememberedPassword => 'Remembered it?';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get newPasswordSubtitle => 'Last step.';

  @override
  String get newPasswordBody =>
      'Create a new password for your account. Once you save it, you\'re in.';

  @override
  String get newPasswordHint => 'Your new password';

  @override
  String get newPasswordHelper => 'At least 8 characters. Avoid numbers only.';

  @override
  String get saveAndSignIn => 'Save and sign in';

  @override
  String get resetCodeTitle => 'Enter the code';

  @override
  String get resetCodeSubtitle => 'To create your new password.';

  @override
  String get signupSubtitle => 'Your vocabulary saved on any phone.';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'What should we call you';

  @override
  String get passwordCreateHint => 'Create a password';

  @override
  String get passwordHelper => 'At least 8 characters.';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get verifyEmailTitle => 'Confirm your email';

  @override
  String get verifyEmailSubtitle => 'Almost there.';

  @override
  String codeSent(int length) {
    return 'We sent a $length-digit code to';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String resendIn(String time) {
    return 'Didn\'t get it? Resend in $time';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get checkSpam => 'Check your spam folder too.';

  @override
  String get changeEmail => 'Change email';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get recording => 'Recording…';

  @override
  String get recordAudio => 'Record audio';

  @override
  String get listenBeforeSaving => 'Listen before saving';

  @override
  String get recordHint => 'Record the sentence the way you heard it';

  @override
  String get micDeniedTitle => 'No microphone access';

  @override
  String get micDeniedMessage =>
      'Allow the microphone in your phone settings to record.';

  @override
  String ofDuration(String max) {
    return 'of $max';
  }

  @override
  String get recordingTime => 'Recording time';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get tapToStop => 'Tap to stop';

  @override
  String get audioPrivacy =>
      'The audio stays on your phone. We only keep the transcript.';

  @override
  String get saveToInbox => 'Save to Inbox';

  @override
  String get reRecord => 'Record again';

  @override
  String get savedProcessing => 'Already processing.';

  @override
  String get savedOffline => 'Pull down the Inbox list when you\'re online.';

  @override
  String get savedReady => 'Ready to pick the terms.';

  @override
  String get savedToInbox => 'Saved to Inbox';

  @override
  String get see => 'See';

  @override
  String get photo => 'Photo';

  @override
  String get photoHint => 'A sign, a menu, a caption';

  @override
  String get checkBeforeSaving => 'Check before saving';

  @override
  String get cameraDeniedTitle => 'No camera access';

  @override
  String get cameraDeniedMessage =>
      'Allow the camera in your phone settings to take photos.';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get takePhotoHint => 'Opens your phone camera';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get pickFromGalleryHint => 'Use a photo you already have';

  @override
  String get photoPrivacy =>
      'The photo stays on your phone. We only keep the text read from it.';

  @override
  String get chosenPhoto => 'Chosen photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get typeText => 'Type text';

  @override
  String get typeTextHint => 'What you heard or read today';

  @override
  String get textCaptureLabel => 'Word, expression or sentence';

  @override
  String get textCaptureHelper =>
      'A sentence or excerpt. You pick the terms in the Inbox.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get homeEmptyTitle => 'Your English starts here';

  @override
  String get homeEmptyMessage =>
      'Capture what you heard or read today, by photo, audio or text. The terms you confirm show up here.';

  @override
  String get homeFirstCapture => 'Make your first capture';

  @override
  String greeting(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'morning': 'Good morning!',
      'afternoon': 'Good afternoon!',
      'evening': 'Good evening!',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String greetingName(String period, String name) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'morning': 'Good morning, $name',
      'afternoon': 'Good afternoon, $name',
      'evening': 'Good evening, $name',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get homeTagline => 'Ready to chat?';

  @override
  String get reviewToday => 'Today\'s review';

  @override
  String termsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms waiting',
      one: '1 term waiting',
      zero: '$count terms waiting',
    );
    return '$_temp0';
  }

  @override
  String get start => 'Start';

  @override
  String get yourVocabulary => 'Your vocabulary';

  @override
  String get seeAll => 'See all';

  @override
  String get totalTerms => 'Total terms';

  @override
  String thisWeek(int count) {
    return '+$count this week';
  }

  @override
  String learningMastered(int learning, int mastered) {
    return '$learning learning, $mastered mastered';
  }

  @override
  String termStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'learning': 'Learning',
      'mastered': 'Mastered',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordOfDay => 'Word of the day';

  @override
  String get listenPronunciation => 'Hear pronunciation';

  @override
  String get addToVocabulary => 'Add to vocabulary';

  @override
  String inboxTab(String tab) {
    String _temp0 = intl.Intl.selectLogic(tab, {
      'all': 'All',
      'ready': 'Ready',
      'pending': 'Pending',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String captureSection(String section) {
    String _temp0 = intl.Intl.selectLogic(section, {
      'attention': 'Needs attention',
      'ready': 'Ready',
      'processing': 'Processing',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noConnectionRetry =>
      'No connection. Try again when you\'re online.';

  @override
  String get inboxEmptyTitle => 'Inbox zero';

  @override
  String get inboxEmptyMessage => 'Use + to capture a new term.';

  @override
  String get nothingHere => 'Nothing here';

  @override
  String get noCapturesInTab => 'No captures in this tab.';

  @override
  String captureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count captures',
      one: '1 capture',
      zero: '$count captures',
    );
    return '$_temp0';
  }

  @override
  String waitingUpload(int count) {
    return '$count waiting to sync';
  }

  @override
  String get discardCapture => 'Discard capture';

  @override
  String get pickTerms => 'Pick terms';

  @override
  String captureSource(String source) {
    String _temp0 = intl.Intl.selectLogic(source, {
      'photo': 'Photo',
      'audio': 'Audio',
      'text': 'Text',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get confirmHint => 'When you confirm, AI builds a card for each term.';

  @override
  String get pickAtLeastOne => 'Pick at least one term';

  @override
  String confirmAnalysisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms',
      one: '1 term',
      zero: '$count terms',
    );
    return 'Confirm analysis · $_temp0';
  }

  @override
  String get pickHelp =>
      'Drag your finger across words to mark an expression. Tap a word to mark just that one.';

  @override
  String get textSection => 'Text';

  @override
  String get done => 'Done';

  @override
  String get editText => 'Edit text';

  @override
  String get editTextHelper =>
      'Fix what came out wrong. Marked terms stay as long as the word doesn\'t change.';

  @override
  String chosenTermsCount(int count) {
    return 'Chosen terms · $count';
  }

  @override
  String get noTermsYetTap => 'None yet. Tap a word in the text.';

  @override
  String termTooLong(int max) {
    return 'Expression too long. Mark up to $max characters.';
  }

  @override
  String tooManyTerms(int max) {
    return 'Limit of $max terms per capture.';
  }

  @override
  String get stop => 'Stop';

  @override
  String get listenRecording => 'Play recording';

  @override
  String get discard => 'Discard';

  @override
  String get processNow => 'Process now';

  @override
  String get edit => 'Edit';

  @override
  String get confirmAnalysis => 'Confirm analysis';

  @override
  String get readingPhoto => 'Reading the photo text…';

  @override
  String get noTextInPhoto => 'No text found in the photo';

  @override
  String get noSpeech => 'No English speech heard';

  @override
  String get noTextInPhotoHint => 'Try another photo or discard this one.';

  @override
  String get noSpeechHint => 'Record again or discard this audio.';

  @override
  String get processFailedTitle => 'Couldn\'t process right now';

  @override
  String get processFailedHint => 'Tap Process now to try again.';

  @override
  String get timeNow => 'now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get yesterday => 'yesterday';

  @override
  String captureStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'failed': 'Error',
      'ready': 'Ready',
      'processing': 'Processing',
      'analyzed': 'Analyzed',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get capturePhoto => 'Capture photo';

  @override
  String captureContent(String source) {
    String _temp0 = intl.Intl.selectLogic(source, {
      'text': 'Your text',
      'photo': 'Photo text',
      'audio': 'Transcript',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get missingPhoto =>
      'The photo is no longer on this phone. The text is still saved.';

  @override
  String get missingAudio =>
      'The audio is no longer on this phone. The transcript is still saved.';

  @override
  String termsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms chosen',
      one: '1 term chosen',
      zero: '$count terms chosen',
    );
    return '$_temp0';
  }

  @override
  String get waitingModel => 'Waiting for the audio model to download…';

  @override
  String get transcribing => 'Transcribing the audio…';

  @override
  String get account => 'Account';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyText =>
      'Photos and audio stay only on this phone. The API keeps only the text.';

  @override
  String get signOut => 'Sign out';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get languageAuto => 'Automatic';

  @override
  String get languageAutoHint => 'Follows your phone\'s language';

  @override
  String languageAutoValue(String language) {
    return 'Automatic · $language';
  }

  @override
  String get languageSheetSubtitle => 'Changes the app\'s text';

  @override
  String modelReady(String size) {
    return 'Transcribed on the phone · $size model';
  }

  @override
  String get ready => 'Ready';

  @override
  String modelDownloading(int percent, String size) {
    return 'Downloading the model: $percent% of $size';
  }

  @override
  String get downloading => 'Downloading';

  @override
  String modelWaiting(String size) {
    return 'The $size model downloads on its own when you\'re online';
  }

  @override
  String get waiting => 'Waiting';

  @override
  String get worksOffline => 'Works offline';

  @override
  String get photoText => 'Text from photos';

  @override
  String get photoTextHint => 'Read on the phone, without sending the photo';

  @override
  String get englishAudio => 'English audio';

  @override
  String get statTerms => 'Terms';

  @override
  String get statLearning => 'Learning';

  @override
  String get statMastered => 'Mastered';

  @override
  String get ungrouped => 'No group';

  @override
  String get moveFailed =>
      'Couldn\'t move right now. Check your internet and try again.';

  @override
  String termsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms moved',
      one: '1 term moved',
      zero: '$count terms moved',
    );
    return '$_temp0';
  }

  @override
  String termsMovedTo(int count, String group) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'They\'re now in $group.',
      one: 'It\'s now in $group.',
      zero: 'They\'re now in $group.',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Undo';

  @override
  String get undoFailed => 'Couldn\'t undo right now.';

  @override
  String get deleteFailed =>
      'Couldn\'t delete right now. Check your internet and try again.';

  @override
  String termsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms deleted',
      one: '1 term deleted',
      zero: '$count terms deleted',
    );
    return '$_temp0';
  }

  @override
  String termsDeletedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'They\'re out of your vocabulary.',
      one: 'It\'s out of your vocabulary.',
      zero: 'They\'re out of your vocabulary.',
    );
    return '$_temp0';
  }

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String get moreOptions => 'More options';

  @override
  String get select => 'Select';

  @override
  String get selectAll => 'Select all';

  @override
  String get delete => 'Delete';

  @override
  String moveTerms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count terms',
      one: 'Move 1 term',
      zero: 'Select terms',
    );
    return '$_temp0';
  }

  @override
  String get allOrganized => 'All organized';

  @override
  String get allOrganizedMessage =>
      'Terms you confirm in your captures land here.';

  @override
  String get groupEmptyTitle => 'No terms here yet';

  @override
  String get groupEmptyMessage =>
      'New terms land in No group. From there, move the ones that belong here.';

  @override
  String get ungroupedHelp =>
      'Terms you confirm in your captures land here. Move each one to its group.';

  @override
  String allCount(int count) {
    return 'All · $count';
  }

  @override
  String selectionMeta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'Tap terms to choose',
    );
    return '$_temp0';
  }

  @override
  String get nothingToOrganize => 'No terms to organize';

  @override
  String termsToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms to put in a group',
      one: '1 term to put in a group',
      zero: '$count terms to put in a group',
    );
    return '$_temp0';
  }

  @override
  String get noTermsYet => 'No terms yet';

  @override
  String termCountMastered(int count, int mastered) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms',
      one: '1 term',
      zero: '$count terms',
    );
    return '$_temp0 · $mastered mastered';
  }

  @override
  String termCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms',
      one: '1 term',
      zero: '$count terms',
    );
    return '$_temp0';
  }

  @override
  String groupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
      zero: '$count groups',
    );
    return '$_temp0';
  }

  @override
  String termsInGroups(String terms, String groups) {
    return '$terms in $groups';
  }

  @override
  String get editGroup => 'Edit group';

  @override
  String get editGroupHint => 'Name, icon and color';

  @override
  String get selectTerms => 'Select terms';

  @override
  String get selectTermsHint => 'Move or delete terms';

  @override
  String get deleteGroup => 'Delete group';

  @override
  String get deleteGroupHint => 'Terms go back to No group';

  @override
  String deleteGroupTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deleteGroupSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The $count terms go back to No group.',
      one: 'The term goes back to No group.',
      zero: 'The group is empty.',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get groupDeleted => 'Group deleted';

  @override
  String groupDeletedMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The $count terms went to No group.',
      one: 'The term went to No group.',
      zero: '$name is off the list.',
    );
    return '$_temp0';
  }

  @override
  String get groupCreated => 'Group created';

  @override
  String groupCreatedMessage(String name) {
    return '$name is at the top of the list.';
  }

  @override
  String get open => 'Open';

  @override
  String get newGroup => 'New group';

  @override
  String get vocabularyEmptyMessage =>
      'Capture and confirm the analysis to get started.';

  @override
  String get organize => 'Organize';

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get noGroupsYetMessage => 'Create a group to organize your terms.';

  @override
  String get createGroup => 'Create group';

  @override
  String get yourGroups => 'Your groups';

  @override
  String get noTermsInGroupYet => 'No terms yet';

  @override
  String percentMastered(int percent) {
    return '$percent% mastered';
  }

  @override
  String groupSaveRejected(String action) {
    String _temp0 = intl.Intl.selectLogic(action, {
      'create': 'Couldn\'t create the group.',
      'save': 'Couldn\'t save the group.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String groupSaveFailed(String action) {
    String _temp0 = intl.Intl.selectLogic(action, {
      'create': 'Couldn\'t create the group right now. Try again.',
      'save': 'Couldn\'t save the group right now. Try again.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get offlineRetry => 'No connection. Try again.';

  @override
  String get groupSheetNewHint => 'Group terms on the same topic';

  @override
  String get groupSheetEditHint => 'Change the name, icon or color';

  @override
  String get groupNameHint => 'E.g.: Music, College';

  @override
  String get groupNameTaken => 'You already have a group with that name.';

  @override
  String get nameTheGroup => 'Name the group';

  @override
  String get save => 'Save';

  @override
  String get moveSheetTitle => 'Move to which group?';

  @override
  String moveSheetSubtitle(String terms, String from) {
    return '$terms from $from';
  }

  @override
  String get noGroupsTitle => 'You don\'t have groups yet';

  @override
  String get noGroupsMessage => 'Create a group to keep these terms.';

  @override
  String termKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'word': 'Word',
      'expression': 'Expression',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String groupIcon(String icon) {
    String _temp0 = intl.Intl.selectLogic(icon, {
      'layers': 'General',
      'talk': 'Conversation',
      'work': 'Work',
      'travel': 'Travel',
      'food': 'Food',
      'tv': 'TV shows',
      'music': 'Music',
      'study': 'Studies',
      'heart': 'Favorites',
      'game': 'Games',
      'shopping': 'Shopping',
      'sport': 'Sports',
      'health': 'Health',
      'home': 'Home',
      'nature': 'Nature',
      'paw': 'Animals',
      'tech': 'Technology',
      'money': 'Money',
      'car': 'Transportation',
      'family': 'Family',
      'book': 'Books',
      'art': 'Art',
      'party': 'Party',
      'weather': 'Weather',
      'phone': 'Phone',
      'mail': 'Email',
      'code': 'Programming',
      'science': 'Science',
      'news': 'News',
      'movie': 'Movies',
      'camera': 'Photography',
      'place': 'Places',
      'city': 'City',
      'globe': 'World',
      'calendar': 'Dates',
      'clock': 'Routine',
      'star': 'Important',
      'idea': 'Ideas',
      'smile': 'Feelings',
      'shirt': 'Clothes',
      'restaurant': 'Restaurant',
      'drink': 'Drinks',
      'mountain': 'Adventure',
      'gift': 'Gifts',
      'flag': 'Countries',
      'podcast': 'Podcasts',
      'goal': 'Goals',
      'writing': 'Writing',
      'other': '',
    });
    return '$_temp0';
  }
}
