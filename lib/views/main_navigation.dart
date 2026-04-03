import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';
import 'shopping_cart_view.dart';
import 'comparison_view.dart';

class MainNavigation extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  const MainNavigation({super.key, required this.onThemeToggle, required this.isDark});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<ShoppingItem> _cart = [];
  String _sortMode = "time";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cart_data');
    if (data != null) {
      setState(() => _cart = (json.decode(data) as List).map((i) => ShoppingItem.fromJson(i)).toList());
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart_data', json.encode(_cart.map((i) => i.toJson()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    if (_sortMode == "time") {
      _cart.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      _cart.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
    }

    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: widget.isDark
            ? CupertinoColors.black.withOpacity(0.8)
            : CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.8),
        middle: Text(
          _selectedIndex == 0 ? "買い物リスト" : "どっちがお得？",
          style: TextStyle(color: CupertinoColors.label.resolveFrom(context)),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.onThemeToggle,
          child: Icon(widget.isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_stars_fill, size: 22),
        ),
      ),
      body: _selectedIndex == 0
          ? ShoppingCartView(cart: _cart, onUpdate: _saveData, sortMode: _sortMode, onSortChanged: (v) => setState(() => _sortMode = v))
          : const ComparisonView(),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _selectedIndex,
        onTap: (i) { HapticFeedback.selectionClick(); setState(() => _selectedIndex = i); },
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart_fill), label: 'リスト'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.arrow_2_squarepath), label: '比較'),
        ],
      ),
    );
  }
}