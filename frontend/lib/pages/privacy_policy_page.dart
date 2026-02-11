import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隱私權政策'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '隱私權政策',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '最後更新日期：2026年02月11日',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              '1. 引言',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '歡迎使用豐邑客服系統（以下簡稱「本服務」）。我們非常重視您的隱私權，本隱私權政策將說明我們如何收集、使用、揭露及保護您的個人資訊。',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '2. 我們收集的資訊',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '當您使用本服務時，我們可能會收集以下類型的資訊：\n'
              '• 帳戶資訊：如您的姓名、電子郵件地址、電話號碼等。\n'
              '• 使用數據：如您操作應用程式的紀錄、點擊行為等。\n'
              '• 裝置資訊：如您的裝置型號、作業系統版本、唯一裝置識別碼等。',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '3. 資訊的使用方式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '我們將收集的資訊用於以下目的：\n'
              '• 提供、維護及改善本服務。\n'
              '• 處理您的帳戶註冊及登入。\n'
              '• 發送相關通知及更新。\n'
              '• 回應您的客戶服務請求。',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '4. 資訊的分享與揭露',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '除非經您同意或法律規定，我們不會將您的個人資訊分享給第三方。但在以下情況下，我們可能會分享您的資訊：\n'
              '• 服務供應商：協助我們營運本服務的第三方合作夥伴。\n'
              '• 法律要求：應法院命令或政府機關要求。',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '5. 資料安全',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '我們採取合理的安全措施來保護您的個人資訊免於遺失、遭竊、濫用、未經授權的存取、揭露、變更或銷毀。',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '6. 變更通知',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '我們可能會不時更新本隱私權政策。如有重大變更，我們將透過應用程式通知您。',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              '7. 聯絡我們',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '如果您對本隱私權政策有任何疑問，請透過客服管道與我們聯繫。',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
