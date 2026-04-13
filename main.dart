import 'package:flutter/material.dart';

void main() {
  runApp(MineStartApp());
}

class MineStartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineStart',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // número de abas
      child: Scaffold(
        appBar: AppBar(
          title: Text('MineStart'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Treinamentos'),
              Tab(text: 'Sobre'),
              Tab(text: 'Cadastro'),
              Tab(text: 'Login'),
              Tab(text: 'Perfil'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PagInicial(),
            TreinamentosPage(),
            SobrePage(),
            CadastroPage(),
            LoginPage(),
            PerfilPage(),
          ],
        ),
      ),
    );
  }
}


class PagInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner inicial
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(16),
              color: Colors.blueAccent,
              child: Column(
                children: [
                  Text(
                    'Treinamento Industrial Gamificado Mais Realista e Customizável',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Navegar para Cursos
                    },
                    child: Text('Ver Cursos'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Destaques
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Treinamentos em Destaque',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  courseCard('Treinamento em Altura', '20h'),
                  courseCard('Manuseio de Substâncias Quimicas', '15h'),
                  courseCard('Ferramentas Manuais', '10h'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Benefícios
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  benefitItem(Icons.school, 'Treinamentos padronizados'),
                  benefitItem(Icons.access_time, 'Acesso prático e rápido'),
                  benefitItem(Icons.verified, 'Certificados digitais'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // CTA
            
          ],
        ),
      ),
    );
  }

  Widget courseCard(String title, String hours) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Carga horária: $hours'),
            SizedBox(height: 8),
            ElevatedButton(onPressed: () {}, child: Text('Inscreva-se')),
          ],
        ),
      ),
    );
  }

  Widget benefitItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(text),
    );
  }
}



class TreinamentosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Treinamentos Disponíveis'));
  }
}

class SobrePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Pagina Sobre'));
  }
}
class CadastroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Pagina de Cadastro'));
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Pagina de Login'));
  }
}
class PerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Meu Perfil'));
  }
}

