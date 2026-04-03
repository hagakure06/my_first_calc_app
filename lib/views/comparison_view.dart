import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});
  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  final _p1 = TextEditingController(); final _v1 = TextEditingController(); double _t1 = 0.0;
  final _p2 = TextEditingController(); final _v2 = TextEditingController(); double _t2 = 0.0;

  double _calcUnit(TextEditingController p, TextEditingController v, double t) {
    double pr = double.tryParse(p.text) ?? 0; double vol = double.tryParse(v.text) ?? 0;
    return vol <= 0 ? 0 : (pr * (1 + t)) / vol;
  }

  @override
  Widget build(BuildContext context) {
    double u1 = _calcUnit(_p1, _v1, _t1); double u2 = _calcUnit(_p2, _v2, _t2);
    bool w1 = u1 > 0 && (u1 < u2 || u2 == 0); bool w2 = u2 > 0 && (u2 < u1 || u1 == 0);
    String msg = "";
    if (u1 > 0 && u2 > 0) {
      double diff = (u1 - u2).abs() * 100;
      msg = "100単位あたり ￥${diff.toStringAsFixed(1)} おトク";
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          _compCard("商品 A", _p1, _v1, _t1, (v) => setState(() => _t1 = v), u1, w1, context, w1 ? msg : ""),
          const Icon(CupertinoIcons.arrow_up_arrow_down, color: CupertinoColors.systemGrey, size: 20),
          _compCard("商品 B", _p2, _v2, _t2, (v) => setState(() => _t2 = v), u2, w2, context, w2 ? msg : ""),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _compCard(String title, TextEditingController p, TextEditingController v, double tax, Function(double) onT, double unit, bool win, BuildContext context, String msg) => Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(12), border: win ? Border.all(color: CupertinoColors.activeBlue, width: 2) : null,
    ),
    child: Column(children: [
      CupertinoListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.label.resolveFrom(context))),
        trailing: win ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: CupertinoColors.activeBlue, borderRadius: BorderRadius.circular(4)), child: const Text("おトク", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))) : null,
      ),
      _inputRow("価格", p, "￥", context), _inputRow("容量", v, "単位", context),
      Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 16), child: SizedBox(width: double.infinity, child: CupertinoSlidingSegmentedControl<double>(
        groupValue: tax,
        children: {
          0.0: Text("内税", style: TextStyle(fontSize: 12, color: CupertinoColors.label.resolveFrom(context))),
          0.08: Text("8%", style: TextStyle(fontSize: 12, color: CupertinoColors.label.resolveFrom(context))),
          0.1: Text("10%", style: TextStyle(fontSize: 12, color: CupertinoColors.label.resolveFrom(context)))
        },
        onValueChanged: (v) { HapticFeedback.selectionClick(); onT(v ?? 0.0); },
      ))),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: win ? CupertinoColors.activeBlue.withOpacity(0.1) : CupertinoColors.quaternarySystemFill.resolveFrom(context), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (msg.isNotEmpty) Text(msg, style: const TextStyle(fontSize: 13, color: CupertinoColors.activeBlue, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text("100単位あたり", style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
          Text(unit > 0 ? "￥${(unit * 100).toStringAsFixed(1)}" : "---", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: win ? CupertinoColors.activeBlue : CupertinoColors.label.resolveFrom(context))),
        ]),
      ),
    ]),
  );

  Widget _inputRow(String l, TextEditingController c, String s, BuildContext context) => CupertinoListTile(
    title: Text(l, style: TextStyle(fontSize: 16, color: CupertinoColors.label.resolveFrom(context))),
    trailing: SizedBox(
      width: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: CupertinoTextField(
            controller: c, textAlign: TextAlign.right, placeholder: "0",
            style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 18),
            decoration: null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            onChanged: (_)=>setState(() {}),
          )),
          const SizedBox(width: 4),
          Text(s, style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 16)),
        ],
      ),
    ),
  );
}