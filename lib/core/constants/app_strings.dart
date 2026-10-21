/// Archivo centralizado de strings de la aplicación "Tiempo con Dios".
/// Facilita la localización, mantenimiento y coherencia en toda la interfaz.
class AppStrings {
  AppStrings._();

  static const String appName = 'Tiempo con Dios';
  static const String appTagline = 'Un espacio digital para desconectarte de todo y encontrarte con Dios en lo secreto.';

  // Notificaciones - Acciones y Textos
  static const String notifEmpezarAction = 'Empezar';
  static const String notifHoraDevocionalTitulo = 'Es momento de tu tiempo con Dios';
  static const String notifHoraDevocionalCuerpo = 'Tu Padre te espera en lo secreto. Tu Biblia y cuaderno están listos.';
  static const String notifAvisoPrevioTitulo = 'Prepara tu espacio';
  static const String notifAvisoPrevioCuerpo = 'Deja lista tu Biblia, cuaderno y pluma para tu tiempo con Dios.';
  static const String notifReengancheTitulo = 'Tiempo con Dios';

  // Módulo 4: Onboarding (Contenido EXACTO especificado)
  static const String onboardingTitulo = 'Tiempo con Dios';
  static const String onboardingSubtitulo = 'Un espacio digital para desconectarte de todo y encontrarte con Dios en lo secreto.';

  // Bloque 1
  static const String onboardingBloque1Titulo = 'Con tu Biblia y cuaderno físico';
  static const String onboardingBloque1Texto = 'Esta app está pensada para ser cerrada. El celular reposa a un lado mientras tu corazón se enfoca en lo importante.';

  // Bloque 2
  static const String onboardingBloque2Titulo = 'Cero culpa, sin rachas rotas';
  static const String onboardingBloque2Texto = 'Tu progreso no se destruye si fallas un día. Dios valora tu constancia, no el perfeccionismo.';

  // Bloque 3
  static const String onboardingBloque3Titulo = 'Privacidad y sincronización en la nube';
  static const String onboardingBloque3Texto = 'Inicia sesión con tu cuenta para mantener tu progreso a salvo en cualquier dispositivo. Tu intimidad con Dios se guarda con total seguridad.';

  // Bienvenida y Captura de Nombre
  static const String bienvenidaGenerica = 'Bienvenido';
  static String bienvenidaUsuario(String nombre) => 'Bienvenido, $nombre';
  static const String placeholderNombre = 'Agrega tu nombre';
  static const String botonAhoraNo = 'Ahora no';
  static const String botonGuardar = 'Guardar';
  static const String botonContinuar = 'Continuar';
  static const String botonComenzar = 'Comenzar';
  static const String repetirBienvenida = 'Repetir bienvenida';

  // Módulo 2: Corrección de tiempo
  static const String dialogoOlvidoTitulo = 'Parece que olvidaste terminar tu tiempo con Dios';
  static const String dialogoOlvidoSubtitulo = '¿Cuánto tiempo duró realmente?';
  static const String botonDescartarSesion = 'Descartar sesión';
  static const String botonGuardarDuracion = 'Guardar';
  static const String sesionPendienteAviso = 'Tienes una sesión pendiente de confirmar';
  static const String indicadorEditadoManualmente = 'Editado manualmente';

  // Módulo 3: Programar horario
  static const String botonProgramarHorario = 'Programar horario';
  static const String proximoHorario = 'Próximo horario';

  // Módulo 6: Tema
  static const String temaTitulo = 'Apariencia / Tema';
  static const String temaClaro = 'Claro';
  static const String temaOscuro = 'Oscuro';
  static const String temaAutomatico = 'Automático (del sistema)';
}
