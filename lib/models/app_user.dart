class AppUser {
  String id;
  String name;
  String username;
  String email;
  String? photoUrl;
  String? bio;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.photoUrl,
    this.bio,
  });

  AppUser.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        name = data['name'],
        username = data['username'],
        email = data['email'],
        photoUrl = data['photoUrl'],
        bio = data['bio'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
    };
  }
}