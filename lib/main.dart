import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================================
// CLASSE PRINCIPAL DO APLICATIVO
// ============================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineStart',
      home: const MyHomePage(title: 'MineStart'),
    );
  }
}

// ============================================================================
// TELA PRINCIPAL
// ============================================================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ============================================================================
// ESTADO DA TELA PRINCIPAL
// ============================================================================
class _MyHomePageState extends State<MyHomePage> {
  bool usuarioLogado = false;
  int indexDoBottomNavBar = 0;
  final PageController pgController = PageController();

  void mudarPagina(int index) {
    // Bloqueia acesso ao Perfil sem login
    if (index == 5 && !usuarioLogado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faça login para acessar o perfil")),
      );
      return;
    }

    pgController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    setState(() {
      indexDoBottomNavBar = index;
    });
  }

  @override
  void dispose() {
    pgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 4),
          child: Image.asset('assets/images/logo.png', height: 80),
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: pgController,
        children: const [
          BodyDaHomeImagem(),
          BodyDoTreinamentos(),
          BodyDoSobre(),
          BodyDoCadastro(),
          BodyDoLogin(),
          BodyDoPerfil(),
        ],
        onPageChanged: (value) {
          setState(() {
            indexDoBottomNavBar = value;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexDoBottomNavBar,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        onTap: (indexClicado) => mudarPagina(indexClicado),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.rocket_launch), label: "Treinamentos"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Sobre"),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: "Cadastro"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Login"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}

// ============================================================================
// BODIES
// ============================================================================
class BodyDaHomeImagem extends StatelessWidget {
  const BodyDaHomeImagem({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Home", style: TextStyle(fontSize: 30)));
}

class BodyDoTreinamentos extends StatelessWidget {
  const BodyDoTreinamentos({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Treinamentos", style: TextStyle(fontSize: 30)));
}

class BodyDoSobre extends StatelessWidget {
  const BodyDoSobre({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Sobre", style: TextStyle(fontSize: 30)));
}

class BodyDoCadastro extends StatefulWidget {
  const BodyDoCadastro({super.key});
  @override
  State<BodyDoCadastro> createState() => _BodyDoCadastroState();
}

class _BodyDoCadastroState extends State<BodyDoCadastro> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Cadastro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome", border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? "Digite seu nome" : null),
          const SizedBox(height: 15),
          TextFormField(controller: emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains("@") ? "Email inválido" : null),
          const SizedBox(height: 15),
          TextFormField(controller: senhaController, decoration: const InputDecoration(labelText: "Senha", border: OutlineInputBorder()), obscureText: true, validator: (v) => v == null || v.length < 6 ? "A senha deve ter pelo menos 6 caracteres" : null),
          const SizedBox(height: 25),
          ElevatedButton(onPressed: () {
            if (_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cadastro realizado!")));
            }
          }, child: const Text("Cadastrar")),
        ]),
      ),
    );
  }
}

class BodyDoLogin extends StatefulWidget {
  const BodyDoLogin({super.key});
  @override
  State<BodyDoLogin> createState() => _BodyDoLoginState();
}

class _BodyDoLoginState extends State<BodyDoLogin> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      final homeState = context.findAncestorStateOfType<_MyHomePageState>();
      if (homeState != null) {
        homeState.setState(() {
          homeState.usuarioLogado = true;
        });
        homeState.mudarPagina(5);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login realizado com sucesso!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextFormField(controller: emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()), validator: (v) => v == null || !v.contains("@") ? "Email inválido" : null),
          const SizedBox(height: 15),
          TextFormField(controller: senhaController, decoration: const InputDecoration(labelText: "Senha", border: OutlineInputBorder()), obscureText: true, validator: (v) => v == null || v.isEmpty ? "Digite sua senha" : null),
          const SizedBox(height: 25),
          ElevatedButton(onPressed: _login, child: const Text("Entrar")),
        ]),
      ),
    );
  }
}

class BodyDoPerfil extends StatelessWidget {
  const BodyDoPerfil({super.key});
  @override
  Widget build(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_MyHomePageState>();
    if (homeState == null || !homeState.usuarioLogado) {
      return const Center(child: Text("Você precisa fazer login para acessar o perfil.", style: TextStyle(fontSize: 20, color: Colors.red)));
    }
    return const Center(child: Text("Bem-vindo ao seu perfil!", style: TextStyle(fontSize: 24)));
  }
}
