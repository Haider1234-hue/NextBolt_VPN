import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';

class AppLocalizations {
  // ── App ──────────────────────────────────────────────────
  final String appName;
  final String appTagline;

  // ── Splash ───────────────────────────────────────────────
  final String splashLoading;

  // ── Onboarding ───────────────────────────────────────────
  final String onboardTitle1;
  final String onboardBody1;
  final String onboardTitle2;
  final String onboardBody2;
  final String onboardTitle3;
  final String onboardBody3;
  final String getStarted;
  final String skip;
  final String next;

  // ── Home ─────────────────────────────────────────────────
  final String notConnected;
  final String connected;
  final String connecting;
  final String disconnecting;
  final String tapToConnect;
  final String tapToDisconnect;
  final String yourIp;
  final String protectedIp;
  final String selectServer;
  final String bestLocation;
  final String selectFastestServer;
  final String download;
  final String upload;
  final String duration;
  final String dataUsedToday;
  final String dataUsedThisMonth;

  // ── Servers ──────────────────────────────────────────────
  final String servers;
  final String searchServers;
  final String freeServers;
  final String premiumServers;
  final String recommended;

  // ── Settings ─────────────────────────────────────────────
  final String settings;
  final String general;
  final String security;
  final String support;
  final String killSwitch;
  final String killSwitchSub;
  final String autoConnect;
  final String autoConnectSub;
  final String protocol;
  final String protocolSub;
  final String language;
  final String privacyPolicy;
  final String termsOfService;
  final String rateUs;
  final String contactSupport;
  final String appVersion;

  // ── Premium ──────────────────────────────────────────────
  final String upgradeToPro;
  final String premiumTagline;
  final String weekly;
  final String monthly;
  final String yearly;
  final String bestValue;
  final String restorePurchase;
  final String continueWithFree;
  final String unlockServers;
  final String getPro;

  // ── Errors ───────────────────────────────────────────────
  final String connectionFailed;
  final String noInternet;
  final String permissionDenied;

  const AppLocalizations._({
    required this.appName,
    required this.appTagline,
    required this.splashLoading,
    required this.onboardTitle1,
    required this.onboardBody1,
    required this.onboardTitle2,
    required this.onboardBody2,
    required this.onboardTitle3,
    required this.onboardBody3,
    required this.getStarted,
    required this.skip,
    required this.next,
    required this.notConnected,
    required this.connected,
    required this.connecting,
    required this.disconnecting,
    required this.tapToConnect,
    required this.tapToDisconnect,
    required this.yourIp,
    required this.protectedIp,
    required this.selectServer,
    required this.bestLocation,
    required this.selectFastestServer,
    required this.download,
    required this.upload,
    required this.duration,
    required this.dataUsedToday,
    required this.dataUsedThisMonth,
    required this.servers,
    required this.searchServers,
    required this.freeServers,
    required this.premiumServers,
    required this.recommended,
    required this.settings,
    required this.general,
    required this.security,
    required this.support,
    required this.killSwitch,
    required this.killSwitchSub,
    required this.autoConnect,
    required this.autoConnectSub,
    required this.protocol,
    required this.protocolSub,
    required this.language,
    required this.privacyPolicy,
    required this.termsOfService,
    required this.rateUs,
    required this.contactSupport,
    required this.appVersion,
    required this.upgradeToPro,
    required this.premiumTagline,
    required this.weekly,
    required this.monthly,
    required this.yearly,
    required this.bestValue,
    required this.restorePurchase,
    required this.continueWithFree,
    required this.unlockServers,
    required this.getPro,
    required this.connectionFailed,
    required this.noInternet,
    required this.permissionDenied,
  });

  // ── Access ───────────────────────────────────────────────
  static AppLocalizations of(BuildContext context) {
    final lang = context.watch<SettingsService>().language;
    return _all[lang] ?? _en;
  }

