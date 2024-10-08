Future<void> _syncData() async {
  setState(() {
    _isSyncing = true;
  });

  try {
    // 执行同步操作
    // ...
  } catch (e) {
    // 错误处理
    print('同步出错: $e');
  } finally {
    // 确保无论同步成功与否，都将_isSyncing设置回false
    setState(() {
      _isSyncing = false;
    });
  }
}
