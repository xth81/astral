import 'package:astral/core/database/dao/net_config_dao.dart';
import 'package:astral/core/states/network_config_state.dart';
import 'package:astral/core/repositories/network_config_repository.dart';

/// 网络配置服务：协调 State 与持久化
class NetworkConfigService {
  final NetworkConfigState state;
  final NetworkConfigRepository _repo;

  NetworkConfigService(this.state, this._repo);

  Future<void> init() async {
    final config = await _repo.get();
    state.applyFrom(config, autoSetMtu: await _repo.getAutoSetMTU());
  }

  Future<void> updateIpv4(String value) async {
    state.updateIpv4(value);
    await _repo.update((c) => c.ipv4 = value);
  }

  Future<void> updateDhcp(bool value) async {
    state.updateDhcp(value);
    await _repo.update((c) => c.dhcp = value);
  }

  Future<void> setAutoSetMTU(bool value) async {
    state.autoSetMTU.value = value;
    await _repo.setAutoSetMTU(value);
  }

  Future<void> updateDefaultProtocol(String value) async {
    state.defaultProtocol.value = value;
    await _repo.update((c) => c.default_protocol = value);
  }

  Future<void> updateEnableEncryption(bool value) async {
    state.updateEnableEncryption(value);
    await _repo.update((c) => c.enable_encryption = value);

    if (value) {
      await updateMtu(1360);
    } else {
      await updateMtu(1380);
    }
  }

  Future<void> updateMtu(int value) async {
    state.updateMtu(value);
    await _repo.update((c) => c.mtu = value);
  }

  Future<void> updateLatencyFirst(bool value) async {
    state.updateLatencyFirst(value);
    await _repo.update((c) => c.latency_first = value);
  }

  Future<void> updateNoTun(bool value) async {
    state.noTun.value = value;
    await _repo.update((c) => c.no_tun = value);
  }

  Future<void> updateEnableSocks5(bool value) async {
    state.enableSocks5.value = value;
    await _repo.update((c) => c.enable_socks5 = value);
  }

  Future<void> updateSocks5Port(int value) async {
    final port = normalizeSocks5Port(value);
    state.socks5Port.value = port;
    await _repo.update((c) => c.socks5_port = port);
  }

  Future<void> updateDataCompressAlgo(int value) async {
    state.dataCompressAlgo.value = value;
    await _repo.update((c) => c.data_compress_algo = value);
  }

  Future<void> updateDisableP2p(bool value) async {
    state.disableP2p.value = value;
    await _repo.update((c) => c.disable_p2p = value);
  }

  Future<void> updateEnableIpv6(bool value) async {
    state.enableIpv6.value = value;
    await _repo.update((c) => c.enable_ipv6 = value);
  }

  Future<void> updateEnableExitNode(bool value) async {
    state.enableExitNode.value = value;
    await _repo.update((c) => c.enable_exit_node = value);
  }

  Future<void> updateUseSmoltcp(bool value) async {
    state.useSmoltcp.value = value;
    await _repo.update((c) => c.use_smoltcp = value);
  }

  Future<void> updateRelayNetworkWhitelist(String value) async {
    state.relayNetworkWhitelist.value = value;
    await _repo.update((c) => c.relay_network_whitelist = value);
  }

  Future<void> updateRelayAllPeerRpc(bool value) async {
    state.relayAllPeerRpc.value = value;
    await _repo.update((c) => c.relay_all_peer_rpc = value);
  }

  Future<void> updateMultiThread(bool value) async {
    state.multiThread.value = value;
    await _repo.update((c) => c.multi_thread = value);
  }

  Future<void> updateDisableKcpInput(bool value) async {
    state.disableKcpInput.value = value;
    await _repo.update((c) => c.disable_kcp_input = value);
  }

  Future<void> updateDisableRelayKcp(bool value) async {
    state.disableRelayKcp.value = value;
    await _repo.update((c) => c.disable_relay_kcp = value);
  }

  Future<void> updateProxyForwardBySystem(bool value) async {
    state.proxyForwardBySystem.value = value;
    await _repo.update((c) => c.proxy_forward_by_system = value);
  }

  Future<void> updateAcceptDns(bool value) async {
    state.acceptDns.value = value;
    await _repo.update((c) => c.accept_dns = value);
  }

  Future<void> updatePrivateMode(bool value) async {
    state.privateMode.value = value;
    await _repo.update((c) => c.private_mode = value);
  }

  Future<void> updateEnableQuicProxy(bool value) async {
    state.enableQuicProxy.value = value;
    await _repo.update((c) => c.enable_quic_proxy = value);
  }

  Future<void> updateDisableQuicInput(bool value) async {
    state.disableQuicInput.value = value;
    await _repo.update((c) => c.disable_quic_input = value);
  }

  Future<void> updateEncryptionAlgorithm(String value) async {
    state.encryptionAlgorithm.value = value;
    await _repo.update((c) => c.encryption_algorithm = value);
  }

  Future<void> updateP2pOnly(bool value) async {
    state.p2pOnly.value = value;
    await _repo.update((c) => c.p2p_only = value);
  }

  Future<void> updateLazyP2p(bool value) async {
    state.lazyP2p.value = value;
    await _repo.update((c) => c.lazy_p2p = value);
  }

  Future<void> updateNeedP2p(bool value) async {
    state.needP2p.value = value;
    await _repo.update((c) => c.need_p2p = value);
  }

  Future<void> updateDisableUpnp(bool value) async {
    state.disableUpnp.value = value;
    await _repo.update((c) => c.disable_upnp = value);
  }

  Future<void> updateDisableRelayData(bool value) async {
    state.disableRelayData.value = value;
    await _repo.update((c) => c.disable_relay_data = value);
  }

  Future<void> updateDisableRelayQuic(bool value) async {
    state.disableRelayQuic.value = value;
    await _repo.update((c) => c.disable_relay_quic = value);
  }

  Future<void> updateTldDnsZone(String value) async {
    state.tldDnsZone.value = value;
    await _repo.update((c) => c.tld_dns_zone = value);
  }

  Future<void> updateExitNodes(List<String> value) async {
    state.exitNodes.value = value;
    await _repo.update((c) => c.exit_nodes = value);
  }

  Future<void> updateStunServers(List<String> value) async {
    state.stunServers.value = value;
    await _repo.update((c) => c.stun_servers = value);
  }

  Future<void> updateStunServersV6(List<String> value) async {
    state.stunServersV6.value = value;
    await _repo.update((c) => c.stun_servers_v6 = value);
  }

  Future<void> updateSecureModeEnabled(bool value) async {
    state.secureModeEnabled.value = value;
    await _repo.update((c) => c.secure_mode_enabled = value);
  }

  Future<void> updateLocalPrivateKey(String value) async {
    state.localPrivateKey.value = value;
    await _repo.update((c) => c.local_private_key = value);
  }

  Future<void> updateLocalPublicKey(String value) async {
    state.localPublicKey.value = value;
    await _repo.update((c) => c.local_public_key = value);
  }

  Future<void> updateManualRoutes(List<String> value) async {
    state.manualRoutes.value = value;
    await _repo.update((c) => c.manual_routes = value);
  }

  Future<void> updatePeerPublicKeys(List<String> value) async {
    state.peerPublicKeys.value = value;
    await _repo.update((c) => c.peer_public_keys = value);
  }

  Future<void> updateEnableUdpBroadcastRelay(bool value) async {
    state.enableUdpBroadcastRelay.value = value;
    await _repo.update((c) => c.enable_udp_broadcast_relay = value);
  }

  Future<void> updateDisableUdpHolePunching(bool value) async {
    state.disableUdpHolePunching.value = value;
    await _repo.update((c) => c.disable_udp_hole_punching = value);
  }

  Future<void> updateDisableTcpHolePunching(bool value) async {
    state.disableTcpHolePunching.value = value;
    await _repo.update((c) => c.disable_tcp_hole_punching = value);
  }

  Future<void> updateDisableSymHolePunching(bool value) async {
    state.disableSymHolePunching.value = value;
    await _repo.update((c) => c.disable_sym_hole_punching = value);
  }

  Future<void> updateBindDevice(bool value) async {
    state.bindDevice.value = value;
    await _repo.update((c) => c.bind_device = value);
  }

  Future<void> updateEnableKcpProxy(bool value) async {
    state.enableKcpProxy.value = value;
    await _repo.update((c) => c.enable_kcp_proxy = value);
  }

  Future<void> updateTcpWhitelist(String value) async {
    state.tcpWhitelist.value = value;
    await _repo.update((c) => c.tcp_whitelist = value);
  }

  Future<void> updateUdpWhitelist(String value) async {
    state.udpWhitelist.value = value;
    await _repo.update((c) => c.udp_whitelist = value);
  }
}
