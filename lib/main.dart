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
      // Este título não aparece automaticamente em todos os lugares,
      // mas faz parte da configuração geral do aplicativo.
      title: 'MineStart',

      // Tema visual básico do app.
      // Aqui estamos usando uma paleta gerada a partir de uma cor base.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // A "home" é a primeira tela carregada pelo aplicativo.
      home: const MyHomePage(title: 'MineStart'),
    );
  }
}

// ============================================================================
// TELA PRINCIPAL
// ============================================================================

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ============================================================================
// ESTADO DA TELA PRINCIPAL
// ============================================================================

class _MyHomePageState extends State<MyHomePage> {
  // Variável simples apenas para manter a ideia do contador do projeto padrão.
 
  void mudarPagina(int index) {
  pgController.animateToPage(
    index,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );

  setState(() {
    indexDoBottomNavBar = index;
  });
}
  // Esta variável guarda QUAL ITEM do BottomNavigationBar está selecionado.
  //
  // Exemplo:
  // 0 = Home
  // 1 = Foguete
  // 2 = Email
  //
  // Esta variável é essencial para que a barra inferior saiba
  // qual item deve aparecer como ativo/selecionado.
  int indexDoBottomNavBar = 0;

  // Aqui temos uma lista com os widgets que podem aparecer no body.
  //
  // Observem uma ideia muito importante:
  // o body não precisa ser sempre um único widget fixo.
  // Podemos trocar o conteúdo exibido dinamicamente.
  //
  // Neste exemplo, cada posição da lista representa uma "página" do app.
  //
  // Posição 0 -> BodyDaHomeImagem
  // Posição 1 -> BodyDoFoguete
  // Posição 2 -> BodyDoEmail
  final List<Widget> listaDeBodies = const [
    BodyDaHomeImagem(),
    BodyDoTreinamentos(),
    BodyDoSobre(),
    BodyDoCadastro(),
    BodyDoLogin(),
  ];

  // O PageController é o "controlador" do PageView.
  //
  // Guardem esta ideia:
  // assim como alguns widgets possuem objetos que os controlam,
  // o PageView pode ser controlado por este PageController.
  //
  // Com ele, conseguimos:
  // - mandar o PageView ir para uma página específica;
  // - animar a troca de páginas;
  // - sincronizar a mudança feita pelo clique no BottomNavigationBar.
  final PageController pgController = PageController();

  // Método apenas para incrementar o contador.
  // Ele não é o foco da aula de hoje, mas foi mantido para aproveitar
  // a estrutura do código base.
  

