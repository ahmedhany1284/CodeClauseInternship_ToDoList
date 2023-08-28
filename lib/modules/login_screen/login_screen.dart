import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:to_do_list/layout/home_layout.dart';
import 'package:to_do_list/modules/register/register.dart';
import 'package:to_do_list/modules/register/reset_pasword.dart';
import 'package:to_do_list/shared/components/components.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;

  const SquareTile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(100),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: 30,
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _passwordTextController = TextEditingController();

  TextEditingController _emailTextController = TextEditingController();
  IconData icon = Icons.visibility;
  bool _notvisible = true;
  bool iconpres = false;

  void check_icon(iconpres) {
    if (iconpres != true) {
      icon = Icons.visibility;
      _notvisible = true;
    } else {
      icon = Icons.visibility_off;
      _notvisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 0, 83),
        title: Text(
          'Sign In',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/logoapp.png',
                        width: 100.0,
                        height: 100.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    TextFormField(
                      controller: _emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      onFieldSubmitted: (String value) {
                        print(value);
                      },
                      onChanged: (String value) {
                        print(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        prefixIcon: Icon(
                          color: Colors.white70,
                          Icons.email,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      controller: _passwordTextController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _notvisible,
                      onFieldSubmitted: (String value) {
                        print(value);
                      },
                      onChanged: (String value) {
                        print(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        prefixIcon: Icon(
                          color: Colors.white70,
                          Icons.lock,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            icon,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              iconpres = !iconpres;
                              check_icon(iconpres);
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    firebaseUIButton(context, "Sign In", () {
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
                        navigateTo(context, Homelayout());
                        showCustomToast('Logged in successfully');
                      }).onError((error, stackTrace) {
                        String e = error.toString();

                        showCustomToast(
                            e.replaceAll(RegExp(r'\[.*?\]'), '').trim());

                        print("Error ${error.toString()}");
                      });
                    }),
                    forgetPassword(context),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            print(_emailTextController.text);
                            print(_passwordTextController.text);
                            signInWithGoogle();
                          },
                          child: SquareTile(imagePath: 'assets/google.png'),
                        ),
                        MaterialButton(
                          onPressed: () {
                            print(_emailTextController.text);
                            print(_passwordTextController.text);
                            signInWithFacebook();
                            print('entered the on pressed');
                          },
                          child: SquareTile(imagePath: 'assets/Facebook.png'),
                        ),
                        MaterialButton(
                          onPressed: () {
                            print(_emailTextController.text);
                            print(_passwordTextController.text);
                            signInWithGitHub(context);
                          },
                          child: SquareTile(imagePath: 'assets/github.png'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            navigateTo(context, SignUpScreen());
                          },
                          child: Text(
                            'Register Now',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 2, 0, 83),
          hexStringToColor("aB2B93"),
          hexStringToColor("7546C4"),
          hexStringToColor("5E61F6"),
          Color.fromARGB(255, 2, 0, 83),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      ),
    );
  }

  signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user?.displayName);
  }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance
        .login(permissions: ['email', 'public_profile', 'user_birthday']);

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<UserCredential> signInWithGitHub(BuildContext context) async {
    final GitHubSignIn gitHubSignIn = GitHubSignIn(
      clientId: '5108688d92508173b91d',
      clientSecret: '05640cf9373cdab8fa7046cdd105fb430797460d',
      redirectUrl: 'https://to-do-list-97572.firebaseapp.com/__/auth/handler',
      title: 'GitHub Connection',
      centerTitle: false,
    );
    final result = await gitHubSignIn.signIn(context);

    final githubAuthCredentials = GithubAuthProvider.credential(result.token!);

    return await FirebaseAuth.instance
        .signInWithCredential(githubAuthCredentials);
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.left,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
}
