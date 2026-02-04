import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';
import '../providers/user_provider.dart';

class RepairPage extends StatefulWidget {
  const RepairPage({super.key});

  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  final _formKey = GlobalKey<FormState>();

  // 定義控制器來獲取輸入值
  final _communityNameController = TextEditingController();
  final _unitController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _contentController = TextEditingController();

  // 檔案選取相關
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  static const int _maxFileSize = 50 * 1024 * 1024; // 50MB

  String? _selectedContactType;

  // 聯絡人類別資料 (從後端 salrepairKinds 取得)
  List<Map<String, String>> _contactTypes = [];
  bool _isLoadingContactTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchContactTypes();

    // 透過 Provider 取得使用者資訊 (需在畫面建構後執行)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _unitController.text = userProvider.unit;
      if (userProvider.pjno.isNotEmpty) {
        _fetchCommunityName(userProvider.pjno);
        _fetchRepairAddress(userProvider.pjno, userProvider.unit);
      }
    });
  }

  Future<void> _fetchRepairAddress(String pjno, String unit) async {
    try {
      debugPrint('Fetching address for pjno: $pjno, unit: $unit');
      // 注意: 後端 API 參數名稱為 repairStord (對應 pjno) 和 repairUno (對應 unit)
      final uri = Uri.parse(
          '$_baseUrl/api/repair/address?repairStord=$pjno&repairUno=$unit');

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final response = await http.get(uri, headers: userProvider.authHeaders);

      debugPrint('Address response code: ${response.statusCode}');
      debugPrint('Address response body: ${response.body}');

      if (response.statusCode == 200) {
        // 假設後端直接回傳地址字串 (如果回傳 JSON 需解析)
        // 這裡後端回傳的是 JSON 格式: {"error": ...} 或 直接字串?
        // 根據 Controller: return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(result);
        // 如果 result 是純字串，前端視為 JSON 字串解析可能會出錯，如果 result 本身是 JSON 格式字串則沒問題
        // 根據 RepairService，它直接回傳 RestTemplate 的結果，通常是 String

        // 嘗試解析 JSON
        try {
          String address = response.body;

          // 嘗試解析 JSON
          try {
            final jsonBody = json.decode(response.body);
            if (jsonBody is Map) {
              if (jsonBody.containsKey('addrs')) {
                address = jsonBody['addrs'];
              } else if (jsonBody.containsKey('error')) {
                debugPrint('Address fetch error: ${jsonBody['error']}');
                // 如果有錯誤訊息，也可以選擇清除地址或顯示錯誤
                // address = '';
              }
            }
          } catch (_) {
            // 非 JSON，視為 plain text address - 維持原狀
          }

          setState(() {
            _addressController.text = address;
          });
        } catch (e) {
          debugPrint('Address parse error: $e');
        }
      }
    } catch (e) {
      debugPrint('無法取得地址 error: $e');
    }
  }

  Future<void> _fetchCommunityName(String pjno) async {
    try {
      debugPrint('Fetching community name for pjno: $pjno');
      final uri = Uri.parse('$_baseUrl/api/repair/store-info?pjno=$pjno');

      // 加入 Authorization Header
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final response = await http.get(uri, headers: userProvider.authHeaders);

      debugPrint('Community name response code: ${response.statusCode}');
      debugPrint('Community name response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['communityName'] != null) {
          setState(() {
            _communityNameController.text = data['communityName'];
          });
        }
      }
    } catch (e) {
      debugPrint('無法取得社區名稱 error: $e');
    }
  }

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  Future<void> _fetchContactTypes() async {
    debugPrint('Starting _fetchContactTypes...');
    try {
      // 自動切換 Base URL
      final uri = Uri.parse('$_baseUrl/api/repair/contact-types');
      debugPrint('Fetching contact types from: $uri');

      // 加入 Authorization Header
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final response = await http.get(uri, headers: userProvider.authHeaders);

      debugPrint('Contact types response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('Contact types response: ${response.body}');
        try {
          final dynamic decodedData = json.decode(response.body);
          if (decodedData is List) {
            setState(() {
              _contactTypes = decodedData
                  .map<Map<String, String>>((item) => {
                        'value': item['kindid']?.toString() ?? '',
                        'label': item['kindName']?.toString() ?? '未知'
                      })
                  .toList();
              _isLoadingContactTypes = false;
            });
          } else {
            throw const FormatException('API 回傳格式不符預期 (非列表)');
          }
        } catch (e) {
          debugPrint('資料解析錯誤: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('資料載入失敗：格式錯誤')),
            );
            setState(() => _isLoadingContactTypes = false);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('伺服器錯誤: ${response.statusCode}')),
          );
        }
        if (mounted) setState(() => _isLoadingContactTypes = false);
      }
    } catch (e) {
      debugPrint('無法取得聯絡人類別 error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('網路連線異常，請檢查網路設定')),
        );
      }
      if (mounted) setState(() => _isLoadingContactTypes = false);
    }
  }

  @override
  void dispose() {
    // 釋放控制器資源
    _communityNameController.dispose();
    _unitController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 圖片壓縮輔助方法
  Future<XFile?> _compressImage(XFile file) async {
    // Web 版暫不執行壓縮 (需改用 Uint8List 處理，且瀏覽器通常會自動處理部分上傳優化)
    if (kIsWeb) return file;

    try {
      final tmpDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tmpDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}',
      );

      var result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70, // 壓縮品質 70%
        minWidth: 1920, // 限制最大寬度，避免上傳過大解析度
        minHeight: 1080,
      );
      return result ?? file; // 若壓縮回傳 null 則使用原圖
    } catch (e) {
      debugPrint('圖片壓縮失敗: $e');
      return file; // 發生錯誤時回傳原圖
    }
  }

  // 影片壓縮輔助方法
  Future<XFile?> _compressVideo(XFile file) async {
    // Web 版暫不執行壓縮
    if (kIsWeb) return file;

    try {
      final MediaInfo? info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality, // 使用中等品質壓縮 (平衡畫質與大小)
        deleteOrigin: false, // 保留原檔
        includeAudio: true,
      );

      if (info != null && info.file != null) {
        return XFile(info.file!.path);
      }
      return file;
    } catch (e) {
      debugPrint('影片壓縮失敗: $e');
      return file; // 發生錯誤時回傳原檔
    }
  }

  // 選取多張照片
  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      List<XFile> validImages = [];
      bool hasOversizedFile = false;

      for (var image in images) {
        // 嘗試壓縮圖片
        XFile? processedImage = await _compressImage(image);

        if (processedImage != null &&
            await processedImage.length() <= _maxFileSize) {
          validImages.add(processedImage);
        } else {
          hasOversizedFile = true;
        }
      }

      if (hasOversizedFile && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('部分圖片超過 50MB 限制，已略過')),
        );
      }

      if (validImages.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(validImages);
        });
      }
    }
  }

  // 選取影片
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      // 顯示處理中提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              duration: Duration(seconds: 1), content: Text('正在壓縮影片...')),
        );
      }

      // 執行壓縮
      XFile? processedVideo = await _compressVideo(video);

      if (processedVideo != null &&
          await processedVideo.length() > _maxFileSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('影片超過 50MB 限制，無法上傳')),
          );
        }
        return;
      }
      setState(() {
        if (processedVideo != null) _selectedFiles.add(processedVideo);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('報修單送出中...')),
      );

      try {
        final uri = Uri.parse('$_baseUrl/api/repair/new');

        final userProvider = Provider.of<UserProvider>(context, listen: false);

        var request = http.MultipartRequest('POST', uri);
        request.headers
            .addAll(userProvider.authHeaders); // 加入 Authorization Header
        request.fields['pjnoid'] = userProvider.pjno; // 傳送專案代號
        request.fields['communityName'] = _communityNameController.text;
        request.fields['unit'] = _unitController.text;
        request.fields['contactName'] = _nameController.text;
        request.fields['contactPhone'] = _phoneController.text;
        request.fields['address'] = _addressController.text;
        request.fields['content'] = _contentController.text;
        request.fields['contactType'] = _selectedContactType ?? '';

        // 加入選取的檔案
        for (var file in _selectedFiles) {
          MediaType mediaType = _getMediaType(file
              .name); // Web uses file.name, Mobile uses file.path but name is safer for extension

          if (kIsWeb) {
            var bytes = await file.readAsBytes();
            request.files.add(http.MultipartFile.fromBytes(
              'files',
              bytes,
              filename: file.name,
              contentType: mediaType,
            ));
          } else {
            request.files.add(await http.MultipartFile.fromPath(
              'files',
              file.path,
              contentType: mediaType,
            ));
          }
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (!mounted) return;

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('報修單建立成功')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('提交失敗: ${response.body}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('發生錯誤: $e')),
          );
        }
      }
    }
  }

  MediaType _getMediaType(String filename) {
    String ext = filename.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      return MediaType('image', ext == 'jpg' ? 'jpeg' : ext);
    }
    if (['mp4', 'mov', 'avi'].contains(ext)) {
      return MediaType('video', ext);
    }
    return MediaType('application', 'octet-stream');
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoadingContactTypes = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Future> tasks = [_fetchContactTypes()];

    if (userProvider.pjno.isNotEmpty) {
      tasks.add(_fetchCommunityName(userProvider.pjno));
    }

    await Future.wait(tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建報修'),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _communityNameController,
                  readOnly: true, // 設定為唯讀，避免使用者修改
                  decoration: const InputDecoration(
                    labelText: '社區名稱',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.apartment),
                    filled: true, // 加入背景色提示為唯讀欄位
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _unitController,
                  readOnly: true, // 設定為唯讀
                  decoration: const InputDecoration(
                    labelText: '戶別',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.meeting_room),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '聯絡人姓名',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? '請輸入聯絡人姓名' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: '聯絡電話',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? '請輸入聯絡電話' : null,
                ),
                const SizedBox(height: 16),
                _isLoadingContactTypes
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedContactType,
                        decoration: const InputDecoration(
                          labelText: '聯絡人類別',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                        items: _contactTypes.map((type) {
                          return DropdownMenuItem(
                            value: type['value'],
                            child: Text(type['label']!),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedContactType = value),
                        validator: (value) =>
                            (value == null) ? '請選擇聯絡人類別' : null,
                      ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  readOnly: true, // 設定為唯讀，因為是由 API 自動帶入
                  decoration: const InputDecoration(
                    labelText: '地址',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                    filled: true,
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? '請輸入地址' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '報修內容',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? '請輸入報修內容' : null,
                ),
                const SizedBox(height: 16),

                // 檔案上傳與預覽區域
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('新增照片'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text('新增影片'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedFiles.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      // 簡單判斷是否為影片 (僅供 UI 顯示區分用)
                      final bool isVideo =
                          file.path.toLowerCase().endsWith('.mp4') ||
                              file.path.toLowerCase().endsWith('.mov');
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isVideo
                                  ? Container(
                                      color: Colors.black12,
                                      child: const Center(
                                          child: Icon(Icons.play_circle_outline,
                                              size: 40)),
                                    )
                                  : kIsWeb
                                      ? Image.network(
                                          file.path,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Image.file(
                                          File(file.path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFiles.removeAt(index);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('送出報修'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
