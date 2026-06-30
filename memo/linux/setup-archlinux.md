# Arch Linux インストール手順（btrfs subvolume / Snapper 構成）

> 本手順書は UEFI 起動・NVMe SSD・btrfs（subvolume 分割）を前提とする。
> デバイス名（`/dev/nvme0n1`）・ホスト名・ユーザ名は環境に合わせて読み替えること。

## 前提・ターゲット構成

### パーティション

| パーティション | サイズ | フォーマット | マウントポイント |
|----------------|--------|--------------|------------------|
| /dev/nvme0n1p1 | 1G     | FAT32 (ESP)  | /boot            |
| /dev/nvme0n1p2 | 残り全部 | btrfs      | /（subvolume 構成）|

### btrfs subvolume レイアウト（Snapper 互換）

| subvol      | マウントポイント            | 目的 |
|-------------|-----------------------------|------|
| `@`         | `/`                         | ロールバック対象のルート |
| `@home`     | `/home`                     | ユーザデータをルートのロールバックから分離 |
| `@log`      | `/var/log`                  | ロールバック時にログを失わない |
| `@pkg`      | `/var/cache/pacman/pkg`     | パッケージキャッシュをスナップショットに含めない |
| `@snapshots`| `/.snapshots`               | Snapper 格納先。再帰スナップショットを回避 |

`/boot`（ESP / FAT32）は btrfs 外のため、スナップショットの対象外となる。

---

## キーボードレイアウト
【英字キーボードの場合は不要】日本語キーボード配列に切り替える
```bash
loadkeys jp106
```

## 起動モードの確認
本手順は起動モードが UEFI であることを前提とする
```bash
ls /sys/firmware/efi/efivars
```
ディレクトリ内にファイルが列挙されれば UEFI で起動している。

## パーティションの作成
- ディスクの初期化
```bash
sgdisk -z /dev/nvme0n1
```
- /boot 用（ESP）パーティションの作成
```bash
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI-System" /dev/nvme0n1
```
- ルート用パーティションの作成
```bash
sgdisk -n 2:0:0 -t 2:8300 -c 2:"ARCH-ROOT" /dev/nvme0n1
```

## パーティションのフォーマット
```bash
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.btrfs -f -L ARCH /dev/nvme0n1p2
```

## btrfs subvolume の作成
トップレベルを一時マウントして subvolume を作成する。
```bash
mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@snapshots
umount /mnt
```
作成結果の確認（任意）
```bash
mount /dev/nvme0n1p2 /mnt && btrfs subvolume list /mnt && umount /mnt
```

## subvolume のマウント
マウントオプションは NVMe / SSD 前提。圧縮は `zstd:1`（高速寄り）、`discard=async` で継続 TRIM を行う。
```bash
# マウントオプションを変数化（このシェルセッション内のみ有効）
BTRFS_OPTS="noatime,compress=zstd:1,ssd,discard=async"

# ルート（@）
mount -o ${BTRFS_OPTS},subvol=@ /dev/nvme0n1p2 /mnt

# マウントポイントを作成
mkdir -p /mnt/{home,var/log,var/cache/pacman/pkg,.snapshots,boot}

# 各 subvolume をマウント
mount -o ${BTRFS_OPTS},subvol=@home      /dev/nvme0n1p2 /mnt/home
mount -o ${BTRFS_OPTS},subvol=@log       /dev/nvme0n1p2 /mnt/var/log
mount -o ${BTRFS_OPTS},subvol=@pkg       /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg
mount -o ${BTRFS_OPTS},subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots

# ESP（/boot）
mount /dev/nvme0n1p1 /mnt/boot
```
> **注意**: ここで全 subvolume をマウントしておくことが重要。後の `genfstab` は「マウント済みの構成」を fstab に書き出すため、マウント漏れがあると fstab に反映されない。

## 【有線 LAN 接続の場合は不要】無線 LAN 接続
- 利用可能な無線インターフェースの確認
```bash
iwctl device list
```
- 無線ネットワークのスキャンと一覧
```bash
iwctl station wlan0 scan
iwctl station wlan0 get-networks
```
- 無線ネットワークに接続
```bash
iwctl station wlan0 connect <SSID> --passphrase <PASSPHRASE>
```
- 接続状態の確認
```bash
iwctl station wlan0 show
```

