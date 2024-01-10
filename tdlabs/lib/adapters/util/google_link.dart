import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tdlabs/firebase_options.dart';
import 'package:tdlabs/utils/progress_dialog.dart';
import 'package:tdlabs/utils/web_service.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import '../../models/util/googlelink.dart';
import '../../utils/toast.dart';

// ignore: must_be_immutable
class GoogleLink extends StatefulWidget {
  String? title;
  int? method;
  int? linked;
  GoogleLink({Key? key, this.title, this.method, this.linked}): super(key: key);
  @override
  State<GoogleLink> createState() => _GoogleLinkState();
}

class _GoogleLinkState extends State<GoogleLink> {
  String userToken = '';
  var json = '';
  int link = 0;
  String userEmail = "";
  final GlobalKey progressDialogKey = GlobalKey<State>();
   static final facebookAppEvents = FacebookAppEvents();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.all(3),
          child: GestureDetector(
            onTap: () async {
                signInWithGoogle(context: context);   
            },
            child: Container(
              width: 200,
              height: 40,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 65, 133, 244),
              ),
              child:Padding(
                padding: const EdgeInsets.all(1),
                child: Row(children: [
                  Container(
                    height:40,
                    color:Colors.white,
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: 'http://pngimg.com/uploads/google/google_PNG19635.png',
                      height: 20,
                      fit: BoxFit.cover),
                  ),
                  const SizedBox(width:15),
                   Text(widget.title!,
                  style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
                ],),
              ) 
            ),
          ),
        );
  }

 Future<User?> signInWithGoogle({required BuildContext context}) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  ProgressDialog.show(context, progressDialogKey);

  try {
    if (Platform.isIOS) {
      final GoogleSignIn googleSignIn = GoogleSignIn(clientId: DefaultFirebaseOptions.currentPlatform.iosClientId);
      final GoogleSignInAccount? googleSignInAccount =await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential =await auth.signInWithCredential(credential);
        userEmail = userCredential.user!.email!;
        GoogleLinks user = GoogleLinks(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          emailVerified: userCredential.user!.emailVerified.toString(),
          displayName: userCredential.user!.displayName,
          isAnonymous: userCredential.user!.isAnonymous.toString(),
          photoURL: userCredential.user!.photoURL,
        );
        json = jsonEncode(user.toJson());
        submitChange(context, json);
        facebookAppEvents.logEvent(
          name: 'user_login_google',
          parameters: {'button_id': 'google_login_button',},
        );
      }
    } else if (Platform.isAndroid) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential =await auth.signInWithCredential(credential);
        userEmail = userCredential.user!.email!;
        GoogleLinks user = GoogleLinks(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          emailVerified: userCredential.user!.emailVerified.toString(),
          displayName: userCredential.user!.displayName,
          isAnonymous: userCredential.user!.isAnonymous.toString(),
          photoURL: userCredential.user!.photoURL,
        );
        json = jsonEncode(user.toJson());
        submitChange(context, json);
      }
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'account-exists-with-different-credential') {
      Toast.show(context, "danger", "Account already exists");
    } else if (e.code == 'invalid-credential') {
      Toast.show(context, "danger", "Invalid");
    }
  } catch (e) {
    print(e);
    Toast.show(context, "danger", e.toString());
  } finally {
    ProgressDialog.hide(progressDialogKey);
  }

  return user;
}


  Future<void> submitChange(BuildContext context, String cred) async {
    final webService = WebService(context);
      var result = await webService.authenticateGoogle(cred, userEmail);
      if ((result != null) && result) {
        return;
      }
  
  }
}
