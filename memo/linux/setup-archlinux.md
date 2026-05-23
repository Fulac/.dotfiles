# Arch Linuxのインストール手順

## キーボードレイアウト
【英字キーボードの場合は不要】日本語キーボード配列を切り替える
```bash
loadkeys jp106
```

## 起動モードの確認
本手順は起動モードがUEFIであることを前提とする
```bash
ls /sys/firmware/efi
```
実行結果に`efivars`というディレクトリがあればOK

## パーティションの作成
ここでは以下のパーティション構成とする
|パーティション |サイズ   |フォーマット |マウントポイント |
|---------------|---------|-------------|-----------------|
|/dev/nvme0n1p1 |1G       |FAT32        |/boot            |
|/dev/nvme0n1p2 |残り全部 |btrfs        |/                |
- ディスクの初期化
```bash
sgdisk -z /dev/sda
```
- /boot用パーティションの作成
```bash
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI-System" /dev/nvme0n1
```
- ルートディレクトリ用パーティションの作成
```bash
sgdisk -n 2:0: -t 2:8300 -c 2:"ARCH-ROOT" /dev/nvme0n1
```

## パーティションのフォーマット
```bash
mkfs.vfat -F32 /dev/nvme0n1p1
mkfs.btrfs /dev/nvme0n1p2
```

## パーティションのマウント
```bash
mount /dev/nvme0n1p1 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p2 /mnt/boot
```

## 【有線LAN接続の場合は不要】無線LAN接続
- 利用可能な無線インターフェースリストを取得する
```bash
iwctl device list
```
```bash
(出力例)                            Devices
--------------------------------------------------------------------------------
  Name                Address             Powered   Adapter   Mode
--------------------------------------------------------------------------------
  wlan0               xx:xx:xx:xx:xx:xx   on        phy0      station
```

- 利用可能な無線ネットワークのスキャン
```bash
iwctl station wlan0 scan
```

- スキャンした無線ネットワークの出力
```bash
iwctl station wlan0 get-networks
```
```bash
(出力例)                      Available networks
--------------------------------------------------------------------------------
  Network name                    Security          Signal
--------------------------------------------------------------------------------
  valinor                         psk               ****
  arda                            psk               ****
```

- 無線ネットワークに接続
```bash
iwctl station wlan0 connect arda --passphrase mysupersecretpassphrase
```

- 接続した無線ネットワークの情報確認
```bash
iwctl station wlan0 show
```

## ArchLinuxのインストール
- ネットワークの疎通確認  
インターネットに接続できることを確認する
```bash
ping archlinux.org
```

- リポジトリの選択  
日本のリポジトリを優先するために`/etc/pacman.d/mirrorlist`に以下の文を上に追記する
```bash
Server = http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/$repo/os/$arch
```

- パッケージのインストール  
intel-cpuの場合は`intel-ucode`、amd-cpuの場合は`amd-ucode`をインストールする
```bash
pacstrap /mnt base base-devel linux linux-headers linux-firmware intel-ucode dosfstools efibootmgr vi vim wpa_supplicant networkmanager dialog
```

- fstabの作成
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

- chroot  
`arch-chroot`コマンドでrootの作業場所を変更する
```bash
arch-chroot /mnt
```

- Localeの設定  
`/etc/locale.gen`をvimで開き、`en_US.UTF-8 UTF-8`と`ja_JP.UTF-8 UTF-8`の行のコメントを解除し、`locale-gen`コマンドを実行する
```bash
...
en_US.UTF-8 UTF-8
...
ja_JP.UTF-8 UTF-8
...
```
```bash
locale-gen
```
LANG環境変数を設定するため、`/etc/locale.conf`を作成し、以下の値を入力する
```bash
echo "LANG=en_US.UTF-8 UTF-8" > /etc/locale.conf
```
【英字キーボードの場合不要】日本語キーボードを利用する場合は以下の値を`/etc/vconsole.conf`に記載する
```bash
echo "KEYMAP=jp106" > /etc/vconsole.conf
```

## timezoneの設定
timezoneを日本に設定する
```bash
tzselect
# 次に5、21、1と入力
# 番号配置が変更されることがあるので注意
```
`/usr/share/zoneinfo`ディレクトリ配下に`/etc/localtime`シンボリックリンクを作成する
```bash
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
```
ハードウェアクロックの時間のズレを修正する
```bash
hwclock --systohc --utc
```

## hostnameの設定
`/etc/hostname`と`/etc/hosts`を編集してhostnameを設定する
```bash
echo "hostname" > /etc/hostname
```
```bash
127.0.0.1  localhost
::1        localhost
127.0.1.1  hostname
```

## initramfsイメージの作成
```bash
mkinitcpio -p linux
```

## rootパスワードの設定
`passwd`コマンドでrootのパスワードを設定する
```bash
passwd
```