  // ── English ───────────────────────────────────────────────
  static const AppLocalizations _en = AppLocalizations._(
    appName: 'NextBolt VPN',
    appTagline: 'Fast. Private. Secure.',
    splashLoading: 'Loading...',
    onboardTitle1: 'Military-Grade Encryption',
    onboardBody1: 'Your data is shielded with AES-256 encryption on every connection.',
    onboardTitle2: 'Global Server Network',
    onboardBody2: 'Connect to 50+ countries and unlock the full internet.',
    onboardTitle3: 'Zero Logs. Zero Tracking.',
    onboardBody3: 'We never store your activity. Privacy is our promise.',
    getStarted: 'Get Started',
    skip: 'Skip',
    next: 'Next',
    notConnected: 'Not Connected',
    connected: 'Connected',
    connecting: 'Connecting...',
    disconnecting: 'Disconnecting...',
    tapToConnect: 'Tap to Connect',
    tapToDisconnect: 'Tap to Disconnect',
    yourIp: 'Your IP',
    protectedIp: 'Protected',
    selectServer: 'Select Server',
    bestLocation: 'Best Location',
    selectFastestServer: 'Select fastest server',
    download: 'Download',
    upload: 'Upload',
    duration: 'Duration',
    dataUsedToday: 'Data used today',
    dataUsedThisMonth: 'Data used this month',
    servers: 'Servers',
    searchServers: 'Search countries...',
    freeServers: 'Free Servers',
    premiumServers: 'Premium Servers',
    recommended: 'Recommended',
    settings: 'Settings',
    general: 'General',
    security: 'Security',
    support: 'Support',
    killSwitch: 'Kill Switch',
    killSwitchSub: 'Block internet if VPN drops',
    autoConnect: 'Auto Connect',
    autoConnectSub: 'Connect VPN on app launch',
    protocol: 'Protocol',
    protocolSub: 'WireGuard / OpenVPN / IKEv2',
    language: 'Language',
    privacyPolicy: 'Privacy Policy',
    termsOfService: 'Terms of Service',
    rateUs: 'Rate NextBolt VPN',
    contactSupport: 'Contact Support',
    appVersion: 'App Version',
    upgradeToPro: 'Upgrade to Pro',
    premiumTagline: 'Unlock all servers and features',
    weekly: 'Weekly',
    monthly: 'Monthly',
    yearly: 'Yearly',
    bestValue: 'BEST VALUE',
    restorePurchase: 'Restore Purchase',
    continueWithFree: 'Continue with Free',
    unlockServers: 'Unlock 50+ servers & 10x speed',
    getPro: 'Get Pro',
    connectionFailed: 'Connection failed. Try another server.',
    noInternet: 'No internet connection.',
    permissionDenied: 'VPN permission is required to continue.',
  );

  // ── Español ───────────────────────────────────────────────
  static const AppLocalizations _es = AppLocalizations._(
    appName: 'NextBolt VPN',
    appTagline: 'Rápido. Privado. Seguro.',
    splashLoading: 'Cargando...',
    onboardTitle1: 'Cifrado Militar',
    onboardBody1: 'Tus datos están protegidos con cifrado AES-256 en cada conexión.',
    onboardTitle2: 'Red Global de Servidores',
    onboardBody2: 'Conéctate a más de 50 países y desbloquea todo el internet.',
    onboardTitle3: 'Sin Registros. Sin Rastreo.',
    onboardBody3: 'Nunca almacenamos tu actividad. La privacidad es nuestra promesa.',
    getStarted: 'Comenzar',
    skip: 'Omitir',
    next: 'Siguiente',
    notConnected: 'No Conectado',
    connected: 'Conectado',
    connecting: 'Conectando...',
    disconnecting: 'Desconectando...',
    tapToConnect: 'Toca para Conectar',
    tapToDisconnect: 'Toca para Desconectar',
    yourIp: 'Tu IP',
    protectedIp: 'Protegida',
    selectServer: 'Seleccionar Servidor',
    bestLocation: 'Mejor Ubicación',
    selectFastestServer: 'Seleccionar servidor más rápido',
    download: 'Descarga',
    upload: 'Subida',
    duration: 'Duración',
    dataUsedToday: 'Datos usados hoy',
    dataUsedThisMonth: 'Datos usados este mes',
    servers: 'Servidores',
    searchServers: 'Buscar países...',
    freeServers: 'Servidores Gratuitos',
    premiumServers: 'Servidores Premium',
    recommended: 'Recomendado',
    settings: 'Ajustes',
    general: 'General',
    security: 'Seguridad',
    support: 'Soporte',
    killSwitch: 'Kill Switch',
    killSwitchSub: 'Bloquear internet si cae la VPN',
    autoConnect: 'Conexión Automática',
    autoConnectSub: 'Conectar VPN al iniciar la app',
    protocol: 'Protocolo',
    protocolSub: 'WireGuard / OpenVPN / IKEv2',
    language: 'Idioma',
    privacyPolicy: 'Política de Privacidad',
    termsOfService: 'Términos de Servicio',
    rateUs: 'Calificar NextBolt VPN',
    contactSupport: 'Contactar Soporte',
    appVersion: 'Versión de la App',
    upgradeToPro: 'Actualizar a Pro',
    premiumTagline: 'Desbloquea todos los servidores y funciones',
    weekly: 'Semanal',
    monthly: 'Mensual',
    yearly: 'Anual',
    bestValue: 'MEJOR VALOR',
    restorePurchase: 'Restaurar Compra',
    continueWithFree: 'Continuar Gratis',
    unlockServers: 'Desbloquea 50+ servidores y velocidad 10x',
    getPro: 'Obtener Pro',
    connectionFailed: 'Conexión fallida. Prueba otro servidor.',
    noInternet: 'Sin conexión a internet.',
    permissionDenied: 'Se requiere permiso VPN para continuar.',
  );

