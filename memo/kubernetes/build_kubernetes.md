## kubernetesの構築メモ

### 利用ソフトウェア
- HostOS：Fedora42
- CRI：cri-o
- CNI：cilium

---
### NetworkManagerのDNS設定が`/etc/resolve.conf`に反映されない問題の対処
Fedora41において`resolve.conf`にDNS設定が反映されず参照先がlocalhostとなっているため、corednsがCrashLoopBackOffとなって起動できない問題の対処方法
```bash
sudo mkdir -p /etc/systemd/resolved.conf.d/
sudo cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/stub-listener.conf
[Resolve]
DNSStubListener=no
EOF
```

---
### kubernetes(マスターノード)の構築
参考：[Fedora公式ドキュメント](https://docs.fedoraproject.org/en-US/quick-docs/using-kubernetes-kubeadm/)
1. パッケージの最新化
```bash
sudo dnf upgrade
```

2. スワップメモリの無効化
```bash
sudo dnf remove zram-generator-defaults
sudo reboot now
```

3. ファイアウォールの無効化
```bash
sudo systemctl disable --now firewalld
```

4. iptables, iproute-tcのインストール
```bash
sudo dnf install iptables iproute-tc
```

5. カーネルモジュール(overlay, br_netfilter)の起動時自動読み込み設定
```bash
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

6. カーネルモジュール(overlay, br_netfilter)の有効化
```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```

7. カーネルパラメータの永続設定
```bash
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

8. システム設定(カーネルパラメータ)の再読込
```bash
sudo sysctl --system
```

9. overlay, br_netfileterが正常に読み込めていることを確認  
overlay, br_netfilterが表示さればOK
```bash
lsmod | grep br_netfilter
lsmod | grep overlay
```

10. ネットワークモジュールのパラメータ値確認  
値が'1'であることを確認する
```bash
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

11. コンテナランタイムのインストール  
```bash
sudo dnf install cri-o crun containernetworking-plugins
```

12. kubernetesのインストール
```bash
sudo dnf install kubernetes kubernetes-kubeadm
```

13. cri-oの起動
```bash
sudo systemctl enable --now crio
```

14. kubernetesで利用するイメージのダウンロード
```bash
sudo kubeadm config images pull
```

15. kubeletの起動
```bash
sudo systemctl enable --now kubelet
```

16. kubernetesクラスタの初期化  
CNIにciliumを利用するためkube-proxyの起動を抑止する
```bash
sudo kubeadm init --skip-phases=addon/kube-proxy
```

17. kubernetesクラスタ操作権限をユーザに追加
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---
### Cilium(CNI)のインストールと起動
参考：[cilium公式ドキュメント](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/)
1. cilium cliのインストール
```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

2. ciliumのインストール
```bash
cilium install --version 1.17.2
```

3. cilium起動状態の確認  
Cilium, OperatorのステータスがOKとなるまで待機
```bash
cilium status --wait
```

4. hubbleの有効化  
ワーカーノードをクラスタに追加するまでは正常に起動しない
```bash
cilium hubble enable --ui
```

---
### kubernetes(ワーカーノード)の構築
1. パッケージの最新化
```bash
sudo dnf upgrade
```

2. スワップメモリの無効化
```bash
sudo dnf remove zram-generator-defaults
sudo reboot now
```

3. ファイアウォールの無効化
```bash
sudo systemctl disable --now firewalld
```

4. iptables, iproute-tcのインストール
```bash
sudo dnf install iptables iproute-tc
```

5. カーネルモジュール(overlay, br_netfilter)の起動時自動読み込み設定
```bash
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

6. カーネルモジュール(overlay, br_netfilter)の有効化
```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```

7. カーネルパラメータの永続設定
```bash
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

8. システム設定(カーネルパラメータ)の再読込
```bash
sudo sysctl --system
```

9. overlay, br_netfileterが正常に読み込めていることを確認  
overlay, br_netfilterが表示さればOK
```bash
lsmod | grep br_netfilter
lsmod | grep overlay
```

10. ネットワークモジュールの状態確認  
モジュールが有効状態「1」であることを確認する
```bash
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

11. コンテナランタイムのインストール
```bash
sudo dnf install cri-o crun containernetworking-plugins
```

12. kubernetesのインストール
```bash
sudo dnf install kubernetes
```

13. cri-oの起動
```bash
sudo systemctl enable --now crio
```

14. kubeletの起動
```bash
sudo systemctl enable --now kubelet
```

15. kubernetesクラスタへのJoinコマンドを生成  
マスターノード側で下記コマンドを実行する
```bash
kubeadm token create --print-join-command
```
16. 15で出力されたコマンドをクラスタに追加したいワーカーノードで実行する (sudoコマンドを付ける)
```bash
(例) sudo kubeadm join <MaterNode IPaddr>:6443 --token <TokenStr> --discovery-token-ca-cert-hash <HashValue>
```

