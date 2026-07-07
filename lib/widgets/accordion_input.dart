import 'package:flutter/material.dart';
import '../theme.dart';

class AccordionInput extends StatefulWidget {
  final Function(String text, bool remember) onProcess;
  final VoidCallback? onClear;
  final String initialText;
  final bool initialRemember;

  const AccordionInput({
    Key? key,
    required this.onProcess,
    this.onClear,
    this.initialText = '',
    this.initialRemember = false,
  }) : super(key: key);

  @override
  State<AccordionInput> createState() => _AccordionInputState();
}

class _AccordionInputState extends State<AccordionInput> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _chevronRotation;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  late TextEditingController _textController;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _remember = widget.initialRemember;
    _textController = TextEditingController(text: widget.initialText);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _chevronRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AccordionInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent updates the initial text or remember flag, reflect it in the controller.
    if (widget.initialText != oldWidget.initialText) {
      _textController.text = widget.initialText;
    }
    if (widget.initialRemember != oldWidget.initialRemember) {
      _remember = widget.initialRemember;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _clearSchedule() {
    setState(() {
      _textController.clear();
      _remember = false;
    });
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShuttleTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(ShuttleTheme.radiusLarge),
        border: Border.all(
          color: _isExpanded 
              ? ShuttleTheme.neonPink.withOpacity(0.8) 
              : ShuttleTheme.neonPink.withOpacity(0.2), 
          width: 1.2,
        ),
        boxShadow: _isExpanded ? [
          BoxShadow(
            color: ShuttleTheme.neonPink.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 1,
          )
        ] : [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Accordion Header button
          InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ShuttleTheme.md,
                vertical: ShuttleTheme.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.content_paste_outlined,
                        color: ShuttleTheme.neonPink,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Paste Schedule',
                        style: ShuttleTheme.headlineSm.copyWith(
                          color: ShuttleTheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RotationTransition(
                    turns: _chevronRotation,
                    child: const Icon(
                      Icons.expand_more,
                      color: ShuttleTheme.neonTeal,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Collapsible Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: 1.0,
            child: Container(
              padding: const EdgeInsets.only(
                left: ShuttleTheme.md,
                right: ShuttleTheme.md,
                bottom: ShuttleTheme.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // Text Area Input
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    style: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.onBackground),
                    decoration: InputDecoration(
                      hintText: 'Paste your raw schedule here...',
                      hintStyle: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.onSurfaceVariant.withOpacity(0.5)),
                      filled: true,
                      fillColor: ShuttleTheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.all(ShuttleTheme.md),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
                        borderSide: BorderSide(color: ShuttleTheme.neonPink.withOpacity(0.2), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
                        borderSide: const BorderSide(color: ShuttleTheme.neonTeal, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: ShuttleTheme.md),
                  
                  // Remember Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _remember,
                              activeColor: ShuttleTheme.neonPink,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ShuttleTheme.radiusSmall),
                              ),
                              side: BorderSide(color: ShuttleTheme.neonPink.withOpacity(0.5), width: 1.5),
                              onChanged: (val) {
                                setState(() {
                                  _remember = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _remember = !_remember;
                              });
                            },
                            child: Text(
                              'Save',
                              style: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _clearSchedule,
                        icon: const Icon(
                          Icons.delete_sweep_outlined,
                          color: ShuttleTheme.neonTeal,
                          size: 18,
                        ),
                        label: Text(
                          'Clear',
                          style: ShuttleTheme.bodySm.copyWith(
                            color: ShuttleTheme.neonTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ShuttleTheme.md),
                  
                  // Process Schedule Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: ShuttleTheme.neonPink.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ShuttleTheme.neonPink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
                        ),
                      ),
                      onPressed: () {
                        widget.onProcess(_textController.text, _remember);
                        _toggleExpanded(); // Auto collapse on process
                      },
                      child: Text(
                        'PROCESS SCHEDULE',
                        style: ShuttleTheme.bodyMd.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
