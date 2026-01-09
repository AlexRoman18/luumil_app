import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:luumil_app/config/theme/gemini/app_theme.dart';

class CustomBottomInput extends StatefulWidget {
  final Function(types.PartialText) onSend;

  const CustomBottomInput({super.key, required this.onSend});

  @override
  State<CustomBottomInput> createState() => _CustomBottomInputState();
}

class _CustomBottomInputState extends State<CustomBottomInput> {
  String text = '';
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void onTextChanged(String value) {
      setState(() {
        text = value;
      });
    }

    void onSend() {
      if (text.isEmpty) return;
      final partialText = types.PartialText(text: text);

      widget.onSend(partialText);
      setState(() {
        text = '';
        controller.clear();
      });
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 5, top: 10),
      decoration: const BoxDecoration(color: seedColor),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 👇 Caja de texto con ancho máximo
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 325),
              child: _TextInput(
                onTextChanged: onTextChanged,
                controller: controller,
              ),
            ),
            IconButton(
              onPressed: text.isEmpty ? null : onSend,
              icon: Icon(
                Icons.send,
                color: text.isEmpty ? Colors.grey : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final Function(String) onTextChanged;
  final TextEditingController controller;

  const _TextInput({required this.onTextChanged, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onTextChanged,
      maxLines: 1, // 👈 compacto, no se expande verticalmente
      minLines: 1,
      decoration: InputDecoration(
        hintText: 'Escribe un mensaje...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.primaryContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
