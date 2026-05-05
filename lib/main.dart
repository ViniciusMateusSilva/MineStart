import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class MongoDBService {
  static mongo.Db? _db;
  static mongo.DbCollection? _collection;

  // Conecta ao banco ProjetoIntegrador e à coleção Usuarios
  static Future<void> connect() async {
    try {
      _db = await mongo.Db.create(
        "mongodb+srv://viniciusmateussilva3_db_user:UNISO2026@aws-sp.mnehrew.mongodb.net/ProjetoIntegrador",
      );
      await _db!.open();

      _collection = _db!.collection("Usuarios");
      debugPrint("Conectado ao MongoDB!");
    } catch (e) {
      debugPrint("Erro ao conectar: $e");
    }
  }

  static Future<void> inserirUsuario(String nome, String email, String senha) async {
    if (_collection == null) {
      throw Exception("Coleção não inicializada. Verifique a conexão.");
    }

    await _collection!.insertOne({
      "nome": nome,
      "email": email,
      "senha": senha,
      "dataCadastro": DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> buscarUsuario(String email) async {
    if (_collection == null) {
      throw Exception("Coleção não inicializada. Verifique a conexão.");
    }

    return await _collection!.findOne(mongo.where.eq("email", email));
  }

  static Future<void> fecharConexao() async {
    await _db?.close();
  }
}

// ============================================================================
// MAIN
// ============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDBService.connect(); // abre a conexão ANTES do app
  runApp(const MyApp());
}

// ============================================================================
// APP PRINCIPAL
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
// HOME PAGE COM NAVEGAÇÃO
// ============================================================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool usuarioLogado = false;
  int indexDoBottomNavBar = 0;
  final PageController pgController = PageController();

  void mudarPagina(int index) {
    if (index == 5 && !usuarioLogado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faça login para acessar o perfil")),
      );
      return;
    }
    pgController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
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
        title: const Text("MineStart"),
        centerTitle: true,
      ),
      body: PageView(
        controller: pgController,
        children: [
          const BodyDaHomeImagem(),
          const BodyDoTreinamentos(),
          const BodyDoSobre(),
          const BodyDoCadastro(),
          BodyDoLogin(onLoginSuccess: () {
            setState(() {
              usuarioLogado = true;
            });
            mudarPagina(5);
          }),
          const BodyDoPerfil(),
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
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "Login"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}

// ============================================================================
// TELAS
// ============================================================================
class BodyDaHomeImagem extends StatelessWidget {
  const BodyDaHomeImagem({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Home", style: TextStyle(fontSize: 30)));
}

class BodyDoTreinamentos extends StatelessWidget {
  const BodyDoTreinamentos({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Treinamentos", style: TextStyle(fontSize: 30)));
}

class BodyDoSobre extends StatelessWidget {
  const BodyDoSobre({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Sobre", style: TextStyle(fontSize: 30)));
}

// ============================================================================
// CADASTRO
// ============================================================================
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
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (MongoDBService._collection == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro: conexão com banco não inicializada")),
          );
          return;
        }

        final nome = nomeController.text.trim();
        final email = emailController.text.trim();
        final senha = senhaController.text.trim();

        if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Preencha todos os campos")),
          );
          return;
        }

        await MongoDBService.inserirUsuario(nome, email, senha);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário salvo no MongoDB!")),
        );

        nomeController.clear();
        emailController.clear();
        senhaController.clear();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Cadastro",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? "Digite seu nome" : null,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || !v.contains("@") ? "Email inválido" : null,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: senhaController,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (v) => v == null || v.length < 6
                  ? "A senha deve ter pelo menos 6 caracteres"
                  : null,
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: _cadastrar,
              child: const Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LOGIN
// ============================================================================
class BodyDoLogin extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const BodyDoLogin({super.key, required this.onLoginSuccess});

  @override
  State<BodyDoLogin> createState() => _BodyDoLoginState();
}

class _BodyDoLoginState extends State<BodyDoLogin> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (formKey.currentState!.validate()) {
      try {
        if (MongoDBService._collection == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro: conexão com banco não inicializada")),
          );
          return;
        }

        final usuario = await MongoDBService.buscarUsuario(emailController.text.trim());
        if (usuario != null && senhaController.text.trim() == usuario["senha"]) {
          widget.onLoginSuccess();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login realizado com sucesso!")),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email ou senha inválidos")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao fazer login: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (v) => v == null || !v.contains("@") ? "Email inválido" : null,
            ),
            TextFormField(
              controller: senhaController,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
              validator: (v) => v == null || v.length < 6 ? "Senha inválida" : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Entrar")),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PERFIL
// ============================================================================
class BodyDoPerfil extends StatelessWidget {
  const BodyDoPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Bem-vindo ao seu perfil!",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
