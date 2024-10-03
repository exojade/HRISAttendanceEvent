class ServerUrl {
  final String serverUrl;

  ServerUrl({
    required this.serverUrl,
  });

  factory ServerUrl.fromJson(Map<String, dynamic> json) {
    return ServerUrl(
      serverUrl: json['serverUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverUrl': serverUrl,
    };
  }
}