## ネットワーク疎通確認
```bash
ping -c 3 archlinux.org
```

## ミラーの最適化（ライブ環境）
公式 ISO に同梱の `reflector` でミラーリストを生成する。
```bash
reflector --country Japan --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

## パッケージのインストール
共通パッケージ群をインストールする。`pacstrap -K` でキーリングを初期化する。
```bash
pacstrap -K /mnt \
  base base-devel linux linux-headers linux-firmware \
  btrfs-progs dosfstools efibootmgr \
  networkmanager \
  vim git sudo \
  sof-firmware
```

CPU ベンダに応じて microcode を追加する。
```bash
# Intel CPU の場合
pacstrap /mnt intel-ucode

# AMD CPU の場合
pacstrap /mnt amd-ucode
```

## fstab の作成
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```
生成後、各 subvolume が `subvol=/@...` 付きで記載されているか確認する。
```bash
cat /mnt/etc/fstab
```

## chroot
```bash
arch-chroot /mnt
```

## Locale の設定
`/etc/locale.gen` を編集し、`en_US.UTF-8 UTF-8` と `ja_JP.UTF-8 UTF-8` のコメントを解除する。
```bash
vim /etc/locale.gen
```
```
...
en_US.UTF-8 UTF-8
...
ja_JP.UTF-8 UTF-8
...
```
ロケールを生成する。
```bash
locale-gen
```
`LANG` を設定する。
```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```
【英字キーボードの場合は不要】コンソール用キーマップを設定する。
```bash
echo "KEYMAP=jp106" > /etc/vconsole.conf
```

## timezone の設定
タイムゾーンのシンボリックリンクを作成し、ハードウェアクロックを同期する。
```bash
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc
```

## hostname の設定
```bash
echo "myhost" > /etc/hostname
```
`/etc/hosts` を編集する。
```bash
vim /etc/hosts
```
```
127.0.0.1   localhost
::1         localhost
127.0.1.1   myhost.localdomain myhost
```

## initramfs イメージの作成
全プリセットを再生成する。
```bash
mkinitcpio -P
```

## root パスワードの設定
```bash
passwd
```

## ユーザの作成（chroot 内で実施）
`wheel` グループに追加する。`sudo` はインストール済み。
```bash
useradd -m -G wheel <ユーザ名>
passwd <ユーザ名>
```
`wheel` グループに sudo 権限を付与する。`visudo` で以下の行をアンコメントする。
```bash
EDITOR=vim visudo
```
```
## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL:ALL) ALL   # <- アンコメント
```

## BootLoader の設定

> **スナップショットからの起動メニュー連携**を使う場合は **PT-2（GRUB + grub-btrfs）を推奨**。
> systemd-boot（PT-1）はシンプルだが、Snapper のスナップショットをブートメニューに自動列挙する機能は持たない（代替として `limine` + `limine-snapper-sync` 等がある）。

### PT-1: systemd-boot を利用する場合
- インストールと自動更新サービスの有効化
```bash
bootctl install
systemctl enable systemd-boot-update.service
```
- ローダー設定 `/boot/loader/loader.conf`
```
default       arch.conf
timeout       3
console-mode  max
editor        no
```
- ルートの UUID を確認
```bash
lsblk -f
```
- ブートエントリ `/boot/loader/entries/arch.conf` を作成する。**btrfs subvolume 構成のため `rootflags=subvol=@` が必須**。

Intel CPU の場合:
```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=<ルートのUUID> rw rootflags=subvol=@
```
AMD CPU の場合（microcode 行のみ差し替え）:
```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=UUID=<ルートのUUID> rw rootflags=subvol=@
```

