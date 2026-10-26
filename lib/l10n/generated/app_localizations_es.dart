// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get sessionExpired => 'Tu sesión expiró. Vuelve a entrar.';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabVocabulary => 'Vocabulario';

  @override
  String get tabInbox => 'Inbox';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get captureMenuTitle => '¿Qué escuchaste hoy?';

  @override
  String get captureMenuSubtitle =>
      'Toma una foto, graba o escribe. El análisis va al Inbox.';

  @override
  String get captureCamera => 'Cámara';

  @override
  String get captureAudio => 'Audio';

  @override
  String get captureText => 'Texto';

  @override
  String get color => 'Color';

  @override
  String accentName(String accent) {
    String _temp0 = intl.Intl.selectLogic(accent, {
      'violet': 'Violeta',
      'coral': 'Coral',
      'mint': 'Menta',
      'mango': 'Mango',
      'sky': 'Cielo',
      'pink': 'Rosa',
      'grape': 'Uva',
      'cocoa': 'Cacao',
      'lime': 'Lima',
      'gold': 'Oro',
      'teal': 'Turquesa',
      'slate': 'Pizarra',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get loading => 'Cargando';

  @override
  String codeFieldLabel(int length) {
    return 'Código de $length dígitos';
  }

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get closeMenu => 'Cerrar menú';

  @override
  String get addTerm => 'Agregar término';

  @override
  String get loadFailedTitle => 'No se pudo cargar';

  @override
  String get loadFailedMessage => 'Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get icon => 'Ícono';

  @override
  String get back => 'Volver';

  @override
  String get next => 'Siguiente';

  @override
  String iconPage(String page) {
    return 'Página $page de íconos';
  }

  @override
  String levelOf(int level, int max) {
    return 'Nivel $level de $max';
  }

  @override
  String removeItem(String label) {
    return 'Quitar $label';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get authOffline => 'Sin conexión con el servidor. Inténtalo de nuevo.';

  @override
  String authFailure(String failure) {
    String _temp0 = intl.Intl.selectLogic(failure, {
      'unavailable': 'Este inicio de sesión no está disponible ahora.',
      'tooManyAttempts':
          'Demasiados intentos. Espera un poco e inténtalo de nuevo.',
      'expired': 'Este paso expiró. Empieza de nuevo.',
      'unknown': 'Algo salió mal. Inténtalo de nuevo.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get googleFailed =>
      'No se pudo entrar con Google. Inténtalo de nuevo.';

  @override
  String get appleFailed => 'No se pudo entrar con Apple. Inténtalo de nuevo.';

  @override
  String get signIn => 'Entrar';

  @override
  String get loginWelcome => 'Qué bueno verte de nuevo.';

  @override
  String get email => 'Correo';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordHint => 'Tu contraseña';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get newHere => '¿Eres nuevo aquí?';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get tagline =>
      'Inglés de verdad, sacado de las conversaciones de tu día.';

  @override
  String get forgotTitle => '¿Olvidaste tu contraseña?';

  @override
  String get forgotSubtitle => 'Pasa. Te ayudamos.';

  @override
  String get forgotBody =>
      'Escribe el correo de tu cuenta. Te enviamos un código para crear una contraseña nueva.';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get rememberedPassword => '¿Recordaste tu contraseña?';

  @override
  String get newPasswordTitle => 'Nueva contraseña';

  @override
  String get newPasswordSubtitle => 'Último paso.';

  @override
  String get newPasswordBody =>
      'Crea una contraseña nueva para tu cuenta. Al guardarla, ya entras a la app.';

  @override
  String get newPasswordHint => 'Tu nueva contraseña';

  @override
  String get newPasswordHelper =>
      'Mínimo 8 caracteres. Evita usar solo números.';

  @override
  String get saveAndSignIn => 'Guardar y entrar';

  @override
  String get resetCodeTitle => 'Escribe el código';

  @override
  String get resetCodeSubtitle => 'Para crear tu nueva contraseña.';

  @override
  String get signupSubtitle => 'Tu vocabulario guardado en cualquier celular.';

  @override
  String get name => 'Nombre';

  @override
  String get nameHint => 'Cómo quieres que te llamemos';

  @override
  String get passwordCreateHint => 'Crea una contraseña';

  @override
  String get passwordHelper => 'Mínimo 8 caracteres.';

  @override
  String get haveAccount => '¿Ya tienes cuenta?';

  @override
  String get verifyEmailTitle => 'Confirma tu correo';

  @override
  String get verifyEmailSubtitle => 'Ya casi empiezas.';

  @override
  String codeSent(int length) {
    return 'Enviamos un código de $length dígitos a';
  }

  @override
  String get confirm => 'Confirmar';

  @override
  String resendIn(String time) {
    return '¿No llegó? Reenviar en $time';
  }

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get checkSpam => 'Revisa también la carpeta de spam.';

  @override
  String get changeEmail => 'Cambiar correo';

  @override
  String get or => 'o';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get recording => 'Grabando…';

  @override
  String get recordAudio => 'Grabar audio';

  @override
  String get listenBeforeSaving => 'Escucha antes de guardar';

  @override
  String get recordHint => 'Graba la frase como la escuchaste';

  @override
  String get micDeniedTitle => 'Sin acceso al micrófono';

  @override
  String get micDeniedMessage =>
      'Permite el micrófono en la configuración del celular para grabar.';

  @override
  String ofDuration(String max) {
    return 'de $max';
  }

  @override
  String get recordingTime => 'Tiempo de grabación';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get tapToStop => 'Toca para detener';

  @override
  String get audioPrivacy =>
      'El audio se queda solo en tu celular. Solo guardamos la transcripción.';

  @override
  String get saveToInbox => 'Guardar en el Inbox';

  @override
  String get reRecord => 'Volver a grabar';

  @override
  String get savedProcessing => 'Ya se está procesando.';

  @override
  String get savedOffline =>
      'Desliza la lista del Inbox cuando tengas internet.';

  @override
  String get savedReady => 'Listo para elegir los términos.';

  @override
  String get savedToInbox => 'Guardado en el Inbox';

  @override
  String get see => 'Ver';

  @override
  String get photo => 'Foto';

  @override
  String get photoHint => 'Un letrero, un menú, un subtítulo';

  @override
  String get checkBeforeSaving => 'Revisa antes de guardar';

  @override
  String get cameraDeniedTitle => 'Sin acceso a la cámara';

  @override
  String get cameraDeniedMessage =>
      'Permite la cámara en la configuración del celular para tomar fotos.';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get takePhotoHint => 'Abre la cámara del celular';

  @override
  String get pickFromGallery => 'Elegir de la galería';

  @override
  String get pickFromGalleryHint => 'Usa una foto que ya tienes';

  @override
  String get photoPrivacy =>
      'La foto se queda solo en tu celular. Solo guardamos el texto que se leyó de ella.';

  @override
  String get chosenPhoto => 'Foto elegida';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get typeText => 'Escribir texto';

  @override
  String get typeTextHint => 'Lo que escuchaste o leíste hoy';

  @override
  String get textCaptureLabel => 'Palabra, expresión o frase';

  @override
  String get textCaptureHelper =>
      'Frase o fragmento. Los términos los eliges en el Inbox.';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get homeEmptyTitle => 'Tu inglés empieza aquí';

  @override
  String get homeEmptyMessage =>
      'Captura lo que escuchaste o leíste hoy, con foto, audio o texto. Los términos que confirmes aparecen aquí.';

  @override
  String get homeFirstCapture => 'Hacer la primera captura';

  @override
  String greeting(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'morning': '¡Buenos días!',
      'afternoon': '¡Buenas tardes!',
      'evening': '¡Buenas noches!',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String greetingName(String period, String name) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'morning': 'Buenos días, $name',
      'afternoon': 'Buenas tardes, $name',
      'evening': 'Buenas noches, $name',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get homeTagline => '¿Charlamos?';

  @override
  String get reviewToday => 'Repaso de hoy';

  @override
  String termsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos esperando',
      one: '1 término esperando',
      zero: '$count términos esperando',
    );
    return '$_temp0';
  }

  @override
  String get start => 'Empezar';

  @override
  String get yourVocabulary => 'Tu vocabulario';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get totalTerms => 'Total de términos';

  @override
  String thisWeek(int count) {
    return '+$count esta semana';
  }

  @override
  String learningMastered(int learning, int mastered) {
    return '$learning aprendiendo, $mastered dominados';
  }

  @override
  String termStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'learning': 'Aprendiendo',
      'mastered': 'Dominado',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordOfDay => 'Palabra del día';

  @override
  String get listenPronunciation => 'Escuchar pronunciación';

  @override
  String get addToVocabulary => 'Agregar al vocabulario';

  @override
  String inboxTab(String tab) {
    String _temp0 = intl.Intl.selectLogic(tab, {
      'all': 'Todas',
      'ready': 'Listas',
      'pending': 'Pendientes',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String captureSection(String section) {
    String _temp0 = intl.Intl.selectLogic(section, {
      'attention': 'Requiere atención',
      'ready': 'Listas',
      'processing': 'Procesando',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noConnectionRetry =>
      'Sin conexión. Inténtalo de nuevo cuando tengas internet.';

  @override
  String get inboxEmptyTitle => 'Inbox vacío';

  @override
  String get inboxEmptyMessage => 'Usa el + para capturar un término nuevo.';

  @override
  String get nothingHere => 'Nada por aquí';

  @override
  String get noCapturesInTab => 'No hay capturas en esta pestaña.';

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
    return '$count esperando envío';
  }

  @override
  String get discardCapture => 'Descartar captura';

  @override
  String get pickTerms => 'Elegir términos';

  @override
  String captureSource(String source) {
    String _temp0 = intl.Intl.selectLogic(source, {
      'photo': 'Foto',
      'audio': 'Audio',
      'text': 'Texto',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get confirmHint =>
      'Al confirmar, la IA arma la ficha de cada término.';

  @override
  String get pickAtLeastOne => 'Elige al menos un término';

  @override
  String confirmAnalysisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos',
      one: '1 término',
      zero: '$count términos',
    );
    return 'Confirmar análisis · $_temp0';
  }

  @override
  String get pickHelp =>
      'Desliza el dedo sobre las palabras para marcar una expresión. Toca una palabra para marcar solo esa.';

  @override
  String get textSection => 'Texto';

  @override
  String get done => 'Listo';

  @override
  String get editText => 'Editar texto';

  @override
  String get editTextHelper =>
      'Corrige lo que salió mal. Los términos marcados se mantienen si la palabra no cambia.';

  @override
  String chosenTermsCount(int count) {
    return 'Términos elegidos · $count';
  }

  @override
  String get noTermsYetTap => 'Ninguno todavía. Toca una palabra del texto.';

  @override
  String termTooLong(int max) {
    return 'Expresión demasiado larga. Marca hasta $max caracteres.';
  }

  @override
  String tooManyTerms(int max) {
    return 'Límite de $max términos por captura.';
  }

  @override
  String get stop => 'Detener';

  @override
  String get listenRecording => 'Escuchar grabación';

  @override
  String get discard => 'Descartar';

  @override
  String get processNow => 'Procesar ahora';

  @override
  String get edit => 'Editar';

  @override
  String get confirmAnalysis => 'Confirmar análisis';

  @override
  String get readingPhoto => 'Leyendo el texto de la foto…';

  @override
  String get noTextInPhoto => 'No encontré texto en la foto';

  @override
  String get noSpeech => 'No escuché habla en inglés';

  @override
  String get noTextInPhotoHint => 'Prueba otra foto o descarta esta.';

  @override
  String get noSpeechHint => 'Graba de nuevo o descarta este audio.';

  @override
  String get processFailedTitle => 'No se pudo procesar ahora';

  @override
  String get processFailedHint =>
      'Toca Procesar ahora para intentarlo de nuevo.';

  @override
  String get timeNow => 'ahora';

  @override
  String minutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String get yesterday => 'ayer';

  @override
  String captureStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'failed': 'Error',
      'ready': 'Lista',
      'processing': 'Procesando',
      'analyzed': 'Analizada',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get capturePhoto => 'Foto de la captura';

  @override
  String captureContent(String source) {
    String _temp0 = intl.Intl.selectLogic(source, {
      'text': 'Tu texto',
      'photo': 'Texto de la foto',
      'audio': 'Transcripción',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get missingPhoto =>
      'La foto ya no está en este celular. El texto sigue guardado.';

  @override
  String get missingAudio =>
      'El audio ya no está en este celular. La transcripción sigue guardada.';

  @override
  String termsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos elegidos',
      one: '1 término elegido',
      zero: '$count términos elegidos',
    );
    return '$_temp0';
  }

  @override
  String get waitingModel => 'Esperando que se descargue el modelo de audio…';

  @override
  String get transcribing => 'Transcribiendo el audio…';

  @override
  String get account => 'Cuenta';

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacyText =>
      'La foto y el audio se quedan solo en este celular. La API guarda solo el texto.';

  @override
  String get signOut => 'Salir';

  @override
  String get preferences => 'Preferencias';

  @override
  String get language => 'Idioma';

  @override
  String get languageAuto => 'Automático';

  @override
  String get languageAutoHint => 'Sigue el idioma del celular';

  @override
  String languageAutoValue(String language) {
    return 'Automático · $language';
  }

  @override
  String get languageModalSubtitle => 'Cambia los textos de la app';

  @override
  String modelReady(String size) {
    return 'Transcrito en el celular · modelo de $size';
  }

  @override
  String get ready => 'Listo';

  @override
  String modelDownloading(int percent, String size) {
    return 'Descargando el modelo: $percent% de $size';
  }

  @override
  String get downloading => 'Descargando';

  @override
  String modelWaiting(String size) {
    return 'El modelo de $size se descarga solo cuando tengas internet';
  }

  @override
  String get waiting => 'Esperando';

  @override
  String get worksOffline => 'Funciona sin internet';

  @override
  String get photoText => 'Texto de fotos';

  @override
  String get photoTextHint => 'Leído en el celular, sin enviar la foto';

  @override
  String get englishAudio => 'Audio en inglés';

  @override
  String get statTerms => 'Términos';

  @override
  String get statLearning => 'Aprendiendo';

  @override
  String get statMastered => 'Dominados';

  @override
  String get ungrouped => 'Sin grupo';

  @override
  String get moveFailed =>
      'No se pudo mover ahora. Revisa tu internet e inténtalo de nuevo.';

  @override
  String termsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos movidos',
      one: '1 término movido',
      zero: '$count términos movidos',
    );
    return '$_temp0';
  }

  @override
  String termsMovedTo(int count, String group) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ahora están en $group.',
      one: 'Ahora está en $group.',
      zero: 'Ahora están en $group.',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get undoFailed => 'No se pudo deshacer ahora.';

  @override
  String get deleteFailed =>
      'No se pudo borrar ahora. Revisa tu internet e inténtalo de nuevo.';

  @override
  String termsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos borrados',
      one: '1 término borrado',
      zero: '$count términos borrados',
    );
    return '$_temp0';
  }

  @override
  String termsDeletedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salieron del vocabulario.',
      one: 'Salió del vocabulario.',
      zero: 'Salieron del vocabulario.',
    );
    return '$_temp0';
  }

  @override
  String get cancelSelection => 'Cancelar selección';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get select => 'Seleccionar';

  @override
  String get selectAll => 'Seleccionar todos';

  @override
  String get delete => 'Borrar';

  @override
  String moveTerms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mover $count términos',
      one: 'Mover 1 término',
      zero: 'Selecciona los términos',
    );
    return '$_temp0';
  }

  @override
  String get allOrganized => 'Todo organizado';

  @override
  String get allOrganizedMessage =>
      'Los términos que confirmes en tus capturas llegan aquí.';

  @override
  String get groupEmptyTitle => 'Todavía no hay términos aquí';

  @override
  String get groupEmptyMessage =>
      'Los términos nuevos llegan a Sin grupo. Desde ahí, mueve los que sean de aquí.';

  @override
  String get ungroupedHelp =>
      'Los términos que confirmas en tus capturas llegan aquí. Mueve cada uno a su grupo.';

  @override
  String allCount(int count) {
    return 'Todos · $count';
  }

  @override
  String selectionMeta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
      zero: 'Toca los términos para elegir',
    );
    return '$_temp0';
  }

  @override
  String get nothingToOrganize => 'No hay términos para organizar';

  @override
  String termsToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos para poner en un grupo',
      one: '1 término para poner en un grupo',
      zero: '$count términos para poner en un grupo',
    );
    return '$_temp0';
  }

  @override
  String get noTermsYet => 'Todavía no hay términos';

  @override
  String termCountMastered(int count, int mastered) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos',
      one: '1 término',
      zero: '$count términos',
    );
    return '$_temp0 · $mastered dominados';
  }

  @override
  String termCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos',
      one: '1 término',
      zero: '$count términos',
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
    return '$terms en $groups';
  }

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get editGroupHint => 'Nombre, ícono y color';

  @override
  String get selectTerms => 'Seleccionar términos';

  @override
  String get selectTermsHint => 'Mueve o borra términos';

  @override
  String get deleteGroup => 'Borrar grupo';

  @override
  String get deleteGroupHint => 'Los términos vuelven a Sin grupo';

  @override
  String deleteGroupTitle(String name) {
    return '¿Borrar $name?';
  }

  @override
  String deleteGroupSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Los $count términos vuelven a Sin grupo.',
      one: 'El término vuelve a Sin grupo.',
      zero: 'El grupo está vacío.',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get groupDeleted => 'Grupo borrado';

  @override
  String groupDeletedMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Los $count términos pasaron a Sin grupo.',
      one: 'El término pasó a Sin grupo.',
      zero: '$name salió de la lista.',
    );
    return '$_temp0';
  }

  @override
  String get groupCreated => 'Grupo creado';

  @override
  String groupCreatedMessage(String name) {
    return '$name está arriba en la lista.';
  }

  @override
  String get open => 'Abrir';

  @override
  String get newGroup => 'Nuevo grupo';

  @override
  String get vocabularyEmptyMessage =>
      'Captura y confirma el análisis para empezar.';

  @override
  String get organize => 'Organizar';

  @override
  String get noGroupsYet => 'Todavía no hay grupos';

  @override
  String get noGroupsYetMessage => 'Crea un grupo para organizar tus términos.';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get yourGroups => 'Tus grupos';

  @override
  String get noTermsInGroupYet => 'Sin términos todavía';

  @override
  String percentMastered(int percent) {
    return '$percent% dominado';
  }

  @override
  String groupSaveRejected(String action) {
    String _temp0 = intl.Intl.selectLogic(action, {
      'create': 'No se pudo crear el grupo.',
      'save': 'No se pudo guardar el grupo.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String groupSaveFailed(String action) {
    String _temp0 = intl.Intl.selectLogic(action, {
      'create': 'No se pudo crear el grupo ahora. Inténtalo de nuevo.',
      'save': 'No se pudo guardar el grupo ahora. Inténtalo de nuevo.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get offlineRetry => 'Sin conexión. Inténtalo de nuevo.';

  @override
  String get groupModalNewHint => 'Junta términos del mismo tema';

  @override
  String get groupModalEditHint => 'Cambia el nombre, el ícono o el color';

  @override
  String get groupNameHint => 'Ej.: Música, Facultad';

  @override
  String get groupNameTaken => 'Ya tienes un grupo con ese nombre.';

  @override
  String get nameTheGroup => 'Ponle un nombre al grupo';

  @override
  String get save => 'Guardar';

  @override
  String get moveModalTitle => '¿A qué grupo mover?';

  @override
  String moveModalSubtitle(String terms, String from) {
    return '$terms de $from';
  }

  @override
  String get noGroupsTitle => 'Todavía no tienes grupos';

  @override
  String get noGroupsMessage => 'Crea un grupo para guardar estos términos.';

  @override
  String get countryOfOrigin => 'País de origen';

  @override
  String get countryNotSet => 'Elige uno para mostrar su bandera en tu avatar';

  @override
  String get countryModalSubtitle => 'Aparece como bandera en tu avatar';

  @override
  String get searchCountry => 'Buscar país';

  @override
  String get countryNone => 'Prefiero no decirlo';

  @override
  String get countrySaveFailed =>
      'No se pudo guardar el país. Revisa tu internet e inténtalo de nuevo.';

  @override
  String get noCountryFound => 'Ningún país con ese nombre';

  @override
  String countryFlag(String country) {
    return 'Bandera: $country';
  }

  @override
  String termKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'word': 'Palabra',
      'expression': 'Expresión',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String groupIcon(String icon) {
    String _temp0 = intl.Intl.selectLogic(icon, {
      'layers': 'General',
      'talk': 'Conversación',
      'work': 'Trabajo',
      'travel': 'Viajes',
      'food': 'Comida',
      'tv': 'Series',
      'music': 'Música',
      'study': 'Estudios',
      'heart': 'Favoritos',
      'game': 'Juegos',
      'shopping': 'Compras',
      'sport': 'Deporte',
      'health': 'Salud',
      'home': 'Casa',
      'nature': 'Naturaleza',
      'paw': 'Animales',
      'tech': 'Tecnología',
      'money': 'Dinero',
      'car': 'Transporte',
      'family': 'Familia',
      'book': 'Libros',
      'art': 'Arte',
      'party': 'Fiesta',
      'weather': 'Clima',
      'phone': 'Celular',
      'mail': 'Correo',
      'code': 'Programación',
      'science': 'Ciencia',
      'news': 'Noticias',
      'movie': 'Cine',
      'camera': 'Fotografía',
      'place': 'Lugares',
      'city': 'Ciudad',
      'globe': 'Mundo',
      'calendar': 'Fechas',
      'clock': 'Rutina',
      'star': 'Importante',
      'idea': 'Ideas',
      'smile': 'Sentimientos',
      'shirt': 'Ropa',
      'restaurant': 'Restaurante',
      'drink': 'Bebidas',
      'mountain': 'Aventura',
      'gift': 'Regalos',
      'flag': 'Países',
      'podcast': 'Podcasts',
      'goal': 'Metas',
      'writing': 'Escritura',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String courseLanguage(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'Inglés',
      'es': 'Español',
      'pt': 'Portugués',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String courseName(String learning, String base) {
    String _temp0 = intl.Intl.selectLogic(learning, {
      'en': 'Inglés',
      'es': 'Español',
      'pt': 'Portugués',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(base, {
      'en': 'inglés',
      'es': 'español',
      'pt': 'portugués',
      'other': '',
    });
    return '$_temp0 a través del $_temp1';
  }

  @override
  String courseVia(String base, int count) {
    String _temp0 = intl.Intl.selectLogic(base, {
      'en': 'inglés',
      'es': 'español',
      'pt': 'portugués',
      'other': '',
    });
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count términos',
      one: '1 término',
      zero: 'ningún término',
    );
    return 'a través del $_temp0 · $_temp1';
  }

  @override
  String get courseNoAudio => 'Audio aún no disponible';

  @override
  String courseOptionNoAudio(String name) {
    return '$name · sin audio por ahora';
  }

  @override
  String get coursePickTitle => '¿Qué quieres aprender?';

  @override
  String get coursePickSubtitle => 'Puedes añadir otro idioma después.';

  @override
  String get courseLearnSection => 'Quiero aprender';

  @override
  String get courseBaseSection => 'A través de';

  @override
  String get courseBaseHint =>
      'Las traducciones y explicaciones vienen en este idioma.';

  @override
  String get coursePickLearning => 'Elige el idioma que quieres aprender';

  @override
  String get coursePickBase => 'Elige a través de qué idioma';

  @override
  String courseStart(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'inglés',
      'es': 'español',
      'pt': 'portugués',
      'other': '',
    });
    return 'Empezar a aprender $_temp0';
  }

  @override
  String get courseStartFailed =>
      'No se pudo empezar ahora. Revisa tu conexión.';

  @override
  String get courseSwitchFailed =>
      'No se pudo cambiar de curso. Revisa tu conexión.';

  @override
  String get coursesTitle => 'Tus cursos';

  @override
  String get coursesSubtitle => 'Cada uno tiene sus capturas y términos';

  @override
  String get courseAdd => 'Aprender otro idioma';

  @override
  String courseBadge(String name) {
    return 'Curso: $name. Cambiar';
  }

  @override
  String get profileStudy => 'Estudio';

  @override
  String get courseChange => 'Cambiar o añadir curso';

  @override
  String progressIn(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'inglés',
      'es': 'español',
      'pt': 'portugués',
      'other': '',
    });
    return 'Progreso en $_temp0';
  }

  @override
  String get termCardLoading => 'Armando la ficha…';

  @override
  String get meaning => 'Significado';

  @override
  String get coverAgain => 'Empañar de nuevo';

  @override
  String get reveal => 'Revelar';

  @override
  String cardSide(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'inglés',
      'es': 'español',
      'pt': 'portugués',
      'other': '',
    });
    return 'En $_temp0';
  }

  @override
  String seeIn(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'en': 'inglés',
      'es': 'español',
      'pt': 'portugués',
      'other': '',
    });
    return 'Ver en $_temp0';
  }

  @override
  String get inYourContext => 'En tu contexto';

  @override
  String get explanation => 'Explicación';

  @override
  String termTab(String tab) {
    String _temp0 = intl.Intl.selectLogic(tab, {
      'context': 'Contexto',
      'words': 'Palabras',
      'usage': 'Uso',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get whereYouSaw => 'Dónde lo viste';

  @override
  String get alsoMarked => 'También marcado';

  @override
  String get examples => 'Ejemplos';

  @override
  String get collocations => 'Arma la frase';

  @override
  String get synonyms => 'Casi lo mismo';

  @override
  String get antonyms => 'Lo contrario';

  @override
  String get formality => 'De chanclas a corbata';

  @override
  String formalityLevel(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'slang': 'Jerga',
      'informal': 'Informal',
      'neutral': 'Neutro',
      'formal': 'Formal',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String formalityMeter(String level, int step) {
    return 'Formalidad: $level, $step de 4';
  }

  @override
  String get whereItFits => 'Dónde encaja';

  @override
  String preferInstead(String word) {
    return 'Mejor $word';
  }

  @override
  String get listenSlow => 'Despacio';

  @override
  String get literally => 'Al pie de la letra';

  @override
  String get itMeans => 'Quiere decir';

  @override
  String get imagine => 'Imagina:';

  @override
  String get remember => 'Para recordar';

  @override
  String get pitfallTitle => 'Trampa';

  @override
  String get sayNot => 'No digas';

  @override
  String get say => 'Di';

  @override
  String get gotItQuestion => '¿Lo entendiste por el contexto?';

  @override
  String get gotItYes => 'Lo entendí';

  @override
  String get gotItNo => 'No';

  @override
  String get gotItYesReply => '¡Bien! El contexto te lo dijo.';

  @override
  String get gotItNoReply => 'Tranquilo. Ahora ya lo sabes.';

  @override
  String seenVia(String source) {
    String _temp0 = intl.Intl.selectLogic(source, {
      'photo': 'Lo leíste en una foto',
      'audio': 'Lo oíste',
      'text': 'Lo anotaste',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get dialogue => 'En una conversación';

  @override
  String get listen => 'Escuchar';

  @override
  String get dialogueHint => 'Toca un globo para ver la traducción.';

  @override
  String get collocationsHint => 'Piezas que van con el término.';

  @override
  String listenTo(String text) {
    return 'Escuchar $text';
  }

  @override
  String get neighbors => 'Vecinos';

  @override
  String get fitsYes => 'Encaja';

  @override
  String get fitsNo => 'No encaja';
}
