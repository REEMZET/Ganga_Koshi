class UserModel {
  String name;
  String userPhone;
  String uid;
  String deviceId;
  String regDate;



  UserModel({
    required this.name,
    required this.userPhone,
    required this.uid,
    required this.deviceId,
    required this.regDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userphone': userPhone,
      'uid': uid,
      'deviceid': deviceId,
      'regdate': regDate,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      userPhone: json['userphone'] ?? '',
      uid: json['uid'] ?? '',
      deviceId: json['deviceid'] ?? '',
      regDate: json['regdate'] ?? '',
    );
  }
}