### PT-2: GRUB + grub-btrfs を利用する場合（推奨）
- インストール
```bash
pacman -S grub efibootmgr grub-btrfs inotify-tools
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch --recheck
```
- 設定生成
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```
> grub-mkconfig は次を自動で処理する:
> - ルートが subvolume `@` 上にあることを検出し、カーネル行に `rootflags=subvol=@` を付与する
> - `intel-ucode.img` / `amd-ucode.img` を検出し、early initrd として組み込む（**手動エントリ不要**）
>
> 念のため、生成された `/boot/grub/grub.cfg` に `rootflags=subvol=@` と microcode の initrd 行が含まれているか確認すること。

## Boot 設定の確認
```bash
efibootmgr
```
- systemd-boot の場合: `Linux Boot Manager` エントリが登録される。
- GRUB の場合: `arch`（`--bootloader-id` で指定した名前）が登録される。

## システム再起動
chroot を抜け、アンマウントして再起動する。インストールメディアを抜くこと。
```bash
exit
umount -R /mnt
reboot
```

---

# インストール後のセットアップ
作成したユーザでログインして設定を行う（sudo 利用）。

## ネットワークの有効化
```bash
sudo systemctl enable --now NetworkManager
```
接続（CLI の例）:
```bash
nmcli device wifi connect <SSID> password <PASSPHRASE>
```

## pacman の設定
`/etc/pacman.conf` を編集する。
```bash
sudo vim /etc/pacman.conf
```
- 以下をアンコメント
```
Color
VerbosePkgLists
ParallelDownloads = 5
```
- Multilib の有効化（32bit アプリ用。Steam 等で必要）
```
[multilib]
Include = /etc/pacman.d/mirrorlist
```
- ミラー最適化と自動キャッシュ削除
```bash
sudo pacman -S reflector pacman-contrib
sudo reflector --country Japan --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo systemctl enable --now paccache.timer
```

## swap（zram）
btrfs と相性が良い zram を利用する（物理スワップファイルは作らない）。
```bash
sudo pacman -S zram-generator
```
`/etc/systemd/zram-generator.conf` を作成する。
```ini
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
```
反映する。
```bash
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
```
確認:
```bash
zramctl
swapon --show
```
> **TRIM について**: マウントオプションで `discard=async` を採用しているため、`fstrim.timer` の有効化は不要（二重実行になる）。`discard=async` を外す方針に変えた場合のみ `sudo systemctl enable --now fstrim.timer` を行う。

## AUR ヘルパーのインストール（paru）
AUR が必要なものだけ `paru` を使う。`root` では実行不可のため作成したユーザで行う。
```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd .. && rm -rf paru   # ビルド後は削除可
```

## GUI 環境のインストール（KDE Plasma）
KDE Plasma / SDDM / 各種ツールを `pacman` で導入する。
```bash
sudo pacman -S plasma-meta sddm konsole dolphin
sudo systemctl enable sddm
```
> 最小構成にしたい場合は `plasma-meta` の代わりに `plasma-desktop` を選択する。

## 日本語設定
- 日本語フォント（`ttf-bizin-gothic` は AUR）
```bash
sudo pacman -S noto-fonts-cjk noto-fonts-emoji
paru -S ttf-bizin-gothic   # Nerd Font 版が必要なら ttf-bizin-gothic-nf 等を選択
```
- 日本語インプットメソッド（fcitx5。公式リポジトリで導入）
```bash
sudo pacman -S fcitx5-im fcitx5-mozc
```
> `fcitx5-im` グループに `fcitx5` 本体・`fcitx5-configtool`・`fcitx5-qt`・`fcitx5-gtk` が含まれる。

### Plasma 6（Wayland）での有効化
fcitx5 は Wayland フロントエンドが既定で有効で、ネイティブ Wayland アプリは text-input 経由で動作する。環境変数の全体設定は行わず、以下の手順で有効化する。

1. **必須**: System Settings →「キーボード」→「仮想キーボード」で **Fcitx 5** を選択する（KWin が fcitx5 を起動し、Wayland の text-input を有効化する。これを行わないと Wayland ネイティブアプリで入力できない）。
2. **任意**: XWayland / 旧 X11 アプリ向けのフォールバックが必要な場合のみ、`~/.config/environment.d/im.conf` を作成する。
```ini
# XWayland / 旧 X11 アプリ向けフォールバック
GTK_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
# QT_IM_MODULE は KDE Wayland では設定しない（text-input を使うため空が推奨）
```
反映には再ログイン（または再起動）が必要。設定後は任意のアプリで `Ctrl+Space` で入力切替を確認する。

---

# 任意: Snapper によるスナップショット運用
ルート（`@`）の自動スナップショットと、pacman 操作時の自動スナップショットを設定する。
```bash
sudo pacman -S snapper snap-pac
```

## ルート設定の作成（@snapshots レイアウトとの整合）
snapper は `create-config` 時に独自の `.snapshots` subvolume を作ろうとするため、既に用意した `@snapshots`（`/.snapshots`）と衝突する。以下の手順で整合させる。
```bash
# 1. 先に用意した @snapshots を一旦退避
sudo umount /.snapshots
sudo rmdir /.snapshots

