import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'driver_profile_page.dart'; // Import the driver profile page

void main() {
  runApp(SidebarXExampleApp());
}

class SidebarXExampleApp extends StatelessWidget {
  SidebarXExampleApp({Key? key}) : super(key: key);

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SidebarX Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: isSmallScreen
                ? AppBar(
                    backgroundColor: canvasColor,
                    title: Text(_getTitleByIndex(_controller.selectedIndex)),
                    leading: IconButton(
                      onPressed: () {
                        _key.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  )
                : null,
            drawer: ExampleSidebarX(controller: _controller),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller),
                Expanded(
                  child: Center(
                    child: _ScreensExample(
                      controller: _controller,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/avatar.png'),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Homepage',
          onTap: () {
            debugPrint('Homepage');
            _controller.selectIndex(0);
          },
        ),
        SidebarXItem(
          icon: Icons.person,
          label: 'Driver Profile',
          onTap: () {
            debugPrint('Driver Profile');
            _controller.selectIndex(1);
          },
        ),
        SidebarXItem(
          icon: Icons.directions_car,
          label: 'Trips',
          onTap: () {
            debugPrint('Trips');
            _controller.selectIndex(2);
          },
        ),
        SidebarXItem(
          icon: Icons.payment,
          label: 'Payments',
          onTap: () {
            debugPrint('Payments');
            _controller.selectIndex(3);
          },
        ),
        SidebarXItem(
          icon: Icons.notifications,
          label: 'Notifications',
          onTap: () {
            debugPrint('Notifications');
            _controller.selectIndex(4);
          },
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            debugPrint('Settings');
            _controller.selectIndex(5);
          },
        ),
        SidebarXItem(
          icon: Icons.help,
          label: 'Help and Support',
          onTap: () {
            debugPrint('Help and Support');
            _controller.selectIndex(6);
          },
        ),
        SidebarXItem(
          icon: Icons.info,
          label: 'App Info',
          onTap: () {
            debugPrint('App Info');
            _controller.selectIndex(7);
          },
        ),
        SidebarXItem(
          icon: Icons.logout,
          label: 'Logout',
          onTap: () {
            debugPrint('Logout');
            _controller.selectIndex(8);
          },
        ),
      ],
    );
  }
}

class _ScreensExample extends StatelessWidget {
  const _ScreensExample({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pageTitle = _getTitleByIndex(controller.selectedIndex);
        switch (controller.selectedIndex) {
          case 0:
            return Center(
                child: Text(pageTitle, style: theme.textTheme.headlineSmall));
          case 1:
            return DriverProfilePage(); // Add your driver profile page here
          case 2:
            return Center(
                child: Text(pageTitle, style: theme.textTheme.headlineSmall));
          case 3:
            return Center(
                child: Text(pageTitle, style: theme.textTheme.headlineSmall));
          case 4:
            return Center(
                child: Text(pageTitle, style: theme.textTheme.headlineSmall));
          case 5:
            return Center(
                child: Text(pageTitle, style: theme.textTheme.headlineSmall));
          case 6:
            return Center(
                child: Text(pageTitle, style: theme.textTheme.headlineSmall));
          case 7:
            return Center(
                child: Text(pageTitle, style: theme.textTheme.headlineSmall));
          case 8:
            return Center(
                child: Text(pageTitle, style: theme.textTheme.headlineSmall));
          default:
            return Center(
                child: Text('Page not found',
                    style: theme.textTheme.headlineSmall));
        }
      },
    );
  }
}

String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Homepage';
    case 1:
      return 'Driver Profile';
    case 2:
      return 'Trips';
    case 3:
      return 'Payments';
    case 4:
      return 'Notifications';
    case 5:
      return 'Settings';
    case 6:
      return 'Help and Support';
    case 7:
      return 'App Info';
    case 8:
      return 'Logout';
    default:
      return 'Not found page';
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);
