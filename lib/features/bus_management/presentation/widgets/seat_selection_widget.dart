import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Production-ready bus seat selection widget with realistic bus layout
/// Shows seats in A/B pattern: Left side (A1, A2, A3...) and Right side (B1, B2, B3...)
class SeatSelectionWidget extends StatefulWidget {
  final int totalSeats;
  final List<String>? seatConfiguration; // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
  final List<String> selectedSeats;
  final Function(List<String>) onSeatsChanged;
  final List<String>? bookedSeats; // Already booked seats
  final List<String>? lockedSeats; // Locked seats

  const SeatSelectionWidget({
    super.key,
    required this.totalSeats,
    this.seatConfiguration,
    required this.selectedSeats,
    required this.onSeatsChanged,
    this.bookedSeats,
    this.lockedSeats,
  });

  @override
  State<SeatSelectionWidget> createState() => _SeatSelectionWidgetState();
}

class _SeatSelectionWidgetState extends State<SeatSelectionWidget> {
  late List<String> _availableSeats;
  late List<String> _selectedSeats;

  @override
  void initState() {
    super.initState();
    _initializeSeats();
    _selectedSeats = List.from(widget.selectedSeats);
  }

  void _initializeSeats() {
    if (widget.seatConfiguration != null && widget.seatConfiguration!.isNotEmpty) {
      // Use custom seat configuration
      _availableSeats = List.from(widget.seatConfiguration!);
    } else {
      // Auto-generate A/B pattern based on total seats
      _availableSeats = _generateABPattern(widget.totalSeats);
    }
  }

  /// Generates A/B pattern: A1, A2, A3... on left, B1, B2, B3... on right
  List<String> _generateABPattern(int totalSeats) {
    final seats = <String>[];
    final seatsPerSide = (totalSeats / 2).ceil();
    
    // Generate left side (A seats)
    for (int i = 1; i <= seatsPerSide; i++) {
      seats.add('A$i');
    }
    
    // Generate right side (B seats)
    for (int i = 1; i <= seatsPerSide && seats.length < totalSeats; i++) {
      seats.add('B$i');
    }
    
    // If odd number, remove last seat to match total
    if (seats.length > totalSeats) {
      seats.removeLast();
    }
    
    return seats;
  }

  @override
  void didUpdateWidget(SeatSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalSeats != widget.totalSeats ||
        oldWidget.seatConfiguration != widget.seatConfiguration) {
      _initializeSeats();
    }
    if (oldWidget.selectedSeats != widget.selectedSeats) {
      _selectedSeats = List.from(widget.selectedSeats);
    }
  }

  void _toggleSeat(String seat) {
    // Don't allow selection of booked or locked seats
    if ((widget.bookedSeats?.contains(seat) ?? false) ||
        (widget.lockedSeats?.contains(seat) ?? false)) {
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
      } else {
        _selectedSeats.add(seat);
      }
      widget.onSeatsChanged(_selectedSeats);
    });
  }

  Color _getSeatColor(String seat) {
    // Booked seats - red
    if (widget.bookedSeats?.contains(seat) ?? false) {
      return Colors.red.shade400;
    }
    // Locked seats - orange
    if (widget.lockedSeats?.contains(seat) ?? false) {
      return Colors.orange.shade400;
    }
    // Selected seats - primary color
    if (_selectedSeats.contains(seat)) {
      return AppTheme.primaryColor;
    }
    // Available seats - green
    return Colors.green.shade400;
  }

  IconData _getSeatIcon(String seat) {
    if (widget.bookedSeats?.contains(seat) ?? false) {
      return Icons.event_busy;
    }
    if (widget.lockedSeats?.contains(seat) ?? false) {
      return Icons.lock;
    }
    if (_selectedSeats.contains(seat)) {
      return Icons.check_circle;
    }
    return Icons.event_seat;
  }

  /// Organizes seats into rows with left (A) and right (B) sides
  Map<String, List<String>> _organizeSeatsIntoRows() {
    final leftSeats = <String>[];
    final rightSeats = <String>[];
    
    for (final seat in _availableSeats) {
      if (seat.toUpperCase().startsWith('A')) {
        leftSeats.add(seat);
      } else if (seat.toUpperCase().startsWith('B')) {
        rightSeats.add(seat);
      } else {
        // If doesn't match A/B pattern, add to left by default
        leftSeats.add(seat);
      }
    }
    
    // Sort seats numerically
    leftSeats.sort((a, b) {
      final aNum = int.tryParse(a.replaceAll(RegExp(r'[A-Z]'), '')) ?? 0;
      final bNum = int.tryParse(b.replaceAll(RegExp(r'[A-Z]'), '')) ?? 0;
      return aNum.compareTo(bNum);
    });
    
    rightSeats.sort((a, b) {
      final aNum = int.tryParse(a.replaceAll(RegExp(r'[A-Z]'), '')) ?? 0;
      final bNum = int.tryParse(b.replaceAll(RegExp(r'[A-Z]'), '')) ?? 0;
      return aNum.compareTo(bNum);
    });
    
    return {
      'left': leftSeats,
      'right': rightSeats,
    };
  }

  @override
  Widget build(BuildContext context) {
    final organizedSeats = _organizeSeatsIntoRows();
    final leftSeats = organizedSeats['left']!;
    final rightSeats = organizedSeats['right']!;
    final maxRows = leftSeats.length > rightSeats.length ? leftSeats.length : rightSeats.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          _buildLegend(),
          const SizedBox(height: 20),
          // Bus Layout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Front/Driver indicator
                _buildFrontIndicator(),
                const SizedBox(height: 16),
                // Seat rows
                ...List.generate(maxRows, (rowIndex) {
                  final leftSeat = rowIndex < leftSeats.length ? leftSeats[rowIndex] : null;
                  final rightSeat = rowIndex < rightSeats.length ? rightSeats[rowIndex] : null;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side (A seats)
                        Expanded(
                          child: leftSeat != null
                              ? _buildSeatButton(leftSeat)
                              : const SizedBox(width: 60, height: 60),
                        ),
                        // Aisle
                        Container(
                          width: 40,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Container(
                              width: 2,
                              height: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        // Right side (B seats)
                        Expanded(
                          child: rightSeat != null
                              ? _buildSeatButton(rightSeat)
                              : const SizedBox(width: 60, height: 60),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                // Back indicator
                _buildBackIndicator(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Selection summary
          if (_selectedSeats.isNotEmpty) _buildSelectionSummary(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(Colors.green.shade400, 'Available'),
          _buildLegendItem(AppTheme.primaryColor, 'Selected'),
          _buildLegendItem(Colors.orange.shade400, 'Locked'),
          _buildLegendItem(Colors.red.shade400, 'Booked'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFrontIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.airline_seat_recline_normal_rounded,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            'Front / Driver',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.airline_seat_recline_normal_rounded,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            'Back',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatButton(String seat) {
    final isSelected = _selectedSeats.contains(seat);
    final isBooked = widget.bookedSeats?.contains(seat) ?? false;
    final isLocked = widget.lockedSeats?.contains(seat) ?? false;
    final isDisabled = isBooked || isLocked;

    return GestureDetector(
      onTap: isDisabled ? null : () => _toggleSeat(seat),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: _getSeatColor(seat),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    spreadRadius: 0.5,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSeatIcon(seat),
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              seat,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selected: ${_selectedSeats.join(", ")} (${_selectedSeats.length} seat${_selectedSeats.length > 1 ? "s" : ""})',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