# 2. snapper の設定作成（この時点で snapper が /.snapshots subvolume を新規作成する）
sudo snapper -c root create-config /

# 3. snapper が作った /.snapshots を削除し、用意済みの @snapshots を使うよう戻す
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo mount -a            # fstab の @snapshots を再マウント
sudo chmod 750 /.snapshots
```
自動スナップショット用タイマーを有効化する。
```bash
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```
動作確認:
```bash
sudo snapper -c root list
```

## grub-btrfs によるブートメニュー連携（PT-2 / GRUB 利用時）
スナップショットの変化を監視し、GRUB メニューへ自動反映するデーモンを有効化する。
```bash
sudo systemctl enable --now grub-btrfsd
```
> 既定で `snapper` の `/.snapshots` を監視する設定になっている。スナップショット作成後、GRUB のサブメニューから過去スナップショット（読み取り専用）を起動できる。本構成は `rootflags=subvol=@` を固定しているため `snapper rollback` のワンコマンドでは `/` を巻き戻せない。`/` の復元は末尾の「付録: `/`（@ サブボリューム）の復元手順」に従う。

---

# 付録: `/`（@ サブボリューム）の復元手順

本手順書はカーネル行で `rootflags=subvol=@` を固定する構成（起動するサブボリュームをパス名で名指しする方式）を採用している。この方式では `snapper rollback` が行う「デフォルトサブボリュームの切り替え」が無視されるため、`/` の巻き戻しはワンコマンドではなく、**`@` の中身をスナップショットで作り直して入れ替える**手順で行う。`@snapshots` を `@` の外側に分離してあるため、`@` を置き換えてもスナップショットは失われない。

## 手順
ライブ環境からトップレベル（subvolid=5）を直接操作する方法が、システムが起動しなくても使えて確実。

```bash
# 1. Arch ISO のライブ USB で起動する
#    （grub-btrfs があれば、先に GRUB メニューから正常な時点のスナップショットを
#     起動して復元先の番号を確認しておくとよい。起動したスナップショットは読み取り専用）

# 2. btrfs のトップレベル（subvolid=5）をマウントする（subvol 指定を付けない）
mount /dev/nvme0n1p2 /mnt

# 3. 復元したいスナップショット番号を特定する
ls /mnt/@snapshots
cat /mnt/@snapshots/<番号>/info.xml   # date（UTC）と説明（pre/post 等）を確認

# 4. 現在の @ を退避し、選んだスナップショットから書き込み可能な新しい @ を作成する
mv /mnt/@ /mnt/@.broken
btrfs subvolume snapshot /mnt/@snapshots/<番号>/snapshot /mnt/@

# 5. アンマウントして再起動する
umount /mnt
reboot
```
> `rootflags=subvol=@` は「`@` という名前のサブボリューム」を指すため、中身を入れ替えても起動方式と矛盾しない。新しい `@` は読み書き可能なため、そのまま通常運用に戻れる。

## 後始末
正常起動を確認したら、退避した旧 `@` を削除する。
```bash
# 別環境（ライブ USB 等）でトップレベルをマウントして削除する
mount /dev/nvme0n1p2 /mnt
btrfs subvolume delete /mnt/@.broken
umount /mnt
```

## 注意点
- snap-pac の更新事故から戻す場合は、更新直前の **pre スナップショット**を選ぶ（`info.xml` の説明やタイムスタンプで判別）。
- `/boot`（カーネル / initramfs）は ESP 上にあり `@` の外のため復元されない。**カーネル更新が原因**で戻す場合、復元後の `@` が持つモジュール（`/usr/lib/modules/<旧版>`）と `/boot` の現行カーネルがずれることがある。その場合は復元後に該当カーネルを再インストールして整合させる（例: `pacman -S linux`）。
- `/home` は `@home` として分離しているため、この手順では戻らない。`/home` の復元が必要な場合は `@home` 用に別途 snapper config を作成し、同様にサブボリューム単位で扱う。
