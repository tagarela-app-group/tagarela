import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @sessionExpired.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão expirou. Entre de novo.'**
  String get sessionExpired;

  /// No description provided for @tabHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get tabHome;

  /// No description provided for @tabVocabulary.
  ///
  /// In pt, this message translates to:
  /// **'Vocabulário'**
  String get tabVocabulary;

  /// No description provided for @tabInbox.
  ///
  /// In pt, this message translates to:
  /// **'Inbox'**
  String get tabInbox;

  /// No description provided for @tabProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get tabProfile;

  /// No description provided for @captureMenuTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que você ouviu hoje?'**
  String get captureMenuTitle;

  /// No description provided for @captureMenuSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Fotografe, grave ou digite. A análise vai pro Inbox.'**
  String get captureMenuSubtitle;

  /// No description provided for @captureCamera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get captureCamera;

  /// No description provided for @captureAudio.
  ///
  /// In pt, this message translates to:
  /// **'Áudio'**
  String get captureAudio;

  /// No description provided for @captureText.
  ///
  /// In pt, this message translates to:
  /// **'Texto'**
  String get captureText;

  /// No description provided for @color.
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get color;

  /// No description provided for @accentName.
  ///
  /// In pt, this message translates to:
  /// **'{accent, select, violet{Violeta} coral{Coral} mint{Menta} mango{Manga} sky{Céu} pink{Rosa} grape{Uva} cocoa{Cacau} lime{Lima} gold{Ouro} teal{Turquesa} slate{Ardósia} other{}}'**
  String accentName(String accent);

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando'**
  String get loading;

  /// No description provided for @codeFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'Código de {length} dígitos'**
  String codeFieldLabel(int length);

  /// No description provided for @showPassword.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get hidePassword;

  /// No description provided for @closeMenu.
  ///
  /// In pt, this message translates to:
  /// **'Fechar menu'**
  String get closeMenu;

  /// No description provided for @addTerm.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar termo'**
  String get addTerm;

  /// No description provided for @loadFailedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra carregar'**
  String get loadFailedTitle;

  /// No description provided for @loadFailedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Confira sua conexão e tente de novo.'**
  String get loadFailedMessage;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get tryAgain;

  /// No description provided for @icon.
  ///
  /// In pt, this message translates to:
  /// **'Ícone'**
  String get icon;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @next.
  ///
  /// In pt, this message translates to:
  /// **'Avançar'**
  String get next;

  /// No description provided for @iconPage.
  ///
  /// In pt, this message translates to:
  /// **'Página {page} dos ícones'**
  String iconPage(String page);

  /// No description provided for @levelOf.
  ///
  /// In pt, this message translates to:
  /// **'Nível {level} de {max}'**
  String levelOf(int level, int max);

  /// No description provided for @removeItem.
  ///
  /// In pt, this message translates to:
  /// **'Remover {label}'**
  String removeItem(String label);

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @authOffline.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com o servidor. Tente de novo.'**
  String get authOffline;

  /// No description provided for @authFailure.
  ///
  /// In pt, this message translates to:
  /// **'{failure, select, unavailable{Esse login não está disponível agora.} tooManyAttempts{Muitas tentativas. Espere um pouco e tente de novo.} expired{Essa etapa expirou. Comece de novo.} unknown{Não deu certo. Tente de novo.} other{}}'**
  String authFailure(String failure);

  /// No description provided for @googleFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra entrar com o Google. Tente de novo.'**
  String get googleFailed;

  /// No description provided for @appleFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra entrar com a Apple. Tente de novo.'**
  String get appleFailed;

  /// No description provided for @signIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signIn;

  /// No description provided for @loginWelcome.
  ///
  /// In pt, this message translates to:
  /// **'Que bom te ver de novo.'**
  String get loginWelcome;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'voce@email.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In pt, this message translates to:
  /// **'Sua senha'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get forgotPassword;

  /// No description provided for @newHere.
  ///
  /// In pt, this message translates to:
  /// **'Novo por aqui?'**
  String get newHere;

  /// No description provided for @createAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// No description provided for @tagline.
  ///
  /// In pt, this message translates to:
  /// **'Inglês de verdade, tirado das conversas do seu dia.'**
  String get tagline;

  /// No description provided for @forgotTitle.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acontece. A gente te ajuda.'**
  String get forgotSubtitle;

  /// No description provided for @forgotBody.
  ///
  /// In pt, this message translates to:
  /// **'Digite o e-mail da sua conta. Enviamos um código pra você criar uma senha nova.'**
  String get forgotBody;

  /// No description provided for @sendCode.
  ///
  /// In pt, this message translates to:
  /// **'Enviar código'**
  String get sendCode;

  /// No description provided for @rememberedPassword.
  ///
  /// In pt, this message translates to:
  /// **'Lembrou a senha?'**
  String get rememberedPassword;

  /// No description provided for @newPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Última etapa.'**
  String get newPasswordSubtitle;

  /// No description provided for @newPasswordBody.
  ///
  /// In pt, this message translates to:
  /// **'Crie uma senha nova pra sua conta. Depois de salvar, você já entra no app.'**
  String get newPasswordBody;

  /// No description provided for @newPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Sua senha nova'**
  String get newPasswordHint;

  /// No description provided for @newPasswordHelper.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de 8 caracteres. Evite só números.'**
  String get newPasswordHelper;

  /// No description provided for @saveAndSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Salvar e entrar'**
  String get saveAndSignIn;

  /// No description provided for @resetCodeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Digite o código'**
  String get resetCodeTitle;

  /// No description provided for @resetCodeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pra criar sua senha nova.'**
  String get resetCodeSubtitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu vocabulário salvo em qualquer celular.'**
  String get signupSubtitle;

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In pt, this message translates to:
  /// **'Como quer ser chamado'**
  String get nameHint;

  /// No description provided for @passwordCreateHint.
  ///
  /// In pt, this message translates to:
  /// **'Crie uma senha'**
  String get passwordCreateHint;

  /// No description provided for @passwordHelper.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de 8 caracteres.'**
  String get passwordHelper;

  /// No description provided for @haveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta?'**
  String get haveAccount;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirme seu e-mail'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Falta pouco pra começar.'**
  String get verifyEmailSubtitle;

  /// No description provided for @codeSent.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um código de {length} dígitos para'**
  String codeSent(int length);

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @resendIn.
  ///
  /// In pt, this message translates to:
  /// **'Não chegou? Reenviar em {time}'**
  String resendIn(String time);

  /// No description provided for @resendCode.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar código'**
  String get resendCode;

  /// No description provided for @checkSpam.
  ///
  /// In pt, this message translates to:
  /// **'Confira também a caixa de spam.'**
  String get checkSpam;

  /// No description provided for @changeEmail.
  ///
  /// In pt, this message translates to:
  /// **'Trocar e-mail'**
  String get changeEmail;

  /// No description provided for @or.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com a Apple'**
  String get continueWithApple;

  /// No description provided for @recording.
  ///
  /// In pt, this message translates to:
  /// **'Gravando…'**
  String get recording;

  /// No description provided for @recordAudio.
  ///
  /// In pt, this message translates to:
  /// **'Gravar áudio'**
  String get recordAudio;

  /// No description provided for @listenBeforeSaving.
  ///
  /// In pt, this message translates to:
  /// **'Ouça antes de salvar'**
  String get listenBeforeSaving;

  /// No description provided for @recordHint.
  ///
  /// In pt, this message translates to:
  /// **'Grave a frase do jeito que ouviu'**
  String get recordHint;

  /// No description provided for @micDeniedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem acesso ao microfone'**
  String get micDeniedTitle;

  /// No description provided for @micDeniedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Libere o microfone nas configurações do celular pra gravar.'**
  String get micDeniedMessage;

  /// No description provided for @ofDuration.
  ///
  /// In pt, this message translates to:
  /// **'de {max}'**
  String ofDuration(String max);

  /// No description provided for @recordingTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo de gravação'**
  String get recordingTime;

  /// No description provided for @stopRecording.
  ///
  /// In pt, this message translates to:
  /// **'Parar gravação'**
  String get stopRecording;

  /// No description provided for @tapToStop.
  ///
  /// In pt, this message translates to:
  /// **'Toque para parar'**
  String get tapToStop;

  /// No description provided for @audioPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'O áudio fica só no seu celular. A gente guarda apenas a transcrição.'**
  String get audioPrivacy;

  /// No description provided for @saveToInbox.
  ///
  /// In pt, this message translates to:
  /// **'Salvar no Inbox'**
  String get saveToInbox;

  /// No description provided for @reRecord.
  ///
  /// In pt, this message translates to:
  /// **'Regravar'**
  String get reRecord;

  /// No description provided for @savedProcessing.
  ///
  /// In pt, this message translates to:
  /// **'Já está processando.'**
  String get savedProcessing;

  /// No description provided for @savedOffline.
  ///
  /// In pt, this message translates to:
  /// **'Puxe a lista no Inbox quando tiver internet.'**
  String get savedOffline;

  /// No description provided for @savedReady.
  ///
  /// In pt, this message translates to:
  /// **'Pronto pra escolher os termos.'**
  String get savedReady;

  /// No description provided for @savedToInbox.
  ///
  /// In pt, this message translates to:
  /// **'Salvo no Inbox'**
  String get savedToInbox;

  /// No description provided for @see.
  ///
  /// In pt, this message translates to:
  /// **'Ver'**
  String get see;

  /// No description provided for @photo.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get photo;

  /// No description provided for @photoHint.
  ///
  /// In pt, this message translates to:
  /// **'Uma placa, um cardápio, uma legenda'**
  String get photoHint;

  /// No description provided for @checkBeforeSaving.
  ///
  /// In pt, this message translates to:
  /// **'Confira antes de salvar'**
  String get checkBeforeSaving;

  /// No description provided for @cameraDeniedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem acesso à câmera'**
  String get cameraDeniedTitle;

  /// No description provided for @cameraDeniedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Libere a câmera nas configurações do celular pra tirar foto.'**
  String get cameraDeniedMessage;

  /// No description provided for @takePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get takePhoto;

  /// No description provided for @takePhotoHint.
  ///
  /// In pt, this message translates to:
  /// **'Abre a câmera do celular'**
  String get takePhotoHint;

  /// No description provided for @pickFromGallery.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get pickFromGallery;

  /// No description provided for @pickFromGalleryHint.
  ///
  /// In pt, this message translates to:
  /// **'Usa uma foto que você já tem'**
  String get pickFromGalleryHint;

  /// No description provided for @photoPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'A foto fica só no seu celular. A gente guarda apenas o texto lido dela.'**
  String get photoPrivacy;

  /// No description provided for @chosenPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Foto escolhida'**
  String get chosenPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Trocar foto'**
  String get changePhoto;

  /// No description provided for @typeText.
  ///
  /// In pt, this message translates to:
  /// **'Digitar texto'**
  String get typeText;

  /// No description provided for @typeTextHint.
  ///
  /// In pt, this message translates to:
  /// **'O que você ouviu ou leu hoje'**
  String get typeTextHint;

  /// No description provided for @textCaptureLabel.
  ///
  /// In pt, this message translates to:
  /// **'Palavra, expressão ou frase'**
  String get textCaptureLabel;

  /// No description provided for @textCaptureHelper.
  ///
  /// In pt, this message translates to:
  /// **'Frase ou trecho. Os termos você escolhe no Inbox.'**
  String get textCaptureHelper;

  /// No description provided for @openSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir configurações'**
  String get openSettings;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu inglês começa aqui'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Capture o que você ouviu ou leu hoje, por foto, áudio ou texto. Os termos que você confirmar aparecem aqui.'**
  String get homeEmptyMessage;

  /// No description provided for @homeFirstCapture.
  ///
  /// In pt, this message translates to:
  /// **'Fazer a primeira captura'**
  String get homeFirstCapture;

  /// No description provided for @greeting.
  ///
  /// In pt, this message translates to:
  /// **'{period, select, morning{Bom dia!} afternoon{Boa tarde!} evening{Boa noite!} other{}}'**
  String greeting(String period);

  /// No description provided for @greetingName.
  ///
  /// In pt, this message translates to:
  /// **'{period, select, morning{Bom dia, {name}} afternoon{Boa tarde, {name}} evening{Boa noite, {name}} other{}}'**
  String greetingName(String period, String name);

  /// No description provided for @homeTagline.
  ///
  /// In pt, this message translates to:
  /// **'Vamos tagarelar?'**
  String get homeTagline;

  /// No description provided for @reviewToday.
  ///
  /// In pt, this message translates to:
  /// **'Revisão de hoje'**
  String get reviewToday;

  /// No description provided for @termsWaiting.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} termos esperando} =1{1 termo esperando} other{{count} termos esperando}}'**
  String termsWaiting(int count);

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get start;

  /// No description provided for @yourVocabulary.
  ///
  /// In pt, this message translates to:
  /// **'Seu vocabulário'**
  String get yourVocabulary;

  /// No description provided for @seeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get seeAll;

  /// No description provided for @totalTerms.
  ///
  /// In pt, this message translates to:
  /// **'Total de termos'**
  String get totalTerms;

  /// No description provided for @thisWeek.
  ///
  /// In pt, this message translates to:
  /// **'+{count} esta semana'**
  String thisWeek(int count);

  /// No description provided for @learningMastered.
  ///
  /// In pt, this message translates to:
  /// **'{learning} aprendendo, {mastered} dominados'**
  String learningMastered(int learning, int mastered);

  /// No description provided for @termStatus.
  ///
  /// In pt, this message translates to:
  /// **'{status, select, learning{Aprendendo} mastered{Dominado} other{}}'**
  String termStatus(String status);

  /// No description provided for @wordOfDay.
  ///
  /// In pt, this message translates to:
  /// **'Palavra do dia'**
  String get wordOfDay;

  /// No description provided for @listenPronunciation.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir pronúncia'**
  String get listenPronunciation;

  /// No description provided for @addToVocabulary.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ao vocabulário'**
  String get addToVocabulary;

  /// No description provided for @inboxTab.
  ///
  /// In pt, this message translates to:
  /// **'{tab, select, all{Todas} ready{Prontas} pending{Pendentes} other{}}'**
  String inboxTab(String tab);

  /// No description provided for @captureSection.
  ///
  /// In pt, this message translates to:
  /// **'{section, select, attention{Precisa de atenção} ready{Prontas} processing{Processando} other{}}'**
  String captureSection(String section);

  /// No description provided for @noConnectionRetry.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Tente de novo quando tiver internet.'**
  String get noConnectionRetry;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Inbox zerado'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Use o + para capturar um termo novo.'**
  String get inboxEmptyMessage;

  /// No description provided for @nothingHere.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui'**
  String get nothingHere;

  /// No description provided for @noCapturesInTab.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma captura nessa aba.'**
  String get noCapturesInTab;

  /// No description provided for @captureCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} capturas} =1{1 captura} other{{count} capturas}}'**
  String captureCount(int count);

  /// No description provided for @waitingUpload.
  ///
  /// In pt, this message translates to:
  /// **'{count} esperando envio'**
  String waitingUpload(int count);

  /// No description provided for @discardCapture.
  ///
  /// In pt, this message translates to:
  /// **'Descartar captura'**
  String get discardCapture;

  /// No description provided for @pickTerms.
  ///
  /// In pt, this message translates to:
  /// **'Escolher termos'**
  String get pickTerms;

  /// No description provided for @captureSource.
  ///
  /// In pt, this message translates to:
  /// **'{source, select, photo{Foto} audio{Áudio} text{Texto} other{}}'**
  String captureSource(String source);

  /// No description provided for @confirmHint.
  ///
  /// In pt, this message translates to:
  /// **'Ao confirmar, a IA monta a ficha de cada termo.'**
  String get confirmHint;

  /// No description provided for @pickAtLeastOne.
  ///
  /// In pt, this message translates to:
  /// **'Escolha pelo menos um termo'**
  String get pickAtLeastOne;

  /// No description provided for @confirmAnalysisCount.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar análise · {count, plural, =0{{count} termos} =1{1 termo} other{{count} termos}}'**
  String confirmAnalysisCount(int count);

  /// No description provided for @pickHelp.
  ///
  /// In pt, this message translates to:
  /// **'Arraste o dedo sobre as palavras pra marcar uma expressão. Toque numa palavra pra marcar só ela.'**
  String get pickHelp;

  /// No description provided for @textSection.
  ///
  /// In pt, this message translates to:
  /// **'Texto'**
  String get textSection;

  /// No description provided for @done.
  ///
  /// In pt, this message translates to:
  /// **'Pronto'**
  String get done;

  /// No description provided for @editText.
  ///
  /// In pt, this message translates to:
  /// **'Editar texto'**
  String get editText;

  /// No description provided for @editTextHelper.
  ///
  /// In pt, this message translates to:
  /// **'Corrija o que saiu errado. Os termos marcados continuam quando a palavra não mudar.'**
  String get editTextHelper;

  /// No description provided for @chosenTermsCount.
  ///
  /// In pt, this message translates to:
  /// **'Termos escolhidos · {count}'**
  String chosenTermsCount(int count);

  /// No description provided for @noTermsYetTap.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ainda. Toque numa palavra do texto.'**
  String get noTermsYetTap;

  /// No description provided for @termTooLong.
  ///
  /// In pt, this message translates to:
  /// **'Expressão grande demais. Marque até {max} caracteres.'**
  String termTooLong(int max);

  /// No description provided for @tooManyTerms.
  ///
  /// In pt, this message translates to:
  /// **'Limite de {max} termos por captura.'**
  String tooManyTerms(int max);

  /// No description provided for @stop.
  ///
  /// In pt, this message translates to:
  /// **'Parar'**
  String get stop;

  /// No description provided for @listenRecording.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir gravação'**
  String get listenRecording;

  /// No description provided for @discard.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get discard;

  /// No description provided for @processNow.
  ///
  /// In pt, this message translates to:
  /// **'Processar agora'**
  String get processNow;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @confirmAnalysis.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar análise'**
  String get confirmAnalysis;

  /// No description provided for @readingPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Lendo o texto da foto…'**
  String get readingPhoto;

  /// No description provided for @noTextInPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Não achei texto na foto'**
  String get noTextInPhoto;

  /// No description provided for @noSpeech.
  ///
  /// In pt, this message translates to:
  /// **'Não ouvi fala em inglês'**
  String get noSpeech;

  /// No description provided for @noTextInPhotoHint.
  ///
  /// In pt, this message translates to:
  /// **'Tente outra foto ou descarte esta.'**
  String get noTextInPhotoHint;

  /// No description provided for @noSpeechHint.
  ///
  /// In pt, this message translates to:
  /// **'Grave de novo ou descarte este áudio.'**
  String get noSpeechHint;

  /// No description provided for @processFailedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra processar agora'**
  String get processFailedTitle;

  /// No description provided for @processFailedHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em Processar agora pra tentar de novo.'**
  String get processFailedHint;

  /// No description provided for @timeNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get timeNow;

  /// No description provided for @minutesAgo.
  ///
  /// In pt, this message translates to:
  /// **'há {minutes} min'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In pt, this message translates to:
  /// **'há {hours} h'**
  String hoursAgo(int hours);

  /// No description provided for @yesterday.
  ///
  /// In pt, this message translates to:
  /// **'ontem'**
  String get yesterday;

  /// No description provided for @captureStatus.
  ///
  /// In pt, this message translates to:
  /// **'{status, select, failed{Erro} ready{Pronta} processing{Processando} analyzed{Analisada} other{}}'**
  String captureStatus(String status);

  /// No description provided for @capturePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Foto da captura'**
  String get capturePhoto;

  /// No description provided for @captureContent.
  ///
  /// In pt, this message translates to:
  /// **'{source, select, text{Seu texto} photo{Texto da foto} audio{Transcrição} other{}}'**
  String captureContent(String source);

  /// No description provided for @missingPhoto.
  ///
  /// In pt, this message translates to:
  /// **'A foto não está mais neste celular. O texto continua salvo.'**
  String get missingPhoto;

  /// No description provided for @missingAudio.
  ///
  /// In pt, this message translates to:
  /// **'O áudio não está mais neste celular. A transcrição continua salva.'**
  String get missingAudio;

  /// No description provided for @termsChosen.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} termos escolhidos} =1{1 termo escolhido} other{{count} termos escolhidos}}'**
  String termsChosen(int count);

  /// No description provided for @waitingModel.
  ///
  /// In pt, this message translates to:
  /// **'Esperando o modelo de áudio baixar…'**
  String get waitingModel;

  /// No description provided for @transcribing.
  ///
  /// In pt, this message translates to:
  /// **'Transcrevendo o áudio…'**
  String get transcribing;

  /// No description provided for @account.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get account;

  /// No description provided for @privacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get privacy;

  /// No description provided for @privacyText.
  ///
  /// In pt, this message translates to:
  /// **'Foto e áudio ficam só neste celular. A API guarda só o texto.'**
  String get privacyText;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @modelReady.
  ///
  /// In pt, this message translates to:
  /// **'Transcrito no celular · modelo de {size}'**
  String modelReady(String size);

  /// No description provided for @ready.
  ///
  /// In pt, this message translates to:
  /// **'Pronto'**
  String get ready;

  /// No description provided for @modelDownloading.
  ///
  /// In pt, this message translates to:
  /// **'Baixando o modelo: {percent}% de {size}'**
  String modelDownloading(int percent, String size);

  /// No description provided for @downloading.
  ///
  /// In pt, this message translates to:
  /// **'Baixando'**
  String get downloading;

  /// No description provided for @modelWaiting.
  ///
  /// In pt, this message translates to:
  /// **'O modelo de {size} baixa sozinho quando tiver internet'**
  String modelWaiting(String size);

  /// No description provided for @waiting.
  ///
  /// In pt, this message translates to:
  /// **'Esperando'**
  String get waiting;

  /// No description provided for @worksOffline.
  ///
  /// In pt, this message translates to:
  /// **'Funciona sem internet'**
  String get worksOffline;

  /// No description provided for @photoText.
  ///
  /// In pt, this message translates to:
  /// **'Texto de fotos'**
  String get photoText;

  /// No description provided for @photoTextHint.
  ///
  /// In pt, this message translates to:
  /// **'Lido no celular, sem enviar a foto'**
  String get photoTextHint;

  /// No description provided for @englishAudio.
  ///
  /// In pt, this message translates to:
  /// **'Áudio em inglês'**
  String get englishAudio;

  /// No description provided for @statTerms.
  ///
  /// In pt, this message translates to:
  /// **'Termos'**
  String get statTerms;

  /// No description provided for @statLearning.
  ///
  /// In pt, this message translates to:
  /// **'Aprendendo'**
  String get statLearning;

  /// No description provided for @statMastered.
  ///
  /// In pt, this message translates to:
  /// **'Dominados'**
  String get statMastered;

  /// No description provided for @ungrouped.
  ///
  /// In pt, this message translates to:
  /// **'Sem grupo'**
  String get ungrouped;

  /// No description provided for @moveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra mover agora. Confira a internet e tente de novo.'**
  String get moveFailed;

  /// No description provided for @termsMoved.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} termos movidos} =1{1 termo movido} other{{count} termos movidos}}'**
  String termsMoved(int count);

  /// No description provided for @termsMovedTo.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Agora estão em {group}.} =1{Agora está em {group}.} other{Agora estão em {group}.}}'**
  String termsMovedTo(int count, String group);

  /// No description provided for @undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// No description provided for @undoFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra desfazer agora.'**
  String get undoFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra apagar agora. Confira a internet e tente de novo.'**
  String get deleteFailed;

  /// No description provided for @termsDeleted.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} termos apagados} =1{1 termo apagado} other{{count} termos apagados}}'**
  String termsDeleted(int count);

  /// No description provided for @termsDeletedMessage.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Saíram do vocabulário.} =1{Saiu do vocabulário.} other{Saíram do vocabulário.}}'**
  String termsDeletedMessage(int count);

  /// No description provided for @cancelSelection.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar seleção'**
  String get cancelSelection;

  /// No description provided for @moreOptions.
  ///
  /// In pt, this message translates to:
  /// **'Mais opções'**
  String get moreOptions;

  /// No description provided for @select.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar todos'**
  String get selectAll;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get delete;

  /// No description provided for @moveTerms.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Selecione os termos} =1{Mover 1 termo} other{Mover {count} termos}}'**
  String moveTerms(int count);

  /// No description provided for @allOrganized.
  ///
  /// In pt, this message translates to:
  /// **'Tudo organizado'**
  String get allOrganized;

  /// No description provided for @allOrganizedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Os termos que você confirmar nas capturas chegam aqui.'**
  String get allOrganizedMessage;

  /// No description provided for @groupEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum termo aqui ainda'**
  String get groupEmptyTitle;

  /// No description provided for @groupEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Termos novos chegam em Sem grupo. De lá, mova os que forem daqui.'**
  String get groupEmptyMessage;

  /// No description provided for @ungroupedHelp.
  ///
  /// In pt, this message translates to:
  /// **'Os termos que você confirma nas capturas chegam aqui. Mova cada um pro grupo dele.'**
  String get ungroupedHelp;

  /// No description provided for @allCount.
  ///
  /// In pt, this message translates to:
  /// **'Todos · {count}'**
  String allCount(int count);

  /// No description provided for @selectionMeta.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Toque nos termos pra escolher} =1{1 selecionado} other{{count} selecionados}}'**
  String selectionMeta(int count);

  /// No description provided for @nothingToOrganize.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum termo pra organizar'**
  String get nothingToOrganize;

  /// No description provided for @termsToGroup.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} termos pra pôr num grupo} =1{1 termo pra pôr num grupo} other{{count} termos pra pôr num grupo}}'**
  String termsToGroup(int count);

  /// No description provided for @noTermsYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum termo ainda'**
  String get noTermsYet;

  /// No description provided for @termCountMastered.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} termos} =1{1 termo} other{{count} termos}} · {mastered} dominados'**
  String termCountMastered(int count, int mastered);

  /// No description provided for @termCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} termos} =1{1 termo} other{{count} termos}}'**
  String termCount(int count);

  /// No description provided for @groupCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{count} grupos} =1{1 grupo} other{{count} grupos}}'**
  String groupCount(int count);

  /// No description provided for @termsInGroups.
  ///
  /// In pt, this message translates to:
  /// **'{terms} em {groups}'**
  String termsInGroups(String terms, String groups);

  /// No description provided for @editGroup.
  ///
  /// In pt, this message translates to:
  /// **'Editar grupo'**
  String get editGroup;

  /// No description provided for @editGroupHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome, ícone e cor'**
  String get editGroupHint;

  /// No description provided for @selectTerms.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar termos'**
  String get selectTerms;

  /// No description provided for @selectTermsHint.
  ///
  /// In pt, this message translates to:
  /// **'Mova ou apague termos'**
  String get selectTermsHint;

  /// No description provided for @deleteGroup.
  ///
  /// In pt, this message translates to:
  /// **'Apagar grupo'**
  String get deleteGroup;

  /// No description provided for @deleteGroupHint.
  ///
  /// In pt, this message translates to:
  /// **'Os termos voltam pra Sem grupo'**
  String get deleteGroupHint;

  /// No description provided for @deleteGroupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar {name}?'**
  String deleteGroupTitle(String name);

  /// No description provided for @deleteGroupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{O grupo está vazio.} =1{O termo volta pra Sem grupo.} other{Os {count} termos voltam pra Sem grupo.}}'**
  String deleteGroupSubtitle(int count);

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @groupDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Grupo apagado'**
  String get groupDeleted;

  /// No description provided for @groupDeletedMessage.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{{name} saiu da lista.} =1{O termo foi pra Sem grupo.} other{Os {count} termos foram pra Sem grupo.}}'**
  String groupDeletedMessage(int count, String name);

  /// No description provided for @groupCreated.
  ///
  /// In pt, this message translates to:
  /// **'Grupo criado'**
  String get groupCreated;

  /// No description provided for @groupCreatedMessage.
  ///
  /// In pt, this message translates to:
  /// **'{name} está no topo da lista.'**
  String groupCreatedMessage(String name);

  /// No description provided for @open.
  ///
  /// In pt, this message translates to:
  /// **'Abrir'**
  String get open;

  /// No description provided for @newGroup.
  ///
  /// In pt, this message translates to:
  /// **'Novo grupo'**
  String get newGroup;

  /// No description provided for @vocabularyEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Capture e confirme a análise pra começar.'**
  String get vocabularyEmptyMessage;

  /// No description provided for @organize.
  ///
  /// In pt, this message translates to:
  /// **'Organizar'**
  String get organize;

  /// No description provided for @noGroupsYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum grupo ainda'**
  String get noGroupsYet;

  /// No description provided for @noGroupsYetMessage.
  ///
  /// In pt, this message translates to:
  /// **'Crie um grupo pra organizar seus termos.'**
  String get noGroupsYetMessage;

  /// No description provided for @createGroup.
  ///
  /// In pt, this message translates to:
  /// **'Criar grupo'**
  String get createGroup;

  /// No description provided for @yourGroups.
  ///
  /// In pt, this message translates to:
  /// **'Seus grupos'**
  String get yourGroups;

  /// No description provided for @noTermsInGroupYet.
  ///
  /// In pt, this message translates to:
  /// **'Sem termos ainda'**
  String get noTermsInGroupYet;

  /// No description provided for @percentMastered.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% dominado'**
  String percentMastered(int percent);

  /// No description provided for @groupSaveRejected.
  ///
  /// In pt, this message translates to:
  /// **'{action, select, create{Não deu pra criar o grupo.} save{Não deu pra salvar o grupo.} other{}}'**
  String groupSaveRejected(String action);

  /// No description provided for @groupSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'{action, select, create{Não deu pra criar o grupo agora. Tente de novo.} save{Não deu pra salvar o grupo agora. Tente de novo.} other{}}'**
  String groupSaveFailed(String action);

  /// No description provided for @offlineRetry.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Tente de novo.'**
  String get offlineRetry;

  /// No description provided for @groupModalNewHint.
  ///
  /// In pt, this message translates to:
  /// **'Junte termos do mesmo assunto'**
  String get groupModalNewHint;

  /// No description provided for @groupModalEditHint.
  ///
  /// In pt, this message translates to:
  /// **'Mude o nome, o ícone ou a cor'**
  String get groupModalEditHint;

  /// No description provided for @groupNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Música, Faculdade'**
  String get groupNameHint;

  /// No description provided for @groupNameTaken.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem um grupo com esse nome.'**
  String get groupNameTaken;

  /// No description provided for @nameTheGroup.
  ///
  /// In pt, this message translates to:
  /// **'Dê um nome ao grupo'**
  String get nameTheGroup;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @moveModalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mover pra qual grupo?'**
  String get moveModalTitle;

  /// No description provided for @moveModalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{terms} de {from}'**
  String moveModalSubtitle(String terms, String from);

  /// No description provided for @noGroupsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não tem grupos'**
  String get noGroupsTitle;

  /// No description provided for @noGroupsMessage.
  ///
  /// In pt, this message translates to:
  /// **'Crie um grupo pra guardar esses termos.'**
  String get noGroupsMessage;

  /// No description provided for @countryOfOrigin.
  ///
  /// In pt, this message translates to:
  /// **'País de origem'**
  String get countryOfOrigin;

  /// No description provided for @countryNotSet.
  ///
  /// In pt, this message translates to:
  /// **'Escolha pra mostrar a bandeira no seu avatar'**
  String get countryNotSet;

  /// No description provided for @countryModalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Aparece como bandeira no seu avatar'**
  String get countryModalSubtitle;

  /// No description provided for @searchCountry.
  ///
  /// In pt, this message translates to:
  /// **'Buscar país'**
  String get searchCountry;

  /// No description provided for @countryNone.
  ///
  /// In pt, this message translates to:
  /// **'Prefiro não dizer'**
  String get countryNone;

  /// No description provided for @countrySaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra salvar o país. Confira a internet e tente de novo.'**
  String get countrySaveFailed;

  /// No description provided for @noCountryFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum país com esse nome'**
  String get noCountryFound;

  /// No description provided for @countryFlag.
  ///
  /// In pt, this message translates to:
  /// **'Bandeira: {country}'**
  String countryFlag(String country);

  /// No description provided for @termKind.
  ///
  /// In pt, this message translates to:
  /// **'{kind, select, word{Palavra} expression{Expressão} other{}}'**
  String termKind(String kind);

  /// No description provided for @groupIcon.
  ///
  /// In pt, this message translates to:
  /// **'{icon, select, layers{Geral} talk{Conversa} work{Trabalho} travel{Viagem} food{Comida} tv{Séries} music{Música} study{Estudos} heart{Favoritos} game{Jogos} shopping{Compras} sport{Esporte} health{Saúde} home{Casa} nature{Natureza} paw{Animais} tech{Tecnologia} money{Dinheiro} car{Transporte} family{Família} book{Livros} art{Arte} party{Festa} weather{Clima} phone{Celular} mail{E-mail} code{Programação} science{Ciência} news{Notícias} movie{Cinema} camera{Fotografia} place{Lugares} city{Cidade} globe{Mundo} calendar{Datas} clock{Rotina} star{Importante} idea{Ideias} smile{Sentimentos} shirt{Roupas} restaurant{Restaurante} drink{Bebidas} mountain{Aventura} gift{Presentes} flag{Países} podcast{Podcasts} goal{Metas} writing{Escrita} other{}}'**
  String groupIcon(String icon);

  /// No description provided for @courseLanguage.
  ///
  /// In pt, this message translates to:
  /// **'{language, select, en{Inglês} es{Espanhol} pt{Português} other{}}'**
  String courseLanguage(String language);

  /// No description provided for @coursePair.
  ///
  /// In pt, this message translates to:
  /// **'{base, select, en{Inglês} es{Espanhol} pt{Português} other{}} → {learning, select, en{Inglês} es{Espanhol} pt{Português} other{}}'**
  String coursePair(String base, String learning);

  /// No description provided for @courseOptionNoAudio.
  ///
  /// In pt, this message translates to:
  /// **'{name} · sem áudio por enquanto'**
  String courseOptionNoAudio(String name);

  /// No description provided for @courseOptionAudio.
  ///
  /// In pt, this message translates to:
  /// **'{name} · com áudio'**
  String courseOptionAudio(String name);

  /// No description provided for @coursePickTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus idiomas'**
  String get coursePickTitle;

  /// No description provided for @coursePickSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você conversa em um e aprende o outro.'**
  String get coursePickSubtitle;

  /// No description provided for @courseLearnSection.
  ///
  /// In pt, this message translates to:
  /// **'Quero aprender'**
  String get courseLearnSection;

  /// No description provided for @courseBaseSection.
  ///
  /// In pt, this message translates to:
  /// **'Eu falo'**
  String get courseBaseSection;

  /// No description provided for @courseBaseHint.
  ///
  /// In pt, this message translates to:
  /// **'O app inteiro fica nesse idioma'**
  String get courseBaseHint;

  /// No description provided for @courseBaseChange.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get courseBaseChange;

  /// No description provided for @courseBaseModalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O app, as traduções e as explicações das fichas ficam nesse idioma'**
  String get courseBaseModalSubtitle;

  /// No description provided for @courseBaseMore.
  ///
  /// In pt, this message translates to:
  /// **'Mais idiomas aparecem aqui conforme o app for traduzido.'**
  String get courseBaseMore;

  /// No description provided for @coursePickLearning.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o que quer aprender'**
  String get coursePickLearning;

  /// No description provided for @courseStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar a aprender {language, select, en{inglês} es{espanhol} pt{português} other{}}'**
  String courseStart(String language);

  /// No description provided for @courseStartFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra começar agora. Confira sua conexão.'**
  String get courseStartFailed;

  /// No description provided for @courseSwitchFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não deu pra trocar de curso. Confira sua conexão.'**
  String get courseSwitchFailed;

  /// No description provided for @coursesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus cursos'**
  String get coursesTitle;

  /// No description provided for @coursesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O app fica no idioma que você fala no curso ativo.'**
  String get coursesSubtitle;

  /// No description provided for @courseAppIn.
  ///
  /// In pt, this message translates to:
  /// **'app em {name}'**
  String courseAppIn(String name);

  /// No description provided for @courseAdd.
  ///
  /// In pt, this message translates to:
  /// **'Aprender outro idioma'**
  String get courseAdd;

  /// No description provided for @courseBadge.
  ///
  /// In pt, this message translates to:
  /// **'Curso: {name}. Trocar'**
  String courseBadge(String name);

  /// No description provided for @profileStudy.
  ///
  /// In pt, this message translates to:
  /// **'Estudo'**
  String get profileStudy;

  /// No description provided for @courseCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{nenhum curso} =1{1 curso} other{{count} cursos}} · trocar ou adicionar'**
  String courseCount(int count);

  /// No description provided for @progressIn.
  ///
  /// In pt, this message translates to:
  /// **'Progresso em {language, select, en{inglês} es{espanhol} pt{português} other{}}'**
  String progressIn(String language);

  /// No description provided for @termCardLoading.
  ///
  /// In pt, this message translates to:
  /// **'Montando a ficha…'**
  String get termCardLoading;

  /// No description provided for @termBuildingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Montando a ficha'**
  String get termBuildingTitle;

  /// No description provided for @termBuildingVerb.
  ///
  /// In pt, this message translates to:
  /// **'{step, select, meaning{procurando} trick{bolando} pitfall{caçando} dialogue{ensaiando} phrase{montando} neighbors{chamando} other{}}'**
  String termBuildingVerb(String step);

  /// No description provided for @termBuildingObject.
  ///
  /// In pt, this message translates to:
  /// **'{step, select, meaning{o sentido} trick{um macete} pitfall{a pegadinha} dialogue{uma conversa} phrase{a frase} neighbors{os vizinhos} other{}}'**
  String termBuildingObject(String step);

  /// No description provided for @termBuildingNote.
  ///
  /// In pt, this message translates to:
  /// **'Só demora na primeira vez. Depois, a ficha fica salva.'**
  String get termBuildingNote;

  /// No description provided for @meaning.
  ///
  /// In pt, this message translates to:
  /// **'Significado'**
  String get meaning;

  /// No description provided for @coverAgain.
  ///
  /// In pt, this message translates to:
  /// **'Embaçar de novo'**
  String get coverAgain;

  /// No description provided for @reveal.
  ///
  /// In pt, this message translates to:
  /// **'Revelar'**
  String get reveal;

  /// No description provided for @cardSide.
  ///
  /// In pt, this message translates to:
  /// **'Em {language, select, en{inglês} es{espanhol} pt{português} other{}}'**
  String cardSide(String language);

  /// No description provided for @seeIn.
  ///
  /// In pt, this message translates to:
  /// **'Ver em {language, select, en{inglês} es{espanhol} pt{português} other{}}'**
  String seeIn(String language);

  /// No description provided for @inYourContext.
  ///
  /// In pt, this message translates to:
  /// **'No seu contexto'**
  String get inYourContext;

  /// No description provided for @explanation.
  ///
  /// In pt, this message translates to:
  /// **'Explicação'**
  String get explanation;

  /// No description provided for @termTab.
  ///
  /// In pt, this message translates to:
  /// **'{tab, select, context{Contexto} words{Palavras} usage{Uso} other{}}'**
  String termTab(String tab);

  /// No description provided for @whereYouSaw.
  ///
  /// In pt, this message translates to:
  /// **'Onde você viu'**
  String get whereYouSaw;

  /// No description provided for @alsoMarked.
  ///
  /// In pt, this message translates to:
  /// **'Também marcado'**
  String get alsoMarked;

  /// No description provided for @examples.
  ///
  /// In pt, this message translates to:
  /// **'Exemplos'**
  String get examples;

  /// No description provided for @collocations.
  ///
  /// In pt, this message translates to:
  /// **'Monta a frase'**
  String get collocations;

  /// No description provided for @synonyms.
  ///
  /// In pt, this message translates to:
  /// **'Quase o mesmo'**
  String get synonyms;

  /// No description provided for @antonyms.
  ///
  /// In pt, this message translates to:
  /// **'O contrário'**
  String get antonyms;

  /// No description provided for @formality.
  ///
  /// In pt, this message translates to:
  /// **'Do chinelo à gravata'**
  String get formality;

  /// No description provided for @formalityLevel.
  ///
  /// In pt, this message translates to:
  /// **'{level, select, slang{Gíria} informal{Informal} neutral{Neutro} formal{Formal} other{}}'**
  String formalityLevel(String level);

  /// No description provided for @formalityMeter.
  ///
  /// In pt, this message translates to:
  /// **'Formalidade: {level}, {step} de 4'**
  String formalityMeter(String level, int step);

  /// No description provided for @whereItFits.
  ///
  /// In pt, this message translates to:
  /// **'Onde cabe'**
  String get whereItFits;

  /// No description provided for @preferInstead.
  ///
  /// In pt, this message translates to:
  /// **'Prefira {word}'**
  String preferInstead(String word);

  /// No description provided for @listenSlow.
  ///
  /// In pt, this message translates to:
  /// **'Devagar'**
  String get listenSlow;

  /// No description provided for @literally.
  ///
  /// In pt, this message translates to:
  /// **'Ao pé da letra'**
  String get literally;

  /// No description provided for @itMeans.
  ///
  /// In pt, this message translates to:
  /// **'Quer dizer'**
  String get itMeans;

  /// No description provided for @imagine.
  ///
  /// In pt, this message translates to:
  /// **'Imagine:'**
  String get imagine;

  /// No description provided for @remember.
  ///
  /// In pt, this message translates to:
  /// **'Pra lembrar'**
  String get remember;

  /// No description provided for @pitfallTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pegadinha'**
  String get pitfallTitle;

  /// No description provided for @sayNot.
  ///
  /// In pt, this message translates to:
  /// **'Não diga'**
  String get sayNot;

  /// No description provided for @say.
  ///
  /// In pt, this message translates to:
  /// **'Diga'**
  String get say;

  /// No description provided for @gotItQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Tinha sacado pelo contexto?'**
  String get gotItQuestion;

  /// No description provided for @gotItYes.
  ///
  /// In pt, this message translates to:
  /// **'Saquei'**
  String get gotItYes;

  /// No description provided for @gotItNo.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get gotItNo;

  /// No description provided for @gotItYesReply.
  ///
  /// In pt, this message translates to:
  /// **'Boa! O contexto te entregou.'**
  String get gotItYesReply;

  /// No description provided for @gotItNoReply.
  ///
  /// In pt, this message translates to:
  /// **'Tranquilo. Agora você sabe.'**
  String get gotItNoReply;

  /// No description provided for @seenVia.
  ///
  /// In pt, this message translates to:
  /// **'{source, select, photo{Você leu numa foto} audio{Você ouviu} text{Você anotou} other{}}'**
  String seenVia(String source);

  /// No description provided for @dialogue.
  ///
  /// In pt, this message translates to:
  /// **'Numa conversa'**
  String get dialogue;

  /// No description provided for @listen.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir'**
  String get listen;

  /// No description provided for @dialogueHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque num balão pra ver a tradução.'**
  String get dialogueHint;

  /// No description provided for @collocationsHint.
  ///
  /// In pt, this message translates to:
  /// **'Peças que andam junto com o termo.'**
  String get collocationsHint;

  /// No description provided for @listenTo.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir {text}'**
  String listenTo(String text);

  /// No description provided for @neighbors.
  ///
  /// In pt, this message translates to:
  /// **'Vizinhos'**
  String get neighbors;

  /// No description provided for @fitsYes.
  ///
  /// In pt, this message translates to:
  /// **'Cabe'**
  String get fitsYes;

  /// No description provided for @fitsNo.
  ///
  /// In pt, this message translates to:
  /// **'Não cabe'**
  String get fitsNo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
