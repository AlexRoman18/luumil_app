import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SideMenu extends StatefulWidget {


  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int navDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;


    return NavigationDrawer(

      selectedIndex: navDrawerIndex,
      onDestinationSelected: (int index){
        setState((){
          navDrawerIndex=index;
        });

        switch (index) {
          case 0:
          context.push('');
            break;
          case 1:
            context.push( '');
            break;
          case 2:
            context.push( '');
            break;
        }
      },
  
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(28, hasNotch ? 0 : 20, 16, 10),
          child: Text('Menú', style: TextStyle(fontWeight: FontWeight.bold)),
          
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.announcement_outlined),
          label: Text('Tutorial'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.search_outlined),
          label: Text('Selección de busqueda'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          label: Text('Carrito de compra'),
        ),
      ],
    );
  }
}