  // ── Deutsch ───────────────────────────────────────────────
  static const AppLocalizations _de = AppLocalizations._(
    appName: 'NextBolt VPN',
    appTagline: 'Schnell. Privat. Sicher.',
    splashLoading: 'Laden...',
    onboardTitle1: 'Militärische Verschlüsselung',
    onboardBody1: 'Deine Daten werden mit AES-256-Verschlüsselung bei jeder Verbindung geschützt.',
    onboardTitle2: 'Globales Servernetzwerk',
    onboardBody2: 'Verbinde dich mit 50+ Ländern und entsperre das gesamte Internet.',
    onboardTitle3: 'Keine Protokolle. Kein Tracking.',
    onboardBody3: 'Wir speichern niemals deine Aktivität. Datenschutz ist unser Versprechen.',
    getStarted: 'Loslegen',
    skip: 'Überspringen',
    next: 'Weiter',
    notConnected: 'Nicht Verbunden',
    connected: 'Verbunden',
    connecting: 'Verbinde...',
    disconnecting: 'Trenne...',
    tapToConnect: 'Tippen zum Verbinden',
    tapToDisconnect: 'Tippen zum Trennen',
    yourIp: 'Deine IP',
    protectedIp: 'Geschützt',
    selectServer: 'Server Auswählen',
    bestLocation: 'Bester Standort',
    selectFastestServer: 'Schnellsten Server wählen',
    download: 'Download',
    upload: 'Upload',
    duration: 'Dauer',
    dataUsedToday: 'Heute verbrauchte Daten',
    dataUsedThisMonth: 'Diesen Monat verbrauchte Daten',
    servers: 'Server',
    searchServers: 'Länder suchen...',
    freeServers: 'Kostenlose Server',
    premiumServers: 'Premium Server',
    recommended: 'Empfohlen',
    settings: 'Einstellungen',
    general: 'Allgemein',
    security: 'Sicherheit',
    support: 'Support',
    killSwitch: 'Kill Switch',
    killSwitchSub: 'Internet sperren wenn VPN abbricht',
    autoConnect: 'Automatisch Verbinden',
    autoConnectSub: 'VPN beim App-Start verbinden',
    protocol: 'Protokoll',
    protocolSub: 'WireGuard / OpenVPN / IKEv2',
    language: 'Sprache',
    privacyPolicy: 'Datenschutzrichtlinie',
    termsOfService: 'Nutzungsbedingungen',
    rateUs: 'NextBolt VPN bewerten',
    contactSupport: 'Support kontaktieren',
    appVersion: 'App-Version',
    upgradeToPro: 'Auf Pro upgraden',
    premiumTagline: 'Alle Server und Funktionen freischalten',
    weekly: 'Wöchentlich',
    monthly: 'Monatlich',
    yearly: 'Jährlich',
    bestValue: 'BESTES ANGEBOT',
    restorePurchase: 'Kauf wiederherstellen',
    continueWithFree: 'Kostenlos weiter',
    unlockServers: '50+ Server & 10x Geschwindigkeit freischalten',
    getPro: 'Pro holen',
    connectionFailed: 'Verbindung fehlgeschlagen. Anderen Server versuchen.',
    noInternet: 'Keine Internetverbindung.',
    permissionDenied: 'VPN-Berechtigung erforderlich.',
  );

