import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_up/data/controller/multiplayer_controller.dart';
import 'package:quiz_up/data/model/domanda.dart';
import 'package:quiz_up/pages/games/multiplayer/quiz_partita_privata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  _InviteFriendsScreenState createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final MultiplayerController _controller = MultiplayerController();
  final TextEditingController _codeController = TextEditingController();
  String? _generatedCode;
  bool _isCodeGenerated = false;
  String? errorMessage;
  late SharedPreferences _preferences;
  String? id;
  bool isJoin = false;
  bool _isJoining = false;
  StreamSubscription? _roomSubscription;

  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    _preferences = await SharedPreferences.getInstance();
    id = _preferences.getString('player_id');
  }

  void _copyCode() {
    if (_isCodeGenerated) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
    }
  }

  Future<void> _generateCode() async {
    setState(() {
      errorMessage = null;
    });

    String code = await _controller.createRoom(id!);
    _listenRoom(code);

    setState(() {
      _generatedCode = code;
      _isCodeGenerated = true;
    });

    // Avvia il timer di 30 secondi
    _startCooldown();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 30;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_cooldownSeconds > 1) {
          _cooldownSeconds--;
        } else {
          _cooldownSeconds = 0;
          timer.cancel();
        }
      });
    });
  }

  void _listenRoom(String code) {
    _roomSubscription = _controller.listenToRoom(code).listen((snapshot) {
      final data = snapshot.data();
      if (data != null && data['status'] == 'ready') {
        final questions = (data['questions'] as List)
            .map((e) => Domanda.fromMap(e))
            .toList();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPartitaPrivata(questions: questions, id: id!, code: _generatedCode!),
          ),
        );
      }
    });
  }

  Future<void> joinToRoom() async {
    setState(() {
      _isJoining = true;
    });
    print(id);
    print(_generatedCode);
    FocusManager.instance.primaryFocus?.unfocus();
    final code = _codeController.text.trim();
    if(code.isNotEmpty) {
      final questions = await _controller.joinRoom(code, id!);
      setState(() {
        isJoin = true;
        _isJoining = false;
        errorMessage =
        questions != null ? null : "Something went wrong, \n please enter a valid code.";
      });
      if (questions != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuizPartitaPrivata( questions: questions, id: id!, code: code)
          ),
        );
      }
    } else {
      setState(() {
        _isJoining = false;
        errorMessage = "Please, insert your code";
      });
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _roomSubscription?.cancel();
    if(_generatedCode != null) {
      _controller.cancelRoom(_generatedCode!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.06),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(width * 0.05),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xBD5CB8FF),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(width * 0.05),
                                      topRight: Radius.circular(width * 0.05),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: height * 0.015),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          CircleAvatar(
                                            radius: width * 0.08,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.person,
                                                size: width * 0.07, color: Colors.black),
                                          ),
                                          Text(
                                            "VS",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.045,
                                            ),
                                          ),
                                          CircleAvatar(
                                            radius: width * 0.08,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.person_outline,
                                                size: width * 0.07, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: height * 0.015),
                                      ClipPath(
                                        clipper: WaveClipper(),
                                        child: Container(
                                          height: height * 0.02,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height * 0.02),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                                  child: Text(
                                    "Invite a friend and see who knows more!\n Get your unique game code now!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.025),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.04, vertical: height * 0.01),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _isCodeGenerated ? _generatedCode! : '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * 0.045,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.025),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: (_cooldownSeconds > 0)
                                                  ? null
                                                  : _generateCode,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF5CB8FF),
                                            disabledBackgroundColor: const Color(0xFF5CB8FF),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(width * 0.1),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: height * 0.018),
                                          ),
                                          icon: Icon(Icons.vpn_key,
                                              size: width * 0.05, color: Colors.black),
                                          label: Text(
                                              _cooldownSeconds > 0
                                                  ? "Wait $_cooldownSeconds s"
                                                  : "Generate Code",
                                            style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width * 0.05),
                                      ElevatedButton(
                                        onPressed: _copyCode,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF5CB8FF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(width * 0.1),
                                          ),
                                          padding: EdgeInsets.all(height * 0.018),
                                        ),
                                        child: Icon(Icons.copy,
                                            size: width * 0.05, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height * 0.025),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                                  child: Text(
                                    "Invite a friend and see who knows more!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.025),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                                  child: Row(
                                  children: [
                                    Expanded(
                                    child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF0F0F0),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                        child: TextField(
                                          onTap: () {
                                            setState(() {
                                              if(errorMessage != null) {
                                                errorMessage = null;
                                              }
                                            });
                                          },
                                          controller: _codeController,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your code',
                                            filled: true,
                                            fillColor: const Color(0xFFF0F0F0),
                                            errorText: errorMessage,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: width * 0.04,
                                              vertical: height * 0.015,
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: errorMessage != null
                                                  ? const BorderSide(color: Colors.red)
                                                  : BorderSide.none,
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.05),
                                    ElevatedButton(
                                      onPressed: joinToRoom,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF5CB8FF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(width * 0.1),
                                        ),
                                        padding: EdgeInsets.all(height * 0.018),
                                      ),
                                      child:  _isJoining
                                          ? SizedBox(
                                        height: width * 0.05,
                                        width: width * 0.05,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                        ),
                                      ) :
                                      Icon(Icons.send_rounded,
                                          size: width * 0.05, color: Colors.black),
                                    ),
                                  ],
                                ),
                                ),
                                SizedBox(height: height * 0.025),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);

    double waveWidth = size.width / 10;
    double waveHeight = 25;

    for (double i = 0; i < size.width; i += waveWidth) {
      path.quadraticBezierTo(
        i + waveWidth / 4,
        waveHeight,
        i + waveWidth / 4,
        0,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
