import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  const User({
    required this.name,
    required this.uid,
    required this.imgUrl,
  });

  final String name;
  final String uid;
  final String? imgUrl;

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return User(
      name: data['username'],
      uid: snapshot.id,
      imgUrl: data['image_url'] ??
          'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
    );
  }
}
