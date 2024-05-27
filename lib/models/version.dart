class Version {
  final String version;

  Version({
    required this.version,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
    };
  }
}
