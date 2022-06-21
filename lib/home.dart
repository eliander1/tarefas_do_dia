import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });

    _lerArquivo();
  }

  Widget criarItemLista(context, index) {
    //final item = _listaTarefas[index]["titulo"];
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        //recuperar o ultimo item excluido
        _ultimaTarefaRemovida = _listaTarefas[index];

        //remove o item da lista
        _listaTarefas.removeAt(index);
        _salvarArquivo();

        //snackbar
        final snackbar = SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Tarefa removida"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _listaTarefas.insert(index, _ultimaTarefaRemovida);
              });
              _salvarArquivo();
            },
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ]),
      ),
      child: CheckboxListTile(
          title: Text(_listaTarefas[index]['titulo']),
          value: _listaTarefas[index]['realizada'],
          onChanged: (valorAlterado) {
            setState(() {
              _listaTarefas[index]['realizada'] = valorAlterado;
            });
            _salvarArquivo();
          }),
    );

    //  return ListTile(title: Text(_listaTarefas[index]['titulo']));
  }

  @override
  Widget build(BuildContext context) {
    //_salvarArquivo();
    //print("itens: " + DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      appBar: AppBar(
          title: Text("Lista de tarefas"), backgroundColor: Colors.purple),

      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: _listaTarefas.length,
            itemBuilder: criarItemLista,
          ),
        ),
      ]),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 7,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {},
                  ),
                  actions: [
                    ElevatedButton(
                      child: Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                        child: Text("Salvar"),
                        onPressed: () {
                          _salvarTarefa();
                          Navigator.pop(context);
                        })
                  ],
                );
              });
        },
      ),
      //bottomNavigationBar: BottomNavigationBar(items: [null],),
    );
  }
}
