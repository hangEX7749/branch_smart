class Admin {

  String id;
  String name;
  String email;
  String status;

  Admin({
    required this.id,
    required this.name, 
    required this.email, 
    required this.status
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name': name,
      'email': email, 
      'status': status,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      status: map['status']
    );
  }


}