  @override
  void dispose() {
    // Comentário importante de boas práticas:
    //
    // Sempre que usamos controllers, animation controllers, text controllers,
    // page controllers e outros objetos parecidos, precisamos liberar
    // esses recursos quando o widget deixa de existir.
    //
    // Isso evita desperdício de memória e problemas de comportamento.
    pgController.dispose();

    // Chamamos o dispose da classe pai ao final.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O Scaffold é a "estrutura base" da tela Material.
      // Ele já oferece espaços prontos para:
      // - appBar
      // - body
      // - drawer
      // - floatingActionButton
      // - bottomNavigationBar
      //
      // Em outras palavras:
      // quando usamos MaterialApp e Scaffold, começamos a construir
      // a tela de um jeito muito mais organizado dentro do padrão Material.

     appBar: AppBar(
  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  title: Image.asset('assets/images/logo.png',
    height: 40,
  ),
  centerTitle: true,
),

      // ----------------------------------------------------------------------
      // BODY COM PAGEVIEW
      // ----------------------------------------------------------------------
      //
      // Aqui está a parte mais importante da lógica.
      //
      // O PageView é um widget que permite trocar páginas horizontalmente.
      // Ele já traz naturalmente o gesto de arrastar o dedo para o lado.
      //
      // Então, quando o usuário desliza o dedo horizontalmente,
      // o PageView muda de página com aquele efeito lateral.
      //
      // E quando o usuário toca no BottomNavigationBar,
      // nós usamos o PageController para mandar o PageView
      // ir para a página correspondente.
      //
      // Resultado:
      // - toque na barra inferior -> muda com animação lateral
      // - arrasto com o dedo -> também muda com animação lateral
      //
      // Isso é exatamente o comportamento que normalmente queremos
      // ao combinar BottomNavigationBar com navegação por páginas.
      body: PageView(
        controller: pgController,

        // "children" são as páginas do PageView.
        //
        // Cada item da lista vira uma página horizontal.
        // Neste caso, reaproveitamos a lista de bodies definida acima.
        children: listaDeBodies,

        // onPageChanged é disparado quando a página muda.
        //
        // Isso acontece, por exemplo, quando o usuário arrasta o dedo
        // para o lado e o PageView vai para outra página.
        //
        // Aqui fazemos a sincronização com o BottomNavigationBar:
        // se a página mudou, o item selecionado da barra também deve mudar.
        onPageChanged: (value) {
          setState(() {
            indexDoBottomNavBar = value;
          });
        },
      ),


      // ----------------------------------------------------------------------
      // BOTTOM NAVIGATION BAR
      // ----------------------------------------------------------------------
      //
      // O BottomNavigationBar é uma barra inferior de navegação.
      // Ele é muito usado quando o app possui áreas principais,
      // por exemplo:
      // - Início
      // - Busca
      // - Favoritos
      // - Perfil
      //
      // Neste exemplo, usamos 3 áreas:
      // - Home
      // - Foguete
      // - Email
      //
      // Conceito importante:
      // cada item da barra tem uma posição.
      //
      // Posição 0 -> Home
      // Posição 1 -> Foguete
      // Posição 2 -> Email
      //
      // Quando o usuário toca em um item, recebemos o índice clicado.
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex informa ao BottomNavigationBar
        // qual item está selecionado neste momento.
        //
        // Sem isso, a barra até aparece,
        // mas não saberia qual item destacar corretamente.
        currentIndex: indexDoBottomNavBar,

        // Sobre 3 itens e 4 itens:
        //
        // Quando temos 3 itens, normalmente o comportamento visual já é
        // bem simples e costuma funcionar bem sem ajustes adicionais.
        //
        // Quando temos 4 ou mais itens, é bastante comum usar:
        // type: BottomNavigationBarType.fixed
        //
        // Isso ajuda a manter todos os itens visíveis de forma estável.
        //
        // Como aqui temos 3 itens, podemos deixar sem o "type"
        // ou definir fixed mesmo assim, se quisermos padronizar o comportamento.
        //
        // Experimente depois descomentar a linha abaixo:
        // type: BottomNavigationBarType.fixed,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.white,

        items: const [
          BottomNavigationBarItem(
            
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            // Dependendo da versão do Flutter/material,
            // Icons.rocket pode não existir.
            // Icons.rocket_launch é mais comum e seguro.
            icon: Icon(Icons.rocket_launch),
            label: "Treinamentos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Sobre",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: "Cadastro",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Login",
          ),

          // Caso você queira testar 4 itens futuramente,
          // bastaria adicionar mais um item aqui
          // E também mais uma página no PageView.
          //
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: "Perfil",
          // ),
        ],

       onTap: (indexClicado) => mudarPagina(indexClicado),
      ),
    );
    
  }
}

// ============================================================================
// PRIMEIRO BODY
// ============================================================================

class BodyDaHomeImagem extends StatelessWidget {
  const BodyDaHomeImagem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Home",
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

// ============================================================================
// SEGUNDO BODY
// ============================================================================

class BodyDoTreinamentos extends StatelessWidget {
  const BodyDoTreinamentos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Text(
          "Treinamentos",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

// ============================================================================
// TERCEIRO BODY
// ============================================================================

class BodyDoSobre extends StatelessWidget {
  const BodyDoSobre({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Text(
          "Sobre",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

class BodyDoCadastro extends StatelessWidget {
  const BodyDoCadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Text(
          "Cadastro",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

class BodyDoLogin extends StatelessWidget {
  const BodyDoLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: Text(
          "Login",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

// ============================================================================
// BODY ALTERNATIVO COM CONTADOR
// ============================================================================
//
// Esta classe foi mantida porque ela já existia na sua ideia original.
// Ela serve como exemplo de um body que recebe dado por parâmetro.
// Neste caso, recebe o valor do contador.
//
class BodyDaHomePage extends StatelessWidget {
  const BodyDaHomePage({
    super.key,
    required int counter,
  }) : _counter = counter;

  final int _counter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // mainAxisAlignment.center centraliza os filhos no eixo principal.
        //
        // Como Column organiza elementos na vertical,
        // o eixo principal dela é vertical.
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have pushed the button this many times:'),

          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}