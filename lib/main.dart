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
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 4),
          child: Image.asset('lib/assets/images/logo.png', height: 80),
        ),
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _cardHero(),
          _cardSection("🚀 Sobre a plataforma",
              "Transformamos o aprendizado técnico em uma experiência prática dentro do jogo.\n\n"
              "Nossa plataforma utiliza o Minecraft como ambiente de simulação para treinar colaboradores em processos industriais, segurança do trabalho e operação de sistemas — tudo de forma gamificada e altamente envolvente."),
          _cardList("🎯 Benefícios", [
            {"title": "Mais engajamento", "desc": "Treinamentos interativos aumentam a retenção e o interesse."},
            {"title": "Aprendizado prático", "desc": "Simulações que colocam o usuário em situações reais."},
            {"title": "Redução de custos", "desc": "Menos gastos com treinamentos presenciais e riscos."},
            {"title": "Escalabilidade", "desc": "Treine várias equipes ao mesmo tempo, de qualquer lugar."},
          ]),
          _cardList("🏭 Como funciona", [
            {"title": "1. Escolha o treinamento", "desc": "Selecione entre diversos módulos industriais."},
            {"title": "2. Acesse o ambiente no Minecraft", "desc": "Entre em um mundo virtual com simulações."},
            {"title": "3. Aprenda na prática", "desc": "Realize tarefas, tome decisões e complete objetivos."},
            {"title": "4. Acompanhe os resultados", "desc": "A plataforma registra desempenho em tempo real."},
          ]),
          _cardList("⚙️ Diferenciais", [
            {"title": "Realismo", "desc": "Simulações mais realistas que plataformas tradicionais."},
            {"title": "Customização", "desc": "Adaptável para diferentes tipos de indústria."},
            {"title": "Integração", "desc": "Dashboards e relatórios conectados."},
            {"title": "Gamificação", "desc": "Experiência envolvente que aumenta desempenho."},
          ]),
          _cardList("🧠 Para quem é", [
            {"title": "Empresas industriais", "desc": ""},
            {"title": "Equipes operacionais", "desc": ""},
            {"title": "Segurança do trabalho", "desc": ""},
            {"title": "Instituições de ensino técnico", "desc": ""},
          ]),
          _cardSection("📊 Resultado esperado",
              "Colaboradores mais preparados, menos erros operacionais e maior eficiência nos processos."),
          _cardCTA(),
        ],
      ),
    );
  }

  // HERO CARD
  Widget _cardHero() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Treinamentos industriais imersivos dentro do Minecraft",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Capacite equipes de forma prática, interativa e escalável com simulações reais de ambiente industrial.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("👉 Ver treinamentos")),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () {}, child: const Text("👉 Solicitar demonstração")),
          ],
        ),
      ),
    );
  }

  // SECTION CARD
  Widget _cardSection(String titulo, String conteudo) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(conteudo, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // LIST CARD (benefícios, diferenciais, etc.)
  Widget _cardList(String titulo, List<Map<String, String>> itens) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...itens.map((item) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.blue),
                  title: Text(item["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: item["desc"]!.isNotEmpty ? Text(item["desc"]!) : null,
                )),
          ],
        ),
      ),
    );
  }

  // CTA FINAL
  Widget _cardCTA() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "🔥 Leve o treinamento da sua equipe para outro nível.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("👉 Solicite uma demonstração")),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () {}, child: const Text("👉 Comece agora")),
          ],
        ),
      ),
    );
  }
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