## BootLoaderの設定
### PT-1: systemd-bootを利用する場合
- systemd-bootをインストールする
```bash
bootctl install
```

- 自動更新設定
`systemd-boot-update.service`を有効化する
```bash
systemctl enable systemd-boot-update.service
```
pacmanフックを追加する。`/etc/pacman.d/hooks/`に手動でファイルを配置する(ex.`/etc/pacman.d/hooks/95-systemd-boot.hook`)
```bash
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Gracefully upgrading systemd-boot...
When = PostTransaction
Exec = /usr/bin/systemctl restart systemd-boot-update.service
```

- ローダー設定
`/boot/loader/loader.conf`に以下の内容を記載する
```bash
default       arch.conf
timeout       3
console-mode  max
editor        no
```

- rootディレクトリのUUID確認
`lsblk -f`コマンドでrootディレクトリのUUIDを確認する
```bash
NAME        FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
nvme0n1                                                                            
├─nvme0n1p1 vfat   FAT32       </bootのUUID>                         434.2M    15% /boot
└─nvme0n1p2 btrfs              </(rootディレクトリ)のUUID>             1.7T     4% /
```

- ブートエントリの作成
`/boot/loader/entries/arch.conf`ファイルを作成して以下の値を記載する
```bash
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
initrd  /intel-ucode.img (または /amd-ucode.img)
options root=UUID=</(root)ディレクトリのUUID> rw rootflags=subvol=/
```

### PT-2: GRUB2を利用する場合
- grubをインストール
```bash
pacman -S grub
```

- grubの設定
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch --recheck
```
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

## Boot設定の確認
`efibootmgr`コマンドでブート設定が反映されていることを確認する
```bash
# systemd-bootを利用した場合の出力例
BootCurrent: 0001
Timeout: 0 seconds
BootOrder: 0001
Boot0001* UEFI OS       HD(1,GPT,225ca0b6-58bb-49a4-aee0-1bce7a0f8762,0x800,0x100000)/\EFI\BOOT\BOOTX64.EFI0000424f
```
上記のような表示がされていれば恐らくOK


## システム再起動
以下のコマンドを実行後、インストールメディアを抜いて正常に起動するか確認する
```bash
exit
shutdown -h now
```

# インストール後のセットアップ
以降`root`ユーザにログインして設定を行う

## ユーザの作成
ユーザ作成時に`wheel`グループに追加する場合は`-G wheel`を記載する
```bash
useradd -m <ユーザ名> -G wheel
passwd <ユーザ名>
```

## ネットワークの有効化
NetworkManager.serviceを起動する
```bash
systemctl enable --now NetworkManager
```

## sudo設定
- `sudo`パッケージのインストール
```bash
pacman -S sudo
```

- `wheel`グループに属するユーザに`sudo`実行権限を付与  
`visudo`コマンドを利用して以下をコメントアウトする
```bash
## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL:ALL) ALL <-- Uncomment
```

## pacmanの設定
- カラー設定、並列ダウンロード  
`/etc/pacman.conf`の以下の項をアンコメントする
```bash
(省略)
Color
(省略)
VerbosePkgLists
(省略)
ParallelDownloads = 5
(省略)
```

- Multilibの有効化  
Multilibを有効化することで32bitアプリケーションの使用が可能となる  
`/etc/pacman.conf`の`[multilib]`の項をアンコメントする
```bash
(省略)
[multilib]
Include = /etc/pacman.d/mirrorlist
(省略)
```

- Mirrorlistの最適化
`reflector`のインストール
```bash
pacman -S reflector
```
24時間以内に同期が行われた日本のhttpsサーバをMirrorlistに保存する
```bash
reflector --country 'Japan' --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

- 自動キャッシュ削除  
`pacman-contrib`をインストールする
```bash
pacman -S pacman-contrib
```
`paccache.timer`を有効化する
```bash
systemcts enable --now paccache.timer
```

## ユーザの切り替え
`exit`をして`root`ユーザから作成したユーザに切り替える

## AURヘルパーのインストール
`yay`をインストールする。`root`ユーザでは利用できないため先ほど作成したユーザに切り替えてから実行する
```bash
sudo pacman -S git go
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```
`make`後は`git clone`した`yay`ディレクトリを削除して問題ない

## GUI環境のインストール
KDE Plasmaを利用する
```bash
yay -S acpid sddm plasma konsole dolphin
sudo systemctl enable sddm
```

## 日本語設定
- 日本語フォントのインストール
```bash
yay -S noto-fonts-cjk ttf-bizin-gothic
```

- 日本語インプットメソッドのインストール
```bash
yay -S fcitx5 fcitx5-mozc fcitx5-configtool
```

- 環境設定
`/etc/environment`に以下の設定を記載する
```bash
XMODIFIERS=@im=fcitx
```

