import 'package:astral/core/models/server_mod.dart';
import 'package:astral/core/models/network_config_share.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/utils/network/ip_utils.dart';
import 'package:astral/src/rust/api/simple.dart';

/// 服务器配置构建器
///
/// 设计思路：
/// 1. 默认配置为底层
/// 2. 通过链式调用逐层修改
/// 3. 房间配置可临时覆盖默认配置（不修改持久化）
class ServerConfigBuilder {
  final ServiceManager _services;
  final List<String> _logs = [];

  // 配置参数
  String? _username;
  bool? _enableDhcp;
  String? _specifiedIp;
  String? _roomName;
  String? _roomPassword;
  List<String> _serverUrls = [];
  List<String> _listenerUrls = [];
  List<String> _cidrs = [];
  // 与 _serverUrls 按索引对应的 peer 公钥（EasyTier peer_public_key）
  List<String> _peerPublicKeys = [];
  final List<Forward> _forwards = [];
  FlagsC? _flags;

  // 房间配置（临时覆盖）
  NetworkConfigShare? _roomConfig;

  ServerConfigBuilder(this._services);

  void _log(String message) {
    _logs.add(message);
  }

  /// 设置玩家信息
  ServerConfigBuilder withPlayerInfo() {
    _username = _services.playerState.playerName.value;

    final currentIp = _services.networkConfigState.ipv4.value;
    bool forceDhcp =
        currentIp.isEmpty ||
        currentIp == "0.0.0.0" ||
        !isValidIpAddress(currentIp, excludeLoopback: false);

    if (forceDhcp) {
      _enableDhcp = true;
      _specifiedIp = "";
      _log('玩家: $_username (强制DHCP)');
    } else {
      _enableDhcp = _services.networkConfigState.dhcp.value;
      _specifiedIp = currentIp;
      _log('玩家: $_username (IP: $currentIp, DHCP: $_enableDhcp)');
    }

    return this;
  }

  List<String> _expandServerUrls(Iterable<ServerMod> servers) {
    final urls = <String>[];
    for (final server in servers) {
      if (server.tcp) urls.add('tcp://${server.url}');
      if (server.faketcp) urls.add('faketcp://${server.url}');
      if (server.udp) urls.add('udp://${server.url}');
      if (server.ws) urls.add('ws://${server.url}');
      if (server.wss) urls.add('wss://${server.url}');
      if (server.quic) urls.add('quic://${server.url}');
      if (server.wg) urls.add('wg://${server.url}');
      if (server.txt) urls.add('txt://${server.url}');
      if (server.srv) urls.add('srv://${server.url}');
      if (server.http) urls.add('http://${server.url}');
      if (server.https) urls.add('https://${server.url}');
    }
    return urls;
  }

  /// 收集与 [urls] 按索引对应的 peer 公钥列表（EasyTier peer_public_key）
  List<String> _collectPeerPublicKeys(Iterable<ServerMod> servers) {
    final keys = <String>[];
    for (final server in servers) {
      // 与 _expandServerUrls 的协议展开顺序保持一致
      for (final enabled in [
        server.tcp,
        server.faketcp,
        server.udp,
        server.ws,
        server.wss,
        server.quic,
        server.wg,
        server.txt,
        server.srv,
        server.http,
        server.https,
      ]) {
        if (enabled) keys.add(server.peer_public_key);
      }
    }
    return keys;
  }

  /// 设置房间信息
  ///
  /// EasyTier 的 network_name / network_secret 默认取房间的 roomName / password；
  /// 若用户在设置中填了自定义网络名称/密钥，则优先使用自定义值（原版易难模式）。
  ServerConfigBuilder withRoom(dynamic room) {
    final customName = _services.networkConfigState.networkName.value;
    final customSecret = _services.networkConfigState.networkSecret.value;

    if (customName.isNotEmpty) {
      _roomName = customName;
      _log('网络名称: 自定义 $customName');
    } else {
      _roomName = room.roomName;
      _log('网络名称: 房间 ${room.roomName}');
    }

    if (customSecret.isNotEmpty) {
      _roomPassword = customSecret;
      _log('网络密钥: 自定义');
    } else {
      _roomPassword = room.password;
    }

    return this;
  }

