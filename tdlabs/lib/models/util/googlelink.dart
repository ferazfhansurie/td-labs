class GoogleLinks {
  String? uid;
  String? email;
  String? emailVerified;
  String? displayName;
  String? isAnonymous;
  String? photoURL;
  List<Map<String, dynamic>>? providerData;
  GoogleLinks(
      {this.uid,
      this.email,
      this.emailVerified,
      this.displayName,
      this.isAnonymous,
      this.photoURL,
      this.providerData});

  factory GoogleLinks.fromJson(Map<String, dynamic> json) {
    return GoogleLinks(
      uid: json['uid'],
      email: json['email'],
      emailVerified: json['emailVerified'],
      displayName: json['displayName'],
      isAnonymous: json['isAnonymous'],
      photoURL: json['photoURL'],
      providerData: json['providerData'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'emailVerified': emailVerified,
        'displayName': displayName,
        'isAnonymous': isAnonymous,
        'photoURL': photoURL,
        'providerData': providerData,
      };
}
