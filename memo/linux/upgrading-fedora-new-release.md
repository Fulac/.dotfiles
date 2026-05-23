## Fedoraの新リリースバージョンへのアップグレード方法(ex.41 to 42)

1. 現バージョンの最終アップデート
```bash
sudo dnf upgrade --refresh
```
```bash
sudo reboot -n
```

2. DNFアップグレードパッケージのインストール
```bash
sudo dnf install dnf-plugin-system-upgrade
```

3. Fedora新バージョンのダウンロード
```bash
sudo dnf system-upgrade download --releasever=42
```

4. ダウンロード後、リブートして更新
```bash
sudo dnf system-upgrade reboot
```

5. 古いパッケージの削除
```bash
sudo dnf install remove-retired-packages
```
```bash
sudo remove-retired-packages 41
```

6. RPMコンフィグの更新
必要に応じてユーザ設定をデフォルトの設定にマージする
```bash
sudo dnf install rpmconf
```
```bash
sudo rpmconf -a
```
