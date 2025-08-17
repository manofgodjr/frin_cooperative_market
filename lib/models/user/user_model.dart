// ADDED: A simple User model to hold user data.
class User {
  final String? username;
  final String? lastname;
  final String? cardnumber;
  final String? phonenumber;

  User({
    this.lastname,
    this.cardnumber,
    this.phonenumber,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      lastname: json['last_name'],
      username: json['username'],
      cardnumber: json['card_number'],
      phonenumber: json['phone_number'],
    );
  }
}
