class ServerModel {
  // Business rule: US & India are the free tier; every other country is paid.
  static const Set<String> _freeCountryCodes = {'US', 'IN'};

  final String id;
  final String countryName;
  final String countryCode;
  final String city;
  final String serverName;
  final String endpoint;      // WireGuard endpoint e.g. "abc-123-wg.whiskergalaxy.com:443"
  final String publicKey;
  final String privateKey;
  final String presharedKey;
  final String address;       // e.g. "100.87.71.70/32"
  final String dns;
  final String allowedIps;
  final int keepalive;
  final bool isPremium;       // from API's is_premium / is_free
  final String flagUrl;       // remote flag image URL

  const ServerModel({
    required this.id,
    required this.countryName,
    required this.countryCode,
    required this.city,
    required this.serverName,
    required this.endpoint,
    required this.publicKey,
    required this.privateKey,
    required this.presharedKey,
    required this.address,
    required this.dns,
    required this.allowedIps,
    required this.keepalive,
    required this.isPremium,
    required this.flagUrl,
  });

  /// Parse from API JSON object
  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id:           json['id']?.toString() ?? '',
      countryName:  json['country_name'] ?? '',
      countryCode:  json['country_code'] ?? '',
      city:         json['city_name'] ?? '',
      serverName:   json['server_name'] ?? '',
      endpoint:     json['endpoint'] ?? '',
      publicKey:    json['peer_public_key'] ?? '',
      privateKey:   json['interface_private_key'] ?? '',
      presharedKey: json['preshared_key'] ?? '',
      address:      json['interface_address'] ?? '',
      dns:          json['dns'] ?? '1.1.1.1',
      allowedIps:   json['allowed_ips'] ?? '0.0.0.0/0',
      keepalive:    int.tryParse(json['keepalive']?.toString() ?? '25') ?? 25,
      isPremium:    !_freeCountryCodes
          .contains((json['country_code'] ?? '').toString().toUpperCase()),
      flagUrl:      json['flag_url'] ?? '',
    );
  }

  /// Emoji flag derived from countryCode
  String get flag {
    final code = countryCode.toUpperCase();
    if (code.length != 2) return '🌍';
    return code.split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) + 127397);
    }).join();
  }

  /// Extract host from endpoint (removes port)
  String get host {
    return endpoint.split(':').first;
  }

  /// Extract port from endpoint
  int get port {
    final parts = endpoint.split(':');
    return parts.length > 1 ? int.tryParse(parts.last) ?? 443 : 443;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ServerModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}