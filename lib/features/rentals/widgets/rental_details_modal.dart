import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/item_model.dart';
import '../../../models/rental_model.dart';
import '../providers/rental_provider.dart';

class RentalDetailsModal extends StatelessWidget {
  final RentalModel rental;
  final ItemModel? item;
  final bool isFr;

  const RentalDetailsModal({
    super.key,
    required this.rental,
    required this.item,
    required this.isFr,
  });

  static void show(BuildContext context, {
    required RentalModel rental,
    required ItemModel? item,
    required bool isFr,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RentalDetailsModal(
        rental: rental,
        item: item,
        isFr: isFr,
      ),
    );
  }

  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.confirmed:
        return const Color(0xFF10B981);
      case RentalStatus.pending:
        return const Color(0xFFF59E0B);
      case RentalStatus.completed:
        return const Color(0xFF2563EB);
      case RentalStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  String _getStatusLabel(RentalStatus status) {
    if (isFr) {
      switch (status) {
        case RentalStatus.confirmed:
          return 'En cours / Confirmée';
        case RentalStatus.pending:
          return 'En attente de validation';
        case RentalStatus.completed:
          return 'Location terminée';
        case RentalStatus.cancelled:
          return 'Annulée';
      }
    } else {
      switch (status) {
        case RentalStatus.confirmed:
          return 'Active / Confirmed';
        case RentalStatus.pending:
          return 'Pending Approval';
        case RentalStatus.completed:
          return 'Completed';
        case RentalStatus.cancelled:
          return 'Cancelled';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = isFr ? '€' : '\$';
    final dateFormat = DateFormat('dd MMM yyyy', isFr ? 'fr_FR' : 'en_US');
    final itemName = item?.name ?? (isFr ? 'Location #${rental.id}' : 'Rental #${rental.id}');
    final statusColor = _getStatusColor(rental.status);
    final statusLabel = _getStatusLabel(rental.status);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFr ? 'Détails de la réservation' : 'Rental Booking Details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: #${rental.id.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Item summary card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: (item?.imageUrl != null && item!.imageUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(item!.imageUrl, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.construction, color: Color(0xFF2563EB), size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.verified, size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text(
                              isFr ? 'Propriétaire vérifié' : 'Verified Partner',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, color: statusColor, size: 10),
                  const SizedBox(width: 8),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Detailed Info Rows
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: isFr ? 'Date de début' : 'Start Date',
              value: dateFormat.format(rental.startDate),
            ),
            _buildDetailRow(
              icon: Icons.event_available_outlined,
              label: isFr ? 'Date de restitution' : 'Return Date',
              value: dateFormat.format(rental.endDate),
            ),
            _buildDetailRow(
              icon: Icons.access_time_outlined,
              label: isFr ? 'Durée totale' : 'Total Duration',
              value: isFr ? '${rental.duration} jours' : '${rental.duration} days',
            ),
            _buildDetailRow(
              icon: Icons.receipt_long_outlined,
              label: isFr ? 'Montant payé' : 'Total Amount Paid',
              value: '${rental.totalPrice.toStringAsFixed(2)} $currency',
              isHighlight: true,
            ),
            _buildDetailRow(
              icon: Icons.security_outlined,
              label: isFr ? 'Statut de la caution' : 'Security Deposit',
              value: isFr ? 'Bloquée (restituée au retour)' : 'Held (released upon return)',
            ),

            const SizedBox(height: 20),

            // Action buttons according to status
            if (rental.status == RentalStatus.confirmed) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFr
                                ? 'Demande de prolongation envoyée au propriétaire'
                                : 'Rental extension request sent to owner'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: Text(isFr ? 'Prolonger' : 'Extend'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final provider = context.read<RentalProvider>();
                        provider.updateRentalStatus(rental.id, RentalStatus.completed);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFr
                                ? 'Restitution confirmée ! Merci d\'avoir utilisé RentIt.'
                                : 'Return confirmed! Thank you for using RentIt.'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: Text(isFr ? 'Restituer' : 'Return Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (rental.status == RentalStatus.pending) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final provider = context.read<RentalProvider>();
                    provider.updateRentalStatus(rental.id, RentalStatus.cancelled);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isFr ? 'Réservation annulée.' : 'Booking cancelled.'),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444)),
                  label: Text(
                    isFr ? 'Annuler la demande de location' : 'Cancel Rental Request',
                    style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    backgroundColor: const Color(0xFFFFF5F5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isFr ? 'Reçu téléchargé avec succès !' : 'Receipt downloaded successfully!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: Text(isFr ? 'Télécharger la facture' : 'Download Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
              color: isHighlight ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
