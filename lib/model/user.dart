import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  const User({
    required this.name,
    required this.uid,
    required this.imgUrl,
    required this.email,
  });

  final String name;
  final String uid;
  final String? imgUrl;
  final String email;

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return User(
      name: data['username'],
      uid: snapshot.id,
      email: data['email'],
      imgUrl: data['image_url'] ?? dummyProfileImageUrl,
    );
  }
}

const dummyProfileImageUrl =
    'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png';
