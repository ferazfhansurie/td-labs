import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

typedef ItemBuilder = Widget Function(int index);

class ButtonGroup extends StatefulWidget {
  final int itemCount;
  final ItemBuilder itemBuilder;

  const ButtonGroup({Key? key, required this.itemCount, required this.itemBuilder}) :
        assert(itemCount >= 0), super(key: key);

  @override
  _ButtonGroupState createState() => _ButtonGroupState();
}

class _ButtonGroupState extends State<ButtonGroup> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildItems(),
    );
  }

  List<Widget> _buildItems() {
    List<Widget> itemList = List.generate(widget.itemCount, (i) {
      final Widget item = widget.itemBuilder(i);
      return item;
    });

    return itemList;
  }
}


class ButtonGroupItem extends StatefulWidget {
  final String label;
  final bool active;
  final bool disabled;
  final VoidCallback? onPressed;

  const ButtonGroupItem({Key? key, required this.label, required this.active, required this.disabled, this.onPressed}) : super(key: key);

  @override
  _ButtonGroupItemState createState() => _ButtonGroupItemState();
}

class _ButtonGroupItemState extends State<ButtonGroupItem> {
  @override
  Widget build(BuildContext context) {
    VoidCallback _onPressed = widget.onPressed ?? (){};
    Color? _textColor = (widget.active) ? CupertinoTheme.of(context).primaryContrastingColor : CupertinoTheme.of(context).textTheme.textStyle.color;
    Color _backgroundColor = (widget.active) ? CupertinoTheme.of(context).primaryColor : CupertinoColors.white;
    if (widget.disabled) {
      _textColor = CupertinoColors.systemGrey2;
      _backgroundColor = CupertinoColors.systemGrey6;
    }

    return GestureDetector(
      onTap: (widget.disabled) ? null : () {
        _onPressed();
        SystemSound.play(SystemSoundType.click);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: CupertinoColors.separator, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        child: Text(widget.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: _textColor,fontWeight: FontWeight.w300)),
      ),
    );
  }
}
