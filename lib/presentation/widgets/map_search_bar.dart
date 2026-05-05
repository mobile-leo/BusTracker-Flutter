import 'package:flutter/material.dart';

class MapSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const MapSearchBar({super.key, required this.onChanged});

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildMenuButton(),
          const SizedBox(width: 8),
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 8),
          _buildNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.menu, color: Colors.white, size: 20),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar linha ou destino',
          hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 14),
          prefixIcon:
              const Icon(Icons.search, color: Color(0xFF666666), size: 20),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                child: const Icon(Icons.close,
                    color: Color(0xFF666666), size: 18),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.notifications_outlined,
          color: Colors.white, size: 20),
    );
  }
}
