import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// 資料模型
class PaymentItem {
  final String id;
  final double amount; // Paymentamt: 已繳金額
  final String name; // PaymentName: 期款名稱
  final String invoiceNumber; // PaymentInv: 發票編號
  final String invoiceDate; // Paymentdate: 發票日期
  final String randomCode; // Paymentrent: 發票隨機碼

  PaymentItem({
    required this.id,
    required this.amount,
    required this.name,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.randomCode,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'] ?? '',
      // 處理金額字串，移除可能存在的逗號
      amount: double.tryParse(
              json['Paymentamt']?.toString().replaceAll(',', '') ?? '0') ??
          0.0,
      name: json['PaymentName'] ?? '',
      invoiceNumber: json['PaymentInv'] ?? '',
      invoiceDate: json['Paymentdate'] ?? '-',
      randomCode: json['Paymentrent'] ?? '',
    );
  }

  // 判斷是否為退款或折讓 (金額為負)
  bool get isRefund => amount < 0;

  // 判斷是否有發票資訊
  bool get hasInvoice => invoiceNumber.isNotEmpty;

  // 取得分類群組
  String get groupName {
    if (name.isEmpty) return '其他';
    final firstChar = name.substring(0, 1);
    if (firstChar == '0') return '訂金與簽約';
    if (firstChar == '1') return '工程期款';
    if (firstChar == '2') return '交屋與貸款';
    if (['6', '7', '9', 'A'].contains(firstChar)) return '規費與找補';
    return '其他款項';
  }
}

class PaymentQueryPage extends StatefulWidget {
  const PaymentQueryPage({super.key});

  @override
  State<PaymentQueryPage> createState() => _PaymentQueryPageState();
}

class _PaymentQueryPageState extends State<PaymentQueryPage> {
  List<PaymentItem> _items = [];
  late Map<String, List<PaymentItem>> _groupedItems;
  double _totalPaid = 0;
  bool _isLoading = true;
  int? _sortColumnIndex;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final rawData =
          await userProvider.fetchPaymentHistory(forceRefresh: forceRefresh);
      if (!mounted) return;

      setState(() {
        _items = rawData.map((json) => PaymentItem.fromJson(json)).toList();
        _totalPaid = _items.fold(0, (sum, item) => sum + item.amount);

        _groupedItems = {};
        for (var item in _items) {
          if (!_groupedItems.containsKey(item.groupName)) {
            _groupedItems[item.groupName] = [];
          }
          _groupedItems[item.groupName]!.add(item);
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading payment data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSort<T>(Comparable<T> Function(PaymentItem item) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
      _items.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'zh_TW', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('繳款查詢')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // 寬度 > 800 視為 Web/Tablet 模式，使用 DataTable
                if (constraints.maxWidth > 800) {
                  return _buildWebView(currencyFormat);
                } else {
                  // 寬度較窄，使用 Mobile 列表模式
                  return _buildMobileView(currencyFormat);
                }
              },
            ),
    );
  }

  // --- Web 版介面 (DataTable) ---
  Widget _buildWebView(NumberFormat fmt) {
    return RefreshIndicator(
      onRefresh: () => _loadData(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 儀表板 (共用)
            _buildDashboard(fmt),
            const SizedBox(height: 24),

            // 表格區塊
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _isAscending,
                    headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                    columnSpacing: 24,
                    columns: [
                      DataColumn(
                          label: const Text('期款名稱',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onSort: (columnIndex, ascending) => _onSort(
                              (item) => item.name, columnIndex, ascending)),
                      DataColumn(
                          label: const Text('金額',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true,
                          onSort: (columnIndex, ascending) => _onSort(
                              (item) => item.amount, columnIndex, ascending)),
                      DataColumn(
                          label: const Text('發票號碼',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onSort: (columnIndex, ascending) => _onSort(
                              (item) => item.invoiceNumber,
                              columnIndex,
                              ascending)),
                      DataColumn(
                          label: const Text('隨機碼',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onSort: (columnIndex, ascending) => _onSort(
                              (item) => item.randomCode,
                              columnIndex,
                              ascending)),
                      DataColumn(
                          label: const Text('發票日期',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onSort: (columnIndex, ascending) => _onSort(
                              (item) => item.invoiceDate,
                              columnIndex,
                              ascending)),
                    ],
                    rows: _items.map((item) {
                      final amountColor =
                          item.isRefund ? Colors.green[700] : Colors.black87;
                      return DataRow(cells: [
                        DataCell(Text(item.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500))),
                        DataCell(Text(
                          fmt.format(item.amount),
                          style: TextStyle(
                              color: amountColor, fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(item.invoiceNumber.isEmpty
                            ? '-'
                            : item.invoiceNumber)),
                        DataCell(Text(
                            item.randomCode.isEmpty || item.randomCode == '-'
                                ? '--'
                                : item.randomCode)),
                        DataCell(Text(item.invoiceDate)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Mobile 版介面 (ListView + Card) ---
  Widget _buildMobileView(NumberFormat fmt) {
    return Column(
      children: [
        _buildDashboard(fmt),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadData(forceRefresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _groupedItems.keys.length,
              itemBuilder: (context, index) {
                String groupName = _groupedItems.keys.elementAt(index);
                List<PaymentItem> groupItems = _groupedItems[groupName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ),
                    ...groupItems.map((item) => _buildMobileCard(item, fmt)),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard(NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('累計已繳金額',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            fmt.format(_totalPaid),
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(PaymentItem item, NumberFormat fmt) {
    final amountColor = item.isRefund ? Colors.green[700] : Colors.black87;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  fmt.format(item.amount),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: amountColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 12),
            if (item.hasInvoice) ...[
              _buildInfoRow(Icons.receipt_long, '發票號碼', item.invoiceNumber),
              const SizedBox(height: 6),
              _buildInfoRow(
                  Icons.qr_code,
                  '隨機碼',
                  item.randomCode.isEmpty || item.randomCode == '-'
                      ? '--'
                      : item.randomCode),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.calendar_today, '發票日期', item.invoiceDate),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('尚無發票資訊',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
              color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
