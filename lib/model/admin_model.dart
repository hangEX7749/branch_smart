class Admin {

  String uid;
  String name;
  String email;
  int status;

  // Predefined status codes
  static const int active = 10;
  static const int pending = 30;
  static const int inactive = 90;

  Admin({
    required this.uid,
    required this.name, 
    required this.email, 
    required this.status
  });

  Map<String, dynamic> toMap() {
    return {
      'uid' : uid,
      'name': name,
      'email': email, 
      'status': status,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      status: map['status']
    );
  }

}
