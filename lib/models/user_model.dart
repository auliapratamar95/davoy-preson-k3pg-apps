class UserModel {
  final String code;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;

  const UserModel({
    required this.code,
    required this.name,
    this.email = '-',
    this.phone = '-',
    this.address = '-',
    this.avatarUrl = '',
  });

  factory UserModel.initial() {
    return const UserModel(
      code: 'K-19030',
      name: 'WULAN SETYA PUTRI',
      email: 'wulan.setya@k3pg.co.id',
      phone: '+62 812-3456-7890',
      address: 'Gresik, Jawa Timur',
      avatarUrl: 'https://preson.k3pg.co.id/sw-content/avatar.jpg',
    );
  }

  UserModel copyWith({
    String? code,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
  }) {
    return UserModel(
      code: code ?? this.code,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
