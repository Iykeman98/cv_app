import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CVData()),
      ],
      child: MyApp(),
    ),
  );
}

class CVData extends ChangeNotifier {
  String fullName = 'Ugwuagu Lawrence';
  String slackUsername = 'lawrence98';
  String githubHandle = "https://github.com/Iykeman98";
  String bio = 'Flutter Developer';
  File? profileImage;

  void updateData(String name, String slack, String github, String bio, File? image) {
    fullName = name;
    slackUsername = slack;
    githubHandle = github;
    this.bio = bio;
    profileImage = image;
    notifyListeners();
  }

  void updateProfileImage(File image) {
    profileImage = image;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CVScreen(),
        '/edit': (context) => EditCVScreen(),
      },
    );
  }
}

class CVScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My CV'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Row(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage("assets/profile2.jpeg"),
                ),SizedBox(width: 10),
                Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 40),
            CVInfoContainer('Full Name', context.watch<CVData>().fullName),
            CVInfoContainer('Slack Username', context.watch<CVData>().slackUsername),
            CVInfoContainer('GitHub Handle', context.watch<CVData>().githubHandle),
            CVInfoContainer('Bio', context.watch<CVData>().bio),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit');
              },
              child: Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditCVScreen extends StatefulWidget {
  @override
  _EditCVScreenState createState() => _EditCVScreenState();
}

class _EditCVScreenState extends State<EditCVScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController slackUsernameController = TextEditingController();
  TextEditingController githubHandleController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cvData = context.read<CVData>();
    fullNameController.text = cvData.fullName;
    slackUsernameController.text = cvData.slackUsername;
    githubHandleController.text = cvData.githubHandle;
    bioController.text = cvData.bio;
  }

  Future<void> _pickImage() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image, // You can specify the file type
    );
    if (pickedFile != null) {
      setState(() {
        final cvData = context.read<CVData>();
        cvData.updateProfileImage(File(pickedFile.files.single.path!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvData = context.watch<CVData>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit CV'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Circular Avatar Image (Clickable)
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Call the method to open the file picker
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.transparent,
                  backgroundImage: cvData.profileImage != null
                      ? Image.memory(cvData.profileImage!.readAsBytesSync()).image
                        :AssetImage("assets/profile2.jpeg"),
                ),
              ),

            ),
            SizedBox(height: 10),
            Text(
              'Edit Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            CVEditContainer('Full Name', fullNameController),
            CVEditContainer('Slack Username', slackUsernameController),
            CVEditContainer('GitHub Handle', githubHandleController),
            CVEditContainer('Bio', bioController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final cvData = context.read<CVData>();
                cvData.updateData(
                  fullNameController.text,
                  slackUsernameController.text,
                  githubHandleController.text,
                  bioController.text,
                  cvData.profileImage,
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class CVInfoContainer extends StatelessWidget {
  final String label;
  final String content;

  CVInfoContainer(this.label, this.content);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(content),
        ],
      ),
    );
  }
}

class CVEditContainer extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  CVEditContainer(this.label, this.controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          TextField(
            controller: controller, style: TextStyle(),
          ),
        ],
      ),
    );
  }
}
