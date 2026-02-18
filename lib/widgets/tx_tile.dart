import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';

class TxTile extends StatelessWidget {
  final TransactionItem tx;
  final String currency;
  final VoidCallback? onDelete;

  const TxTile({
    super.key,
    required this.tx,
    required this.currency,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.amount > 0;
    
    Widget content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.silver.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.burgundy.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(tx.category.icon, color: AppColors.burgundy, size: 20),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkGrey),
        ),
        subtitle: Text(
          '${tx.date.day}/${tx.date.month} • ${tx.category.label}',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}$currency ${tx.amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isIncome ? AppColors.success : AppColors.error,
            fontSize: 14,
          ),
        ),
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: ValueKey(tx.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (_) => onDelete!(),
        child: content,
      );
    }

    return content;
  }
}