  // ── Français ──────────────────────────────────────────────
  static const AppLocalizations _fr = AppLocalizations._(
    appName: 'NextBolt VPN',
    appTagline: 'Rapide. Privé. Sécurisé.',
    splashLoading: 'Chargement...',
    onboardTitle1: 'Chiffrement Militaire',
    onboardBody1: 'Vos données sont protégées par un chiffrement AES-256 à chaque connexion.',
    onboardTitle2: 'Réseau Mondial de Serveurs',
    onboardBody2: 'Connectez-vous à plus de 50 pays et débloquez tout internet.',
    onboardTitle3: 'Zéro Journal. Zéro Traçage.',
    onboardBody3: 'Nous ne stockons jamais votre activité. La confidentialité est notre engagement.',
    getStarted: 'Commencer',
    skip: 'Passer',
    next: 'Suivant',
    notConnected: 'Non Connecté',
    connected: 'Connecté',
    connecting: 'Connexion...',
    disconnecting: 'Déconnexion...',
    tapToConnect: 'Appuyer pour Connecter',
    tapToDisconnect: 'Appuyer pour Déconnecter',
    yourIp: 'Votre IP',
    protectedIp: 'Protégée',
    selectServer: 'Choisir un Serveur',
    bestLocation: 'Meilleur Emplacement',
    selectFastestServer: 'Choisir le serveur le plus rapide',
    download: 'Téléchargement',
    upload: 'Envoi',
    duration: 'Durée',
    dataUsedToday: 'Données utilisées aujourd\'hui',
    dataUsedThisMonth: 'Données utilisées ce mois',
    servers: 'Serveurs',
    searchServers: 'Rechercher des pays...',
    freeServers: 'Serveurs Gratuits',
    premiumServers: 'Serveurs Premium',
    recommended: 'Recommandé',
    settings: 'Paramètres',
    general: 'Général',
    security: 'Sécurité',
    support: 'Support',
    killSwitch: 'Kill Switch',
    killSwitchSub: 'Bloquer internet si le VPN tombe',
    autoConnect: 'Connexion Automatique',
    autoConnectSub: 'Connecter le VPN au démarrage',
    protocol: 'Protocole',
    protocolSub: 'WireGuard / OpenVPN / IKEv2',
    language: 'Langue',
    privacyPolicy: 'Politique de Confidentialité',
    termsOfService: "Conditions d'Utilisation",
    rateUs: 'Évaluer NextBolt VPN',
    contactSupport: 'Contacter le Support',
    appVersion: "Version de l'App",
    upgradeToPro: 'Passer à Pro',
    premiumTagline: 'Débloquez tous les serveurs et fonctionnalités',
    weekly: 'Hebdomadaire',
    monthly: 'Mensuel',
    yearly: 'Annuel',
    bestValue: 'MEILLEURE VALEUR',
    restorePurchase: "Restaurer l'achat",
    continueWithFree: 'Continuer Gratuitement',
    unlockServers: 'Débloquez 50+ serveurs et vitesse 10x',
    getPro: 'Obtenir Pro',
    connectionFailed: 'Connexion échouée. Essayez un autre serveur.',
    noInternet: 'Pas de connexion internet.',
    permissionDenied: 'Permission VPN requise pour continuer.',
  );

  static const Map<String, AppLocalizations> _all = {
    'English': _en,
    'Español': _es,
    'Deutsch': _de,
    'Français': _fr,
  };
}
