import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text('Nombre del Usuario'),
            accountEmail: Text('correo@dominio.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.indigo),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Actividades'),
            onTap: () {
              // Aquí puedes implementar la navegación a la pantalla de Actividades
              Navigator.pop(context); // cerrar drawer
              Navigator.pushNamed(context, '/actividades');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () {
              // Aquí puedes implementar la navegación a la pantalla de Categorías
              Navigator.pushNamed(context, '/categorias');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Encargados'),
            onTap: () {
              // Aquí puedes implementar la navegación a la pantalla de Encargados
              Navigator.pushNamed(context, '/encargados');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuraciones'),
            onTap: () {
              // Agregar navegación a configuraciones
            },
          ),
        ],
      ),
    );
  }
}
