import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shopping_item.dart';

class ShoppingCartView extends StatefulWidget {
  final List<ShoppingItem> cart;
  final Function onUpdate;
  final String sortMode;
  final Function(String) onSortChanged;
  const ShoppingCartView({super.key, required this.cart, required this.onUpdate, required this.sortMode, required this.onSortChanged});

  @override
  State<ShoppingCartView> createState() => _ShoppingCartViewState();
}

class _ShoppingCartViewState extends State<ShoppingCartView> {
  final _pC = TextEditingController();
  final _dC = TextEditingController();
  double _tax = 0.0;

  void _setDiscount(double val) {
    HapticFeedback.selectionClick();
    setState(() => _dC.text = val.toInt().toString());
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.cart.fold(0, (sum, item) => sum + item.finalPrice);

    return Column(children: [
      CupertinoListSection.insetGrouped(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        children: [
          _iosInputRow("価格", _pC, "￥", context),
          _iosInputRow("割引", _dC, "%", context),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quickBtn("10%", 10), _quickBtn("20%", 20), _quickBtn("30%", 30), _quickBtn("半額", 50),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(children: [
          SizedBox(width: double.infinity, child: CupertinoSlidingSegmentedControl<double>(
            groupValue: _tax,
            children: {
              0.0: _tabTxt("内税", context),
              0.08: _tabTxt("8%", context),
              0.1: _tabTxt("10%", context)
            },
            onValueChanged: (v) { HapticFeedback.selectionClick(); setState(() => _tax = v ?? 0.0); },
          )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: CupertinoButton.filled(
            borderRadius: BorderRadius.circular(12),
            onPressed: () {
              if (_pC.text.isEmpty) return;
              HapticFeedback.heavyImpact();
              setState(() {
                widget.cart.add(ShoppingItem(id: DateTime.now().toString(), createdAt: DateTime.now(), price: double.parse(_pC.text), discount: double.tryParse(_dC.text) ?? 0, taxRate: _tax));
                _pC.clear(); _dC.clear(); FocusScope.of(context).unfocus();
              });
              widget.onUpdate();
            },
            child: const Text("カートに追加", style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.white)),
          )),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SizedBox(width: double.infinity, child: CupertinoSlidingSegmentedControl<String>(
          groupValue: widget.sortMode,
          children: {
            "time": _sortTab(CupertinoIcons.clock, "新着順", context),
            "price": _sortTab(CupertinoIcons.sort_down, "価格順", context)
          },
          onValueChanged: (v) { if(v != null) widget.onSortChanged(v); },
        )),
      ),
      Expanded(child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.cart.length,
        itemBuilder: (context, i) {
          final item = widget.cart[i];
          return Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: CupertinoColors.systemRed, child: const Icon(CupertinoIcons.delete, color: Colors.white)),
            onDismissed: (_) { setState(() => widget.cart.removeAt(i)); widget.onUpdate(); },
            child: _iosItemTile(item, context),
          );
        },
      )),
      _iosTotalBar(total, context),
    ]);
  }

  Widget _quickBtn(String label, double val) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero, minSize: 38,
        color: CupertinoColors.systemGrey5.resolveFrom(context),
        borderRadius: BorderRadius.circular(8),
        onPressed: () => _setDiscount(val),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CupertinoColors.label.resolveFrom(context))),
      ),
    ),
  );

  Widget _tabTxt(String t, BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(t, style: TextStyle(fontSize: 13, color: CupertinoColors.label.resolveFrom(context))));
  Widget _sortTab(IconData i, String l, BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 14, color: CupertinoColors.label.resolveFrom(context)), const SizedBox(width: 4), Text(l, style: TextStyle(fontSize: 12, color: CupertinoColors.label.resolveFrom(context)))]);

  Widget _iosInputRow(String label, TextEditingController controller, String suffix, BuildContext context) => CupertinoListTile(
    title: Text(label, style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
    trailing: SizedBox(
      width: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: CupertinoTextField(
            controller: controller, placeholder: "0", textAlign: TextAlign.right,
            style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 18),
            decoration: null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            onChanged: (v) { if (v.isNotEmpty) HapticFeedback.selectionClick(); setState(() {}); },
          )),
          const SizedBox(width: 4),
          Text(suffix, style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16)),
        ],
      ),
    ),
  );

  Widget _iosItemTile(ShoppingItem item, BuildContext context) {
    return Container(
      color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("￥${item.finalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue)),
          Text("${item.price.toInt()}円 (${item.discount.toInt()}%引 / 税${(item.taxRate*100).toInt()}%)", style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
        ])),
        Row(children: [
          CupertinoButton(padding: EdgeInsets.zero, onPressed: () { setState(() => item.quantity > 1 ? item.quantity-- : null); widget.onUpdate(); }, child: const Icon(CupertinoIcons.minus_circle, size: 28)),
          SizedBox(width: 35, child: Center(child: Text("${item.quantity}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
          CupertinoButton(padding: EdgeInsets.zero, onPressed: () { setState(() => item.quantity++); widget.onUpdate(); }, child: const Icon(CupertinoIcons.plus_circle, size: 28)),
        ])
      ]),
    );
  }

  Widget _iosTotalBar(double t, BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
    decoration: BoxDecoration(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      border: Border(top: BorderSide(color: CupertinoColors.separator.resolveFrom(context))),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("合計", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: CupertinoColors.label.resolveFrom(context))),
      Text("￥${t.toStringAsFixed(0)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue)),
    ]),
  );
}