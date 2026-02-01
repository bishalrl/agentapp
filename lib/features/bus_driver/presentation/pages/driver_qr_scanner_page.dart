import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';

class DriverQRScannerPage extends StatefulWidget {
  final String busId;
  final String? expectedTicketNumber;
  final String? passengerSeat;

  const DriverQRScannerPage({
    super.key,
    required this.busId,
    this.expectedTicketNumber,
    this.passengerSeat,
  });

  @override
  State<DriverQRScannerPage> createState() => _DriverQRScannerPageState();
}

class _DriverQRScannerPageState extends State<DriverQRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  String? _scannedCode;
  bool _isVerified = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScan(BarcodeCapture capture) {
    if (_isVerifying || _isVerified) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _scannedCode = barcode.rawValue;
      _isVerifying = true;
    });

    // Stop scanning
    _controller.stop();

    // Verify ticket
    _verifyTicket(barcode.rawValue!);
  }

  Future<void> _verifyTicket(String scannedCode) async {
    // Call backend API to verify ticket
    final seatNumber = widget.passengerSeat != null 
        ? int.tryParse(widget.passengerSeat!) 
        : null;
    
    context.read<DriverBloc>().add(
      VerifyTicketEvent(
        qrCode: scannedCode,
        busId: widget.busId,
        seatNumber: seatNumber,
      ),
    );
  }

  void _resetScan() {
    setState(() {
      _scannedCode = null;
      _isVerified = false;
      _isVerifying = false;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverBloc, DriverState>(
      listener: (context, state) {
        if (state.ticketVerificationResult != null) {
          final result = state.ticketVerificationResult!;
          final success = result['success'] == true;
          final alreadyVerified = result['alreadyVerified'] == true;
          final message = result['message'] as String? ?? '';
          
          setState(() {
            _isVerified = success;
            _isVerifying = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        }
        if (state.errorMessage != null && _isVerifying) {
          setState(() {
            _isVerified = false;
            _isVerifying = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ticket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Scanner View
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onScan,
                ),
                // Overlay with scanning area
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: CustomPaint(
                    painter: _ScannerOverlayPainter(),
                  ),
                ),
                // Instructions
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: EnhancedCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              'Position QR code within the frame',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Result Section
          if (_scannedCode != null)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: EnhancedCard(
                child: Column(
                  children: [
                    if (_isVerifying)
                      const CircularProgressIndicator()
                    else if (_isVerified)
                      BlocBuilder<DriverBloc, DriverState>(
                        builder: (context, state) {
                          final result = state.ticketVerificationResult;
                          final booking = result?['booking'] ?? result?['data']?['booking'];
                          
                          return Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green,
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              Text(
                                result?['alreadyVerified'] == true
                                    ? 'Ticket Already Verified'
                                    : 'Ticket Verified',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Text('Code: $_scannedCode'),
                              if (booking != null) ...[
                                const SizedBox(height: AppTheme.spacingS),
                                Text('Passenger: ${booking['passengerName'] ?? 'N/A'}'),
                                Text('Seat: ${booking['seatNumber'] ?? widget.passengerSeat ?? 'N/A'}'),
                                if (booking['ticketNumber'] != null)
                                  Text('Ticket: ${booking['ticketNumber']}'),
                              ] else if (widget.passengerSeat != null) ...[
                                Text('Seat: ${widget.passengerSeat}'),
                              ],
                            ],
                          );
                        },
                      )
                    else
                      Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Verification Failed',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text('Scanned: $_scannedCode'),
                          if (widget.expectedTicketNumber != null)
                            Text(
                                'Expected: ${widget.expectedTicketNumber}'),
                        ],
                      ),
                    const SizedBox(height: AppTheme.spacingM),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _resetScan,
                        child: const Text('Scan Another'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: EnhancedCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Scanning...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Point camera at QR code',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create scanning area (center square)
    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;

    final scanArea = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            scanAreaLeft,
            scanAreaTop,
            scanAreaSize,
            scanAreaSize,
          ),
          const Radius.circular(12),
        ),
      );

    final cutout = Path.combine(
      PathOperation.difference,
      path,
      scanArea,
    );

    canvas.drawPath(cutout, paint);

    // Draw border around scanning area
    final borderPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanAreaLeft,
          scanAreaTop,
          scanAreaSize,
          scanAreaSize,
        ),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Draw corner indicators
    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Top-left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      Offset(scanAreaLeft, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerLength,
          scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize,
          scanAreaTop + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
