import 'package:astral/features/rooms/utils/random_name.dart';
import 'package:astral/features/rooms/pages/room_page.dart';
import 'package:flutter/material.dart';

Future<void> showAddRoomDialog(BuildContext context) async {
  bool isEncrypted = true;
  String? name = RandomName();
  String? roomName;
  String? roomPassword;
  String? networkName;
  String? networkSecret;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('添加房间'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: name),
                  decoration: const InputDecoration(labelText: '房间名称'),
                  // 当文本字段内容改变时，同步更新外部 'name' 变量
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('是否保护'),
                  value: isEncrypted,
                  onChanged: (value) {
                    setState(() {
                      isEncrypted = value;
                    });
                  },
                ),

                if (!isEncrypted) ...[
                  TextField(
                    decoration: const InputDecoration(labelText: '房间号'),
                    onChanged: (value) => roomName = value,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: '房间密码'),
                    onChanged: (value) => roomPassword = value,
                  ),
                  const SizedBox(height: 8),
                ],
                const Divider(),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'EasyTier 网络名称',
                    helperText: 'EasyTier network name，留空使用房间号',
                  ),
                  onChanged: (value) => networkName = value,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'EasyTier 网络密钥',
                    helperText: 'EasyTier network secret，留空使用房间密码',
                  ),
                  onChanged: (value) => networkSecret = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  addEncryptedRoom(
                    isEncrypted,
                    name ?? RandomName(),
                    roomName ?? "",
                    roomPassword ?? "",
                    networkName ?? "",
                    networkSecret ?? "",
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    },
  );
}