  /// 设置房间配置（临时覆盖）
  ServerConfigBuilder withRoomConfig(NetworkConfigShare? config) {
    _roomConfig = config;
    if (config != null) {
      final overrides = <String>[];
      if (config.dhcp != null) overrides.add('DHCP');
      if (config.defaultProtocol != null) overrides.add('协议');
      if (config.enableEncryption != null) overrides.add('加密');
      if (config.latencyFirst != null) overrides.add('低延迟');
      if (config.disableP2p != null) overrides.add('P2P');
      if (config.disableUdpHolePunching != null) overrides.add('UDP打洞');
      if (config.enableKcpProxy != null) overrides.add('KCP代理');
      if (config.noTun != null) overrides.add('TUN模式');

      if (overrides.isNotEmpty) {
        _log('🔄 房间配置临时覆盖: ${overrides.join(', ')}');
      }
    }
    return this;
  }

  /// 构建服务器URL列表
  ServerConfigBuilder withServers(dynamic room, List<ServerMod> globalServers) {
    final enabledServers = globalServers.where((s) => s.enable).toList();
    final enabledUrls = _expandServerUrls(enabledServers);
    final enabledKeys = _collectPeerPublicKeys(enabledServers);

    // 房间服务器优先 - 直接检查列表，不依赖 hasServers 标志
    if (room.servers != null && room.servers.isNotEmpty) {
      final roomUrls = List<String>.from(room.servers);
      final merged = <String>[];
      final mergedKeys = <String>[];
      final seen = <String>{};
      for (final url in roomUrls) {
        if (seen.add(url)) {
          merged.add(url);
          mergedKeys.add(''); // 房间服务器没有公钥
        }
      }
      for (final (i, url) in enabledUrls.indexed) {
        if (seen.add(url)) {
          merged.add(url);
          mergedKeys.add(enabledKeys[i]);
        }
      }
      _serverUrls = merged;
      _peerPublicKeys = mergedKeys;
      _log('📡 使用房间服务器 (${_serverUrls.length} 个): $_serverUrls');
      return this;
    }

    // 否则使用全局启用的服务器
    _serverUrls = enabledUrls;
    _peerPublicKeys = enabledKeys;
    _log('📡 使用全局服务器 (${_serverUrls.length} 个)');
    return this;
  }

  /// 构建监听器列表
  ServerConfigBuilder withListeners(List<String> listeners) {
    _listenerUrls = listeners.where((url) => !url.contains('[::]')).toList();
    _log('👂 监听器 (${_listenerUrls.length} 个)');
    return this;
  }

  /// 构建代理CIDR
  ServerConfigBuilder withCidrs(List<String> cidrs) {
    _cidrs = cidrs;
    if (cidrs.isNotEmpty) {
      _log('🌐 代理CIDR (${cidrs.length} 个)');
    }
    return this;
  }

