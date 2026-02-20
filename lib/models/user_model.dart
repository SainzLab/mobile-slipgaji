class User {
  final int id;
  final String nip;
  final String nama;
  final String email;
  final String token;

  User({required this.id, required this.nip, required this.nama, required this.email, this.token = ""});

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'],
      nip: json['nip'],
      nama: json['nama_pegawai'],
      email: json['email'],
      token: token ?? "",
    );
  }
}