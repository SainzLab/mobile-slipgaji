class User {
  final int id;
  final String nip;
  final String nama;
  final String email;
  final String token;

  User({
    required this.id, 
    required this.nip, 
    required this.nama, 
    required this.email, 
    this.token = ""
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] ?? 0,
      nip: json['nip']?.toString() ?? "",
      nama: json['nama_pegawai']?.toString() ?? "User Pegawai",
      email: json['email']?.toString() ?? "", 
      token: token ?? "",
    );
  }
}