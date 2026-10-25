// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get sessionExpired => 'Sua sessão expirou. Entre de novo.';

  @override
  String get tabHome => 'Início';

  @override
  String get tabVocabulary => 'Vocabulário';

  @override
  String get tabInbox => 'Inbox';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get captureMenuTitle => 'O que você ouviu hoje?';

  @override
  String get captureMenuSubtitle =>
      'Fotografe, grave ou digite. A análise vai pro Inbox.';

  @override
  String get captureCamera => 'Câmera';

  @override
  String get captureAudio => 'Áudio';

  @override
  String get captureText => 'Texto';

  @override
  String get color => 'Cor';

  @override
  String accentName(String accent) {
    String _temp0 = intl.Intl.selectLogic(accent, {
      'violet': 'Violeta',
      'coral': 'Coral',
      'mint': 'Menta',
      'mango': 'Manga',
      'sky': 'Céu',
      'pink': 'Rosa',
      'grape': 'Uva',
      'cocoa': 'Cacau',
      'lime': 'Lima',
      'gold': 'Ouro',
      'teal': 'Turquesa',
      'slate': 'Ardósia',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get loading => 'Carregando';

  @override
  String codeFieldLabel(int length) {
    return 'Código de $length dígitos';
  }

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get closeMenu => 'Fechar menu';

  @override
  String get addTerm => 'Adicionar termo';

  @override
  String get loadFailedTitle => 'Não deu pra carregar';

  @override
  String get loadFailedMessage => 'Confira sua conexão e tente de novo.';

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get icon => 'Ícone';

  @override
  String get back => 'Voltar';

  @override
  String get next => 'Avançar';

  @override
  String iconPage(String page) {
    return 'Página $page dos ícones';
  }

  @override
  String levelOf(int level, int max) {
    return 'Nível $level de $max';
  }

  @override
  String removeItem(String label) {
    return 'Remover $label';
  }

  @override
  String get close => 'Fechar';

  @override
  String get authOffline => 'Sem conexão com o servidor. Tente de novo.';

  @override
  String authFailure(String failure) {
    String _temp0 = intl.Intl.selectLogic(failure, {
      'unavailable': 'Esse login não está disponível agora.',
      'tooManyAttempts': 'Muitas tentativas. Espere um pouco e tente de novo.',
      'expired': 'Essa etapa expirou. Comece de novo.',
      'unknown': 'Não deu certo. Tente de novo.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get googleFailed => 'Não deu pra entrar com o Google. Tente de novo.';

  @override
  String get appleFailed => 'Não deu pra entrar com a Apple. Tente de novo.';

  @override
  String get signIn => 'Entrar';

  @override
  String get loginWelcome => 'Que bom te ver de novo.';

  @override
  String get email => 'E-mail';

  @override
  String get emailHint => 'voce@email.com';

  @override
  String get password => 'Senha';

  @override
  String get passwordHint => 'Sua senha';

  @override
  String get forgotPassword => 'Esqueci minha senha';

  @override
  String get newHere => 'Novo por aqui?';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get tagline => 'Inglês de verdade, tirado das conversas do seu dia.';

  @override
  String get forgotTitle => 'Esqueceu a senha?';

  @override
  String get forgotSubtitle => 'Acontece. A gente te ajuda.';

  @override
  String get forgotBody =>
      'Digite o e-mail da sua conta. Enviamos um código pra você criar uma senha nova.';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get rememberedPassword => 'Lembrou a senha?';

  @override
  String get newPasswordTitle => 'Nova senha';

  @override
  String get newPasswordSubtitle => 'Última etapa.';

  @override
  String get newPasswordBody =>
      'Crie uma senha nova pra sua conta. Depois de salvar, você já entra no app.';

  @override
  String get newPasswordHint => 'Sua senha nova';

  @override
  String get newPasswordHelper => 'Mínimo de 8 caracteres. Evite só números.';

  @override
  String get saveAndSignIn => 'Salvar e entrar';

  @override
  String get resetCodeTitle => 'Digite o código';

  @override
  String get resetCodeSubtitle => 'Pra criar sua senha nova.';

  @override
  String get signupSubtitle => 'Seu vocabulário salvo em qualquer celular.';

  @override
  String get name => 'Nome';

  @override
  String get nameHint => 'Como quer ser chamado';

  @override
  String get passwordCreateHint => 'Crie uma senha';

  @override
  String get passwordHelper => 'Mínimo de 8 caracteres.';

  @override
  String get haveAccount => 'Já tem conta?';

  @override
  String get verifyEmailTitle => 'Confirme seu e-mail';

  @override
  String get verifyEmailSubtitle => 'Falta pouco pra começar.';

  @override
  String codeSent(int length) {
    return 'Enviamos um código de $length dígitos para';
  }

  @override
  String get confirm => 'Confirmar';

  @override
  String resendIn(String time) {
    return 'Não chegou? Reenviar em $time';
  }

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get checkSpam => 'Confira também a caixa de spam.';

  @override
  String get changeEmail => 'Trocar e-mail';

  @override
  String get or => 'ou';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithApple => 'Continuar com a Apple';

  @override
  String get recording => 'Gravando…';

  @override
  String get recordAudio => 'Gravar áudio';

  @override
  String get listenBeforeSaving => 'Ouça antes de salvar';

  @override
  String get recordHint => 'Grave a frase do jeito que ouviu';

  @override
  String get micDeniedTitle => 'Sem acesso ao microfone';

  @override
  String get micDeniedMessage =>
      'Libere o microfone nas configurações do celular pra gravar.';

  @override
  String ofDuration(String max) {
    return 'de $max';
  }

  @override
  String get recordingTime => 'Tempo de gravação';

  @override
  String get stopRecording => 'Parar gravação';

  @override
  String get tapToStop => 'Toque para parar';

  @override
  String get audioPrivacy =>
      'O áudio fica só no seu celular. A gente guarda apenas a transcrição.';

  @override
  String get saveToInbox => 'Salvar no Inbox';

  @override
  String get reRecord => 'Regravar';

  @override
  String get savedProcessing => 'Já está processando.';

  @override
  String get savedOffline => 'Puxe a lista no Inbox quando tiver internet.';

  @override
  String get savedReady => 'Pronto pra escolher os termos.';

  @override
  String get savedToInbox => 'Salvo no Inbox';

  @override
  String get see => 'Ver';

  @override
  String get photo => 'Foto';

  @override
  String get photoHint => 'Uma placa, um cardápio, uma legenda';

  @override
  String get checkBeforeSaving => 'Confira antes de salvar';

  @override
  String get cameraDeniedTitle => 'Sem acesso à câmera';

  @override
  String get cameraDeniedMessage =>
      'Libere a câmera nas configurações do celular pra tirar foto.';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get takePhotoHint => 'Abre a câmera do celular';

  @override
  String get pickFromGallery => 'Escolher da galeria';

  @override
  String get pickFromGalleryHint => 'Usa uma foto que você já tem';

  @override
  String get photoPrivacy =>
      'A foto fica só no seu celular. A gente guarda apenas o texto lido dela.';

  @override
  String get chosenPhoto => 'Foto escolhida';

  @override
  String get changePhoto => 'Trocar foto';

  @override
  String get typeText => 'Digitar texto';

  @override
  String get typeTextHint => 'O que você ouviu ou leu hoje';

  @override
  String get textCaptureLabel => 'Palavra, expressão ou frase';

  @override
  String get textCaptureHelper =>
      'Frase ou trecho. Os termos você escolhe no Inbox.';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get homeEmptyTitle => 'Seu inglês começa aqui';

  @override
  String get homeEmptyMessage =>
      'Capture o que você ouviu ou leu hoje, por foto, áudio ou texto. Os termos que você confirmar aparecem aqui.';

  @override
  String get homeFirstCapture => 'Fazer a primeira captura';

  @override
  String greeting(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'morning': 'Bom dia!',
      'afternoon': 'Boa tarde!',
      'evening': 'Boa noite!',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String greetingName(String period, String name) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'morning': 'Bom dia, $name',
      'afternoon': 'Boa tarde, $name',
      'evening': 'Boa noite, $name',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get homeTagline => 'Vamos tagarelar?';

  @override
  String get reviewToday => 'Revisão de hoje';

  @override
  String termsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos esperando',
      one: '1 termo esperando',
      zero: '$count termos esperando',
    );
    return '$_temp0';
  }

  @override
  String get start => 'Começar';

  @override
  String get yourVocabulary => 'Seu vocabulário';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get totalTerms => 'Total de termos';

  @override
  String thisWeek(int count) {
    return '+$count esta semana';
  }

  @override
  String learningMastered(int learning, int mastered) {
    return '$learning aprendendo, $mastered dominados';
  }

  @override
  String termStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'learning': 'Aprendendo',
      'mastered': 'Dominado',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordOfDay => 'Palavra do dia';

  @override
  String get listenPronunciation => 'Ouvir pronúncia';

  @override
  String get addToVocabulary => 'Adicionar ao vocabulário';

  @override
  String inboxTab(String tab) {
    String _temp0 = intl.Intl.selectLogic(tab, {
      'all': 'Todas',
      'ready': 'Prontas',
      'pending': 'Pendentes',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String captureSection(String section) {
    String _temp0 = intl.Intl.selectLogic(section, {
      'attention': 'Precisa de atenção',
      'ready': 'Prontas',
      'processing': 'Processando',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noConnectionRetry =>
      'Sem conexão. Tente de novo quando tiver internet.';

  @override
  String get inboxEmptyTitle => 'Inbox zerado';

  @override
  String get inboxEmptyMessage => 'Use o + para capturar um termo novo.';

  @override
  String get nothingHere => 'Nada por aqui';

  @override
  String get noCapturesInTab => 'Nenhuma captura nessa aba.';

  @override
  String captureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capturas',
      one: '1 captura',
      zero: '$count capturas',
    );
    return '$_temp0';
  }

  @override
  String waitingUpload(int count) {
    return '$count esperando envio';
  }

  @override
  String get discardCapture => 'Descartar captura';

  @override
  String get pickTerms => 'Escolher termos';

  @override
  String captureSource(String source) {
    String _temp0 = intl.Intl.selectLogic(source, {
      'photo': 'Foto',
      'audio': 'Áudio',
      'text': 'Texto',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get confirmHint => 'Ao confirmar, a IA monta a ficha de cada termo.';

  @override
  String get pickAtLeastOne => 'Escolha pelo menos um termo';

  @override
  String confirmAnalysisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos',
      one: '1 termo',
      zero: '$count termos',
    );
    return 'Confirmar análise · $_temp0';
  }

  @override
  String get pickHelp =>
      'Arraste o dedo sobre as palavras pra marcar uma expressão. Toque numa palavra pra marcar só ela.';

  @override
  String get textSection => 'Texto';

  @override
  String get done => 'Pronto';

  @override
  String get editText => 'Editar texto';

  @override
  String get editTextHelper =>
      'Corrija o que saiu errado. Os termos marcados continuam quando a palavra não mudar.';

  @override
  String chosenTermsCount(int count) {
    return 'Termos escolhidos · $count';
  }

  @override
  String get noTermsYetTap => 'Nenhum ainda. Toque numa palavra do texto.';

  @override
  String termTooLong(int max) {
    return 'Expressão grande demais. Marque até $max caracteres.';
  }

  @override
  String tooManyTerms(int max) {
    return 'Limite de $max termos por captura.';
  }

  @override
  String get stop => 'Parar';

  @override
  String get listenRecording => 'Ouvir gravação';

  @override
  String get discard => 'Descartar';

  @override
  String get processNow => 'Processar agora';

  @override
  String get edit => 'Editar';

  @override
  String get confirmAnalysis => 'Confirmar análise';

  @override
  String get readingPhoto => 'Lendo o texto da foto…';

  @override
  String get noTextInPhoto => 'Não achei texto na foto';

  @override
  String get noSpeech => 'Não ouvi fala em inglês';

  @override
  String get noTextInPhotoHint => 'Tente outra foto ou descarte esta.';

  @override
  String get noSpeechHint => 'Grave de novo ou descarte este áudio.';

  @override
  String get processFailedTitle => 'Não deu pra processar agora';

  @override
  String get processFailedHint =>
      'Toque em Processar agora pra tentar de novo.';

  @override
  String get timeNow => 'agora';

  @override
  String minutesAgo(int minutes) {
    return 'há $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'há $hours h';
  }

  @override
  String get yesterday => 'ontem';

  @override
  String captureStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'failed': 'Erro',
      'ready': 'Pronta',
      'processing': 'Processando',
      'analyzed': 'Analisada',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get capturePhoto => 'Foto da captura';

  @override
  String captureContent(String source) {
    String _temp0 = intl.Intl.selectLogic(source, {
      'text': 'Seu texto',
      'photo': 'Texto da foto',
      'audio': 'Transcrição',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get missingPhoto =>
      'A foto não está mais neste celular. O texto continua salvo.';

  @override
  String get missingAudio =>
      'O áudio não está mais neste celular. A transcrição continua salva.';

  @override
  String termsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos escolhidos',
      one: '1 termo escolhido',
      zero: '$count termos escolhidos',
    );
    return '$_temp0';
  }

  @override
  String get waitingModel => 'Esperando o modelo de áudio baixar…';

  @override
  String get transcribing => 'Transcrevendo o áudio…';

  @override
  String get account => 'Conta';

  @override
  String get privacy => 'Privacidade';

  @override
  String get privacyText =>
      'Foto e áudio ficam só neste celular. A API guarda só o texto.';

  @override
  String get signOut => 'Sair';

  @override
  String get preferences => 'Preferências';

  @override
  String get language => 'Idioma';

  @override
  String get languageAuto => 'Automático';

  @override
  String get languageAutoHint => 'Segue o idioma do celular';

  @override
  String languageAutoValue(String language) {
    return 'Automático · $language';
  }

  @override
  String get languageSheetSubtitle => 'Muda os textos do app';

  @override
  String modelReady(String size) {
    return 'Transcrito no celular · modelo de $size';
  }

  @override
  String get ready => 'Pronto';

  @override
  String modelDownloading(int percent, String size) {
    return 'Baixando o modelo: $percent% de $size';
  }

  @override
  String get downloading => 'Baixando';

  @override
  String modelWaiting(String size) {
    return 'O modelo de $size baixa sozinho quando tiver internet';
  }

  @override
  String get waiting => 'Esperando';

  @override
  String get worksOffline => 'Funciona sem internet';

  @override
  String get photoText => 'Texto de fotos';

  @override
  String get photoTextHint => 'Lido no celular, sem enviar a foto';

  @override
  String get englishAudio => 'Áudio em inglês';

  @override
  String get statTerms => 'Termos';

  @override
  String get statLearning => 'Aprendendo';

  @override
  String get statMastered => 'Dominados';

  @override
  String get ungrouped => 'Sem grupo';

  @override
  String get moveFailed =>
      'Não deu pra mover agora. Confira a internet e tente de novo.';

  @override
  String termsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos movidos',
      one: '1 termo movido',
      zero: '$count termos movidos',
    );
    return '$_temp0';
  }

  @override
  String termsMovedTo(int count, String group) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Agora estão em $group.',
      one: 'Agora está em $group.',
      zero: 'Agora estão em $group.',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Desfazer';

  @override
  String get undoFailed => 'Não deu pra desfazer agora.';

  @override
  String get deleteFailed =>
      'Não deu pra apagar agora. Confira a internet e tente de novo.';

  @override
  String termsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos apagados',
      one: '1 termo apagado',
      zero: '$count termos apagados',
    );
    return '$_temp0';
  }

  @override
  String termsDeletedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saíram do vocabulário.',
      one: 'Saiu do vocabulário.',
      zero: 'Saíram do vocabulário.',
    );
    return '$_temp0';
  }

  @override
  String get cancelSelection => 'Cancelar seleção';

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get select => 'Selecionar';

  @override
  String get selectAll => 'Selecionar todos';

  @override
  String get delete => 'Apagar';

  @override
  String moveTerms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mover $count termos',
      one: 'Mover 1 termo',
      zero: 'Selecione os termos',
    );
    return '$_temp0';
  }

  @override
  String get allOrganized => 'Tudo organizado';

  @override
  String get allOrganizedMessage =>
      'Os termos que você confirmar nas capturas chegam aqui.';

  @override
  String get groupEmptyTitle => 'Nenhum termo aqui ainda';

  @override
  String get groupEmptyMessage =>
      'Termos novos chegam em Sem grupo. De lá, mova os que forem daqui.';

  @override
  String get ungroupedHelp =>
      'Os termos que você confirma nas capturas chegam aqui. Mova cada um pro grupo dele.';

  @override
  String allCount(int count) {
    return 'Todos · $count';
  }

  @override
  String selectionMeta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
      zero: 'Toque nos termos pra escolher',
    );
    return '$_temp0';
  }

  @override
  String get nothingToOrganize => 'Nenhum termo pra organizar';

  @override
  String termsToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos pra pôr num grupo',
      one: '1 termo pra pôr num grupo',
      zero: '$count termos pra pôr num grupo',
    );
    return '$_temp0';
  }

  @override
  String get noTermsYet => 'Nenhum termo ainda';

  @override
  String termCountMastered(int count, int mastered) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos',
      one: '1 termo',
      zero: '$count termos',
    );
    return '$_temp0 · $mastered dominados';
  }

  @override
  String termCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termos',
      one: '1 termo',
      zero: '$count termos',
    );
    return '$_temp0';
  }

  @override
  String groupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
      zero: '$count grupos',
    );
    return '$_temp0';
  }

  @override
  String termsInGroups(String terms, String groups) {
    return '$terms em $groups';
  }

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get editGroupHint => 'Nome, ícone e cor';

  @override
  String get selectTerms => 'Selecionar termos';

  @override
  String get selectTermsHint => 'Mova ou apague termos';

  @override
  String get deleteGroup => 'Apagar grupo';

  @override
  String get deleteGroupHint => 'Os termos voltam pra Sem grupo';

  @override
  String deleteGroupTitle(String name) {
    return 'Apagar $name?';
  }

  @override
  String deleteGroupSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Os $count termos voltam pra Sem grupo.',
      one: 'O termo volta pra Sem grupo.',
      zero: 'O grupo está vazio.',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get groupDeleted => 'Grupo apagado';

  @override
  String groupDeletedMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Os $count termos foram pra Sem grupo.',
      one: 'O termo foi pra Sem grupo.',
      zero: '$name saiu da lista.',
    );
    return '$_temp0';
  }

  @override
  String get groupCreated => 'Grupo criado';

  @override
  String groupCreatedMessage(String name) {
    return '$name está no topo da lista.';
  }

  @override
  String get open => 'Abrir';

  @override
  String get newGroup => 'Novo grupo';

  @override
  String get vocabularyEmptyMessage =>
      'Capture e confirme a análise pra começar.';

  @override
  String get organize => 'Organizar';

  @override
  String get noGroupsYet => 'Nenhum grupo ainda';

  @override
  String get noGroupsYetMessage => 'Crie um grupo pra organizar seus termos.';

  @override
  String get createGroup => 'Criar grupo';

  @override
  String get yourGroups => 'Seus grupos';

  @override
  String get noTermsInGroupYet => 'Sem termos ainda';

  @override
  String percentMastered(int percent) {
    return '$percent% dominado';
  }

  @override
  String groupSaveRejected(String action) {
    String _temp0 = intl.Intl.selectLogic(action, {
      'create': 'Não deu pra criar o grupo.',
      'save': 'Não deu pra salvar o grupo.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String groupSaveFailed(String action) {
    String _temp0 = intl.Intl.selectLogic(action, {
      'create': 'Não deu pra criar o grupo agora. Tente de novo.',
      'save': 'Não deu pra salvar o grupo agora. Tente de novo.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get offlineRetry => 'Sem conexão. Tente de novo.';

  @override
  String get groupSheetNewHint => 'Junte termos do mesmo assunto';

  @override
  String get groupSheetEditHint => 'Mude o nome, o ícone ou a cor';

  @override
  String get groupNameHint => 'Ex.: Música, Faculdade';

  @override
  String get groupNameTaken => 'Você já tem um grupo com esse nome.';

  @override
  String get nameTheGroup => 'Dê um nome ao grupo';

  @override
  String get save => 'Salvar';

  @override
  String get moveSheetTitle => 'Mover pra qual grupo?';

  @override
  String moveSheetSubtitle(String terms, String from) {
    return '$terms de $from';
  }

  @override
  String get noGroupsTitle => 'Você ainda não tem grupos';

  @override
  String get noGroupsMessage => 'Crie um grupo pra guardar esses termos.';

  @override
  String termKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'word': 'Palavra',
      'expression': 'Expressão',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String groupIcon(String icon) {
    String _temp0 = intl.Intl.selectLogic(icon, {
      'layers': 'Geral',
      'talk': 'Conversa',
      'work': 'Trabalho',
      'travel': 'Viagem',
      'food': 'Comida',
      'tv': 'Séries',
      'music': 'Música',
      'study': 'Estudos',
      'heart': 'Favoritos',
      'game': 'Jogos',
      'shopping': 'Compras',
      'sport': 'Esporte',
      'health': 'Saúde',
      'home': 'Casa',
      'nature': 'Natureza',
      'paw': 'Animais',
      'tech': 'Tecnologia',
      'money': 'Dinheiro',
      'car': 'Transporte',
      'family': 'Família',
      'book': 'Livros',
      'art': 'Arte',
      'party': 'Festa',
      'weather': 'Clima',
      'phone': 'Celular',
      'mail': 'E-mail',
      'code': 'Programação',
      'science': 'Ciência',
      'news': 'Notícias',
      'movie': 'Cinema',
      'camera': 'Fotografia',
      'place': 'Lugares',
      'city': 'Cidade',
      'globe': 'Mundo',
      'calendar': 'Datas',
      'clock': 'Rotina',
      'star': 'Importante',
      'idea': 'Ideias',
      'smile': 'Sentimentos',
      'shirt': 'Roupas',
      'restaurant': 'Restaurante',
      'drink': 'Bebidas',
      'mountain': 'Aventura',
      'gift': 'Presentes',
      'flag': 'Países',
      'podcast': 'Podcasts',
      'goal': 'Metas',
      'writing': 'Escrita',
      'other': '',
    });
    return '$_temp0';
  }
}