  /// 构建运行时标志（支持房间配置覆盖）
  ServerConfigBuilder withFlags() {
    final nc = _services.networkConfigState;
    final rc = _roomConfig; // 房间配置

    // 应用房间配置的DHCP覆盖
    if (rc?.dhcp != null) {
      _enableDhcp = rc!.dhcp;
      _log('🔄 DHCP被房间配置覆盖: ${rc.dhcp}');
    }

    final enableEncryption = rc?.enableEncryption ?? nc.enableEncryption.value;

    _flags = FlagsC(
      defaultProtocol: rc?.defaultProtocol ?? nc.defaultProtocol.value,
      devName: nc.devName.value,
      enableEncryption: enableEncryption,
      enableIpv6: nc.enableIpv6.value,
      mtu: nc.mtu.value,
      multiThread: nc.multiThread.value,
      latencyFirst: rc?.latencyFirst ?? nc.latencyFirst.value,
      enableExitNode: nc.enableExitNode.value,
      noTun: rc?.noTun ?? nc.noTun.value,
      useSmoltcp: nc.useSmoltcp.value,
      relayNetworkWhitelist: nc.relayNetworkWhitelist.value.isEmpty
          ? '*'
          : nc.relayNetworkWhitelist.value,
      disableP2P: rc?.disableP2p ?? nc.disableP2p.value,
      enableUdpBroadcastRelay: nc.enableUdpBroadcastRelay.value,
      relayAllPeerRpc: nc.relayAllPeerRpc.value,
      disableUdpHolePunching:
          rc?.disableUdpHolePunching ?? nc.disableUdpHolePunching.value,
      disableTcpHolePunching:
          rc?.disableTcpHolePunching ?? nc.disableTcpHolePunching.value,
      dataCompressAlgo: rc?.dataCompressAlgo ?? nc.dataCompressAlgo.value,
      bindDevice: rc?.bindDevice ?? nc.bindDevice.value,
      enableKcpProxy: rc?.enableKcpProxy ?? nc.enableKcpProxy.value,
      disableKcpInput: nc.disableKcpInput.value,
      disableRelayKcp: nc.disableRelayKcp.value,
      proxyForwardBySystem: nc.proxyForwardBySystem.value,
      acceptDns: nc.acceptDns.value,
      privateMode: nc.privateMode.value,
      enableQuicProxy: nc.enableQuicProxy.value,
      disableQuicInput: nc.disableQuicInput.value,
      disableSymHolePunching:
          rc?.disableSymHolePunching ?? nc.disableSymHolePunching.value,
      tcpWhitelist: nc.tcpWhitelist.value,
      udpWhitelist: nc.udpWhitelist.value,
      socks5Port: nc.enableSocks5.value ? nc.socks5Port.value : 0,
      encryptionAlgorithm: nc.encryptionAlgorithm.value,
      p2pOnly: nc.p2pOnly.value,
      lazyP2p: nc.lazyP2p.value,
      needP2p: nc.needP2p.value,
      disableUpnp: nc.disableUpnp.value,
      preferPeerRelay: nc.preferPeerRelay.value,
      disableRelayData: nc.disableRelayData.value,
      disableRelayQuic: nc.disableRelayQuic.value,
      tldDnsZone: nc.tldDnsZone.value,
      exitNodes: nc.exitNodes.value,
      stunServers: nc.stunServers.value,
      tcpStunServers: nc.tcpStunServers.value,
      stunServersV6: nc.stunServersV6.value,
      secureModeEnabled: nc.secureModeEnabled.value,
      localPrivateKey: nc.localPrivateKey.value,
      localPublicKey: nc.localPublicKey.value,
      manualRoutes: nc.manualRoutes.value,
      peerPublicKeys: _peerPublicKeys,
    );

    _log('⚙️  运行标志配置完成 (加密: $enableEncryption, SOCKS5: ${_flags!.socks5Port})');
    return this;
  }

  /// 构建并返回配置 + 日志
  ({
    String username,
    bool enableDhcp,
    String specifiedIp,
    String roomName,
    String roomPassword,
    List<String> severurl,
    List<String> onurl,
    List<String> cidrs,
    List<Forward> forwards,
    FlagsC flag,
    List<String> logs,
  })
  build() {
    _log('✅ 配置构建完成');
    _log(
      '📊 摘要: 服务器=${_serverUrls.length}, 监听器=${_listenerUrls.length}, 转发=${_forwards.length}',
    );

    return (
      username: _username!,
      enableDhcp: _enableDhcp!,
      specifiedIp: _specifiedIp!,
      roomName: _roomName!,
      roomPassword: _roomPassword!,
      severurl: _serverUrls,
      onurl: _listenerUrls,
      cidrs: _cidrs,
      forwards: _forwards,
      flag: _flags!,
      logs: List.unmodifiable(_logs),
    );
  }

}
