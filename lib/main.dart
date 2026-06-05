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
void mostrarPopupContato(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Entre em contato"),
        content: const Text(
          "Para solicitar uma demonstração ou iniciar um treinamento, "
          "entre em contato com nossa equipe:\n\n"
          "📧 Email: contato@minestart.com\n"
          "📞 Telefone: (11) 99999-9999",
          textAlign: TextAlign.start,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      );
    },
  );
}

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
    BodyDaHomeImagem(
      onVerTreinamentos: () {
        mudarPagina(1); // índice da página de Treinamentos
      },
    ),
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
  final VoidCallback onVerTreinamentos;

  const BodyDaHomeImagem({super.key, required this.onVerTreinamentos});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _heroSection(),
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
          _cardCTA(context),
        ],
      ),
    );
  }

 Widget _heroSection() {
    return Padding(
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
          ElevatedButton(
            onPressed: onVerTreinamentos, // leva para Treinamentos
            child: const Text("👉 Ver treinamentos"),
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

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

  Widget _cardCTA(BuildContext context) {
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
          ElevatedButton(
            onPressed: () {
              mostrarPopupContato(context); // agora funciona
            },
            child: const Text("👉 Solicite uma demonstração"),
          ),
        ],
      ),
    ),
  );
}

}


class BodyDoTreinamentos extends StatelessWidget {
  const BodyDoTreinamentos({super.key});

  final treinamentos = const [
    {
      "titulo": "NR1 – Disposições Gerais",
      "descricao": "Responsabilidades básicas de empresa e funcionários.",
      "duracao": "2h",
      "nivel": "Básico",
      "objetivos": "A Norma Regulamentadora nº 1 estabelece os princípios gerais de segurança e saúde no trabalho, definindo responsabilidades tanto da empresa quanto dos trabalhadores. Esse treinamento aborda as obrigações legais da organização em garantir um ambiente seguro e dos funcionários em cumprir as normas de segurança, criando uma base para todas as demais NRs."
    },
    {
      "titulo": "NR35 – Trabalho em Altura",
      "descricao": "Segurança e práticas para atividades acima de 2 metros.",
      "duracao": "3h",
      "nivel": "Intermediário",
      "objetivos": "A NR35 trata das medidas de proteção para atividades realizadas acima de 2 metros do nível inferior, onde haja risco de queda. Breve resumo: O treinamento ensina técnicas seguras para trabalhos em altura, uso correto de equipamentos, análise de risco e procedimentos de emergência, garantindo a integridade física dos trabalhadores."
    },
    {
      "titulo": "NR6 – Equipamentos de Proteção Individual (EPI)",
      "descricao": "Uso correto e importância dos EPIs no trabalho.",
      "duracao": "4h",
      "nivel": "Avançado",
      "objetivos": "A NR6 regulamenta o fornecimento, uso e manutenção dos Equipamentos de Proteção Individual. Breve resumo: O treinamento explica a importância dos EPIs, como utilizá-los corretamente e a responsabilidade da empresa em fornecê-los e do trabalhador em usá-los, reduzindo riscos ocupacionais."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: treinamentos.length,
      itemBuilder: (context, index) {
        final t = treinamentos[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.school, color: Colors.blue),
            title: Text(t["titulo"]!),
            subtitle: Text(t["descricao"]!),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalhesTreinamento(
                    titulo: t["titulo"]!,
                    descricao: t["descricao"]!,
                    duracao: t["duracao"]!,
                    nivel: t["nivel"]!,
                    objetivos: t["objetivos"]!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class DetalhesTreinamento extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String duracao;
  final String nivel;
  final String objetivos;

  const DetalhesTreinamento({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.duracao,
    required this.nivel,
    required this.objetivos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(descricao),
            const SizedBox(height: 20),
            Text("📌 Objetivos: $objetivos"),
            const SizedBox(height: 10),
            Text("⏳ Duração: $duracao"),
            const SizedBox(height: 10),
            Text("🎯 Nível: $nivel"),
            const Spacer(),
            ElevatedButton(
  onPressed: () {
    mostrarPopupContato(context);
  },
  child: const Text("Solicitar demonstração"),
),

          ],
        ),
      ),
    );
  }
}




class BodyDoSobre extends StatelessWidget {
  const BodyDoSobre({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("📌 Sobre o MineStart"),
              _sectionText(
                "O MineStart é uma plataforma digital desenvolvida para oferecer "
                "treinamentos industriais imersivos e capacitação profissional de forma prática, "
                "acessível e envolvente. Utilizando o ambiente do Minecraft como simulação, "
                "a solução conecta teoria e prática, permitindo que empresas e usuários individuais "
                "treinem em cenários reais de forma gamificada."
              ),

              _sectionTitle("🎯 Missão"),
              _sectionText(
                "Facilitar o acesso à capacitação profissional, promovendo o desenvolvimento de "
                "competências e apoiando empresas na gestão de treinamentos internos."
              ),

              _sectionTitle("⚙️ Diferenciais"),
              _bulletList([
                "Treinamentos gamificados que aumentam engajamento e retenção.",
                "Simulações realistas de processos industriais e segurança do trabalho.",
                "Interface intuitiva e fácil de usar.",
                "Escalabilidade: treine várias equipes ao mesmo tempo, em qualquer lugar.",
                "Impacto social alinhado aos ODS 4 (Educação de Qualidade) e ODS 8 (Trabalho Decente e Crescimento Econômico).",
              ]),

              _sectionTitle("👥 Público-Alvo"),
              _bulletList([
                "Empresas que buscam padronizar e melhorar treinamentos internos.",
                "Profissionais em busca de capacitação.",
                "Estudantes que desejam complementar sua formação.",
                "Pessoas em processo de inserção ou recolocação no mercado de trabalho.",
              ]),

              _sectionTitle("📊 Impacto esperado"),
              _sectionText(
                "Colaboradores mais preparados, redução de erros operacionais e maior eficiência nos processos, "
                "além de contribuir para a democratização do acesso à educação e ao desenvolvimento profissional."
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets auxiliares
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 16)),
            Expanded(child: Text(item, style: const TextStyle(fontSize: 16))),
          ],
        ),
      )).toList(),
    );
  }
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