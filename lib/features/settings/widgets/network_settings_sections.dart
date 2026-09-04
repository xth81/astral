import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/features/settings/pages/network/port_whitelist_page.dart';
import 'package:astral/src/rust/api/hops.dart';
import 'package:signals_flutter/signals_flutter.dart';

Widget _settingsCard({required List<Widget> children}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Card(child: Column(children: children))],
  );
}

Widget _divider() => const Divider(height: 1);

/// 基础网络设置卡片（协议 / 加密 / 延迟优先 / 禁用 P2P）
class NetworkBasicSettingsCard extends StatelessWidget {
  const NetworkBasicSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _settingsCard(
      children: [
        ListTile(
          title: Text(LocaleKeys.p2p_hole_punching.tr()),
          subtitle: Text(LocaleKeys.preferred_protocol.tr()),
          trailing: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                value:
                    ServiceManager()
                            .networkConfigState
                            .defaultProtocol.watch(context)
                            .isEmpty
                        ? 'tcp'
                        : ServiceManager()
                            .networkConfigState
                            .defaultProtocol.watch(context),
                items: const [
                  DropdownMenuItem(
                    value: 'tcp',
                    child: Text('TCP', style: TextStyle(fontSize: 14)),
                  ),
                  DropdownMenuItem(
                    value: 'udp',
                    child: Text('UDP', style: TextStyle(fontSize: 14)),
                  ),
                  DropdownMenuItem(
                    value: 'faketcp',
                    child: Text('FakeTCP', style: TextStyle(fontSize: 14)),
                  ),
                  DropdownMenuItem(
                    value: 'ws',
                    child: Text(
                      'WebSocket',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'wss',
                    child: Text('WSS', style: TextStyle(fontSize: 14)),
                  ),
                  DropdownMenuItem(
                    value: 'quic',
                    child: Text('QUIC', style: TextStyle(fontSize: 14)),
                  ),
                ],
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (value) {
                  if (value != null) {
                    ServiceManager().networkConfig.updateDefaultProtocol(
                      value,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        _divider(),
        SwitchListTile(
          title: Text(LocaleKeys.enable_encryption.tr()),
          subtitle: Text(LocaleKeys.auto_set_mtu.tr()),
          value: ServiceManager().networkConfigState.enableEncryption.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableEncryption(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.latency_first.tr()),
          subtitle: Text(LocaleKeys.latency_first_desc.tr()),
          value: ServiceManager().networkConfigState.latencyFirst.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateLatencyFirst(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.disable_p2p.tr()),
          subtitle: Text(LocaleKeys.disable_p2p_desc.tr()),
          value: ServiceManager().networkConfigState.disableP2p.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableP2p(value);
          },
        ),
      ],
    );
  }
}

/// 高级网络设置卡片
class NetworkAdvancedSettingsCard extends StatelessWidget {
  const NetworkAdvancedSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _settingsCard(
      children: [
        ListTile(
          title: Text(LocaleKeys.advanced_network_settings.tr()),
          subtitle: Text(LocaleKeys.advanced_network_settings_desc.tr()),
          leading: const Icon(Icons.settings_ethernet),
        ),
        _divider(),
        SwitchListTile(
          title: Text(LocaleKeys.disable_udp_hole_punching.tr()),
          subtitle: Text(LocaleKeys.disable_udp_hole_punching_desc.tr()),
          value:
              ServiceManager()
                  .networkConfigState
                  .disableUdpHolePunching.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableUdpHolePunching(
              value,
            );
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.disable_tcp_hole_punching.tr()),
          subtitle: Text(LocaleKeys.disable_tcp_hole_punching_desc.tr()),
          value:
              ServiceManager()
                  .networkConfigState
                  .disableTcpHolePunching.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableTcpHolePunching(
              value,
            );
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.disable_sym_hole_punching.tr()),
          subtitle: Text(LocaleKeys.disable_sym_hole_punching_desc.tr()),
          value:
              ServiceManager()
                  .networkConfigState
                  .disableSymHolePunching.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableSymHolePunching(
              value,
            );
          },
        ),
        ListTile(
          title: Text(LocaleKeys.compression_algorithm.tr()),
          subtitle: Text(LocaleKeys.compression_algorithm_desc.tr()),
          trailing: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<int>(
                value:
                    ServiceManager()
                        .networkConfigState
                        .dataCompressAlgo.watch(context),
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: Text(
                      LocaleKeys.no_compression.tr(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text(
                      LocaleKeys.high_performance_compression.tr(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (value) {
                  if (value != null) {
                    ServiceManager().networkConfig.updateDataCompressAlgo(
                      value,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        SwitchListTile(
          title: Text(LocaleKeys.enable_kcp_proxy.tr()),
          subtitle: Text(LocaleKeys.enable_kcp_proxy_desc.tr()),
          value: ServiceManager().networkConfigState.enableKcpProxy.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableKcpProxy(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.bind_device.tr()),
          subtitle: Text(LocaleKeys.bind_device_desc.tr()),
          value: ServiceManager().networkConfigState.bindDevice.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateBindDevice(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.tun_device.tr()),
          subtitle: Text(LocaleKeys.tun_device_desc.tr()),
          value: ServiceManager().networkConfigState.noTun.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateNoTun(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.enable_socks5.tr()),
          subtitle: Text(LocaleKeys.enable_socks5_desc.tr()),
          value: ServiceManager().networkConfigState.enableSocks5.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableSocks5(value);
          },
        ),
        if (ServiceManager().networkConfigState.enableSocks5.watch(context)) ...[
          ListTile(
            title: Text(LocaleKeys.socks5_port.tr()),
            subtitle: Text(LocaleKeys.socks5_port_desc.tr()),
            trailing: SizedBox(
              width: 100,
              child: TextFormField(
                key: ValueKey(
                  ServiceManager().networkConfigState.socks5Port.watch(context),
                ),
                initialValue: ServiceManager()
                    .networkConfigState
                    .socks5Port.watch(context)
                    .toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) {
                  final port = int.tryParse(value);
                  if (port != null && port > 0 && port <= 65535) {
                    ServiceManager().networkConfig.updateSocks5Port(port);
                  }
                },
              ),
            ),
          ),
          ListTile(
            title: Text(
              LocaleKeys.socks5_address_hint.tr(
                namedArgs: {
                  'port': ServiceManager()
                      .networkConfigState
                      .socks5Port.watch(context)
                      .toString(),
                },
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 网络身份设置卡片（自定义 EasyTier network_name / network_secret）
class NetworkIdentitySettingsCard extends StatelessWidget {
  const NetworkIdentitySettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _settingsCard(
      children: [
        ListTile(
          title: Text('网络身份'),
          subtitle: Text('自定义网络名称和密钥，留空则使用房间配置'),
          leading: const Icon(Icons.vpn_key),
        ),
        _divider(),
        ListTile(
          title: Text('网络名称'),
          subtitle: Text('EasyTier network name，留空使用房间号'),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(
                ServiceManager().networkConfigState.networkName.watch(context),
              ),
              initialValue:
                  ServiceManager().networkConfigState.networkName.watch(
                    context,
                  ),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateNetworkName(value.trim());
              },
            ),
          ),
        ),
        _divider(),
        ListTile(
          title: Text('网络密钥'),
          subtitle: Text('EasyTier network secret，留空使用房间密码'),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(
                ServiceManager().networkConfigState.networkSecret.watch(
                  context,
                ),
              ),
              initialValue:
                  ServiceManager().networkConfigState.networkSecret.watch(
                    context,
                  ),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateNetworkSecret(
                  value.trim(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// EasyTier 兼容设置卡片（已透传但未暴露的 EasyTier 原版高级功能）
class EasyTierCompatSettingsCard extends StatelessWidget {
  const EasyTierCompatSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final nc = ServiceManager().networkConfigState;

    return _settingsCard(
      children: [
        ListTile(
          title: Text('EasyTier 兼容设置'),
          subtitle: Text('更多 EasyTier 原版高级功能'),
          leading: const Icon(Icons.settings_suggest),
        ),
        _divider(),
        SwitchListTile(
          title: Text('启用 IPv6'),
          subtitle: Text('EasyTier enable_ipv6'),
          value: nc.enableIpv6.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableIpv6(value);
          },
        ),
        SwitchListTile(
          title: Text('出口节点'),
          subtitle: Text('EasyTier enable_exit_node，允许其他节点经此节点访问外部网络'),
          value: nc.enableExitNode.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableExitNode(value);
          },
        ),
        SwitchListTile(
          title: Text('smoltcp 网络栈'),
          subtitle: Text('EasyTier use_smoltcp，使用用户态 TCP/IP 栈'),
          value: nc.useSmoltcp.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateUseSmoltcp(value);
          },
        ),
        SwitchListTile(
          title: Text('中继所有对等 RPC'),
          subtitle: Text('EasyTier relay_all_peer_rpc'),
          value: nc.relayAllPeerRpc.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateRelayAllPeerRpc(value);
          },
        ),
        SwitchListTile(
          title: Text('多线程'),
          subtitle: Text('EasyTier multi_thread'),
          value: nc.multiThread.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateMultiThread(value);
          },
        ),
        SwitchListTile(
          title: Text('禁用 KCP 输入'),
          subtitle: Text('EasyTier disable_kcp_input'),
          value: nc.disableKcpInput.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableKcpInput(value);
          },
        ),
        SwitchListTile(
          title: Text('禁用 KCP 中继'),
          subtitle: Text('EasyTier disable_relay_kcp'),
          value: nc.disableRelayKcp.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableRelayKcp(value);
          },
        ),
        SwitchListTile(
          title: Text('QUIC 代理'),
          subtitle: Text('EasyTier enable_quic_proxy'),
          value: nc.enableQuicProxy.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableQuicProxy(value);
          },
        ),
        SwitchListTile(
          title: Text('禁用 QUIC 输入'),
          subtitle: Text('EasyTier disable_quic_input'),
          value: nc.disableQuicInput.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableQuicInput(value);
          },
        ),
        SwitchListTile(
          title: Text('系统代理转发'),
          subtitle: Text('EasyTier proxy_forward_by_system'),
          value: nc.proxyForwardBySystem.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateProxyForwardBySystem(value);
          },
        ),
        SwitchListTile(
          title: Text('接受 DNS'),
          subtitle: Text('EasyTier accept_dns，启用 Magic DNS'),
          value: nc.acceptDns.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateAcceptDns(value);
          },
        ),
        SwitchListTile(
          title: Text('私有模式'),
          subtitle: Text('EasyTier private_mode'),
          value: nc.privateMode.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updatePrivateMode(value);
          },
        ),
        _divider(),
        ListTile(
          title: Text('中继网络白名单'),
          subtitle: Text('EasyTier relay_network_whitelist，留空表示 *'),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(nc.relayNetworkWhitelist.watch(context)),
              initialValue: nc.relayNetworkWhitelist.watch(context),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateRelayNetworkWhitelist(
                  value.trim(),
                );
              },
            ),
          ),
        ),
        _divider(),
        ListTile(
          leading: const Icon(Icons.shield_outlined),
          title: Text('端口白名单'),
          subtitle: Text('TCP/UDP 端口限制'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PortWhitelistPage(),
            ),
          ),
        ),
        _divider(),
        ListTile(
          title: Text('加密算法'),
          subtitle: Text('EasyTier encryption_algorithm'),
          trailing: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                value: nc.encryptionAlgorithm.watch(context),
                items: const [
                  DropdownMenuItem(
                    value: 'aes-gcm',
                    child: Text('AES-GCM', style: TextStyle(fontSize: 14)),
                  ),
                  DropdownMenuItem(
                    value: 'aes-256-gcm',
                    child: Text(
                      'AES-256-GCM',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'chacha20-poly1305',
                    child: Text(
                      'ChaCha20-Poly1305',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (value) {
                  if (value != null) {
                    ServiceManager().networkConfig.updateEncryptionAlgorithm(
                      value,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        SwitchListTile(
          title: Text('仅使用 P2P 直连'),
          subtitle: Text('EasyTier p2p_only，禁用所有中转'),
          value: nc.p2pOnly.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateP2pOnly(value);
          },
        ),
        SwitchListTile(
          title: Text('懒加载 P2P'),
          subtitle: Text('EasyTier lazy_p2p'),
          value: nc.lazyP2p.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateLazyP2p(value);
          },
        ),
        SwitchListTile(
          title: Text('强制 P2P 连接'),
          subtitle: Text('EasyTier need_p2p'),
          value: nc.needP2p.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateNeedP2p(value);
          },
        ),
        SwitchListTile(
          title: Text('禁用 UPnP'),
          subtitle: Text('EasyTier disable_upnp'),
          value: nc.disableUpnp.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableUpnp(value);
          },
        ),
        SwitchListTile(
          title: Text('优先对等中继'),
          subtitle: Text('EasyTier prefer_peer_relay，优先使用对等节点作为中继'),
          value: nc.preferPeerRelay.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updatePreferPeerRelay(value);
          },
        ),
        SwitchListTile(
          title: Text('禁用中继数据'),
          subtitle: Text('EasyTier disable_relay_data'),
          value: nc.disableRelayData.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableRelayData(value);
          },
        ),
        SwitchListTile(
          title: Text('禁用 QUIC 中继'),
          subtitle: Text('EasyTier disable_relay_quic'),
          value: nc.disableRelayQuic.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableRelayQuic(value);
          },
        ),
        _divider(),
        ListTile(
          title: Text('DNS 顶级域名'),
          subtitle: Text('EasyTier tld_dns_zone（Magic DNS 域名后缀）'),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(nc.tldDnsZone.watch(context)),
              initialValue: nc.tldDnsZone.watch(context),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateTldDnsZone(value.trim());
              },
            ),
          ),
        ),
        _divider(),
        ListTile(
          title: Text('出口节点'),
          subtitle: Text(
            'EasyTier exit_nodes，允许其他节点经此节点访问外部网络（IP，逗号分隔）',
          ),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(nc.exitNodes.watch(context).join(',')),
              initialValue: nc.exitNodes.watch(context).join(','),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateExitNodes(
                  _splitList(value),
                );
              },
            ),
          ),
        ),
        _divider(),
        ListTile(
          title: Text('STUN 服务器'),
          subtitle: Text('EasyTier stun_servers（逗号分隔）'),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(nc.stunServers.watch(context).join(',')),
              initialValue: nc.stunServers.watch(context).join(','),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateStunServers(
                  _splitList(value),
                );
              },
            ),
          ),
        ),
        _divider(),
        ListTile(
          title: Text('TCP STUN 服务器'),
          subtitle: Text('EasyTier tcp_stun_servers（逗号分隔）'),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(nc.tcpStunServers.watch(context).join(',')),
              initialValue: nc.tcpStunServers.watch(context).join(','),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateTcpStunServers(
                  _splitList(value),
                );
              },
            ),
          ),
        ),
        _divider(),
        ListTile(
          title: Text('IPv6 STUN 服务器'),
          subtitle: Text('EasyTier stun_servers_v6（逗号分隔）'),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(nc.stunServersV6.watch(context).join(',')),
              initialValue: nc.stunServersV6.watch(context).join(','),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateStunServersV6(
                  _splitList(value),
                );
              },
            ),
          ),
        ),
        _divider(),
        ListTile(
          title: Text('手动路由'),
          subtitle: Text('EasyTier routes（CIDR，逗号分隔，如 10.0.0.0/16）'),
          trailing: SizedBox(
            width: 160,
            child: TextFormField(
              key: ValueKey(nc.manualRoutes.watch(context).join(',')),
              initialValue: nc.manualRoutes.watch(context).join(','),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                ServiceManager().networkConfig.updateManualRoutes(
                  _splitList(value),
                );
              },
            ),
          ),
        ),
        _divider(),
        SwitchListTile(
          title: Text('安全模式'),
          subtitle: Text('EasyTier secure_mode，使用 X25519 密钥认证'),
          value: nc.secureModeEnabled.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateSecureModeEnabled(value);
          },
        ),
        if (nc.secureModeEnabled.watch(context)) ...[
          ListTile(
            title: Text('X25519 私钥'),
            subtitle: Text('base64 私钥（可选）'),
            trailing: SizedBox(
              width: 160,
              child: TextFormField(
                key: ValueKey(nc.localPrivateKey.watch(context)),
                initialValue: nc.localPrivateKey.watch(context),
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) {
                  ServiceManager().networkConfig.updateLocalPrivateKey(
                    value.trim(),
                  );
                },
              ),
            ),
          ),
          ListTile(
            title: Text('X25519 公钥'),
            subtitle: Text('base64 公钥（可选）'),
            trailing: SizedBox(
              width: 160,
              child: TextFormField(
                key: ValueKey(nc.localPublicKey.watch(context)),
                initialValue: nc.localPublicKey.watch(context),
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) {
                  ServiceManager().networkConfig.updateLocalPublicKey(
                    value.trim(),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 逗号分隔字符串转为列表
List<String> _splitList(String value) {
  return value
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

/// MTU / Hop 设置卡片
class NetworkHopSettingsCard extends StatelessWidget {
  const NetworkHopSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _settingsCard(
      children: [
        SwitchListTile(
          title: Text(LocaleKeys.auto_set_hop.tr()),
          subtitle: Text(LocaleKeys.auto_set_hop_desc.tr()),
          value: ServiceManager().networkConfigState.autoSetMTU.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.setAutoSetMTU(value);
          },
        ),
        _divider(),
        ListTile(
          leading: const Icon(Icons.list),
          title: Text(LocaleKeys.view_hop_list.tr()),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showHopList(context),
        ),
      ],
    );
  }
}

Future<void> showHopList(BuildContext context) async {
  try {
    final result = await getAllInterfacesMetrics();
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.network_adapter_hop_list.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    result
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('${e.$1}: ${e.$2}'),
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.close.tr()),
              ),
            ],
          ),
    );
  } catch (e) {
    if (!context.mounted) return;
    AppSnackBars.error(context, '错误', LocaleKeys.get_hop_list_failed.tr());
  }
}
