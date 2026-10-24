import 'package:flutter/material.dart';
import '../all.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool arrow;
  const PrimaryButton(this.label, {super.key, this.onTap, this.arrow = false});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
          onPressed: onTap,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (arrow) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.arrow_forward, size: 18)),
          ]),
        ),
      );
}

class Box extends StatelessWidget {
  final Widget child;
  final Color color;
  final bool selected;
  final EdgeInsets padding;
  const Box({super.key, required this.child, this.color = Colors.white, this.selected = false,
      this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? kPrimary : Colors.transparent, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
        ),
        child: child,
      );
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconBadge(this.icon, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(.18), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      );
}

const kTitle = TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText);
