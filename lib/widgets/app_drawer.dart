import 'package:flutter/material.dart';
import 'package:mobile/viewModels/auth_viewmodel.dart';
import 'package:mobile/viewModels/theme_viewmodel.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    bool isDarkMode =
        themeViewModel.themeMode == ThemeMode.dark ||
        (themeViewModel.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child:
                      authViewModel.profileImageUrl != null &&
                              authViewModel.profileImageUrl!.isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              authViewModel.profileImageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                );
                              },
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppColors.primaryColor,
                                );
                              },
                            ),
                          )
                          : const Icon(
                            Icons.person,
                            size: 30,
                            color: AppColors.primaryColor,
                          ),
                ),
                const SizedBox(height: 12),
                Text(
                  authViewModel.isAuthenticated
                      ? (authViewModel.userName ?? 'Usuario')
                      : 'CrediTEC',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (authViewModel.isAuthenticated)
                  Text(
                    'Rol: Participante',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          //if (authViewModel.isAuthenticated)
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Actividades'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/actividades');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vista de Categorías próximamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Encargados'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vista de Encargados próximamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            value: isDarkMode,
            onChanged: (bool value) {
              themeViewModel.setThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          if (authViewModel.isAuthenticated)
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade700),
              title: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red.shade700),
              ),
              onTap: () async {
                await authViewModel.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Iniciar Sesión'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'CrediTEC',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.school,
                  size: 50,
                  color: AppColors.primaryColor,
                ),
                children: const [
                  Text('Sistema de Gestión de Créditos Complementarios'),
                  SizedBox(height: 8),
                  Text('Desarrollado por PlenumSoft'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
