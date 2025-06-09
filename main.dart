import 'package:flutter/material.dart';
import 'database_helper.dart';

void main()
{
  runApp(MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class LoginPage extends StatefulWidget
{
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  final _formKey = GlobalKey<FormState>();
  String mobile = '';
  String password = '';

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
      (
      appBar: AppBar(title: Text("Login"), centerTitle: true),
      body: Padding
        (
        padding: EdgeInsets.all(16),
        child: Form
          (
          key: _formKey,
          child: Column
            (
            children:
            [
              TextFormField
                (
                decoration: InputDecoration(labelText: "Mobile"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? "Enter mobile number" : null,
                onChanged: (value) => mobile = value,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? "Enter password" : null,
                onChanged: (value) => password = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Login"),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var user = await DatabaseHelper.instance
                        .getUserByMobileAndPassword(mobile, password);
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UserDetailPage(user: user)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid credentials")),
                      );
                    }
                  }
                },
              ),
              TextButton(
                child: Text("Don't have an account? Sign Up"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SignUpPage()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String firstName = '';
  String lastName = '';
  String password = '';
  String mobile = '';
  String degree = '';
  String gender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField("First Name", (v) => firstName = v),
              buildTextField("Last Name", (v) => lastName = v),
              buildTextField("Password", (v) => password = v, isPassword: true),
              buildTextField("Mobile", (v) => mobile = v,
                  keyboardType: TextInputType.phone),
              buildTextField("Degree", (v) => degree = v),
              SizedBox(height: 10),
              Text("Gender", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<String>(
                    value: "Male",
                    groupValue: gender,
                    onChanged: (value) => setState(() => gender = value!),
                  ),
                  Text("Male"),
                  Radio<String>(
                    value: "Female",
                    groupValue: gender,
                    onChanged: (value) => setState(() => gender = value!),
                  ),
                  Text("Female"),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Map<String, dynamic> userData = {
                      'firstName': firstName,
                      'lastName': lastName,
                      'password': password,
                      'mobile': mobile,
                      'degree': degree,
                      'gender': gender,
                    };
                    await DatabaseHelper.instance.insertUser(userData);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("User saved to database"),
                    ));
                    Navigator.pop(context); // Back to Login
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, Function(String) onChanged,
      {bool isPassword = false,
        TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
        value == null || value.isEmpty ? 'Enter $label' : null,
        onChanged: onChanged,
      ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Details")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("First Name: ${user['firstName']}"),
            Text("Last Name: ${user['lastName']}"),
            Text("Mobile: ${user['mobile']}"),
            Text("Degree: ${user['degree']}"),
            Text("Gender: ${user['gender']}"),
          ],
        ),
      ),
    );
  }
}
