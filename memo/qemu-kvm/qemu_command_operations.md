## QEMU仮想マシンの操作方法メモ

### 仮想マシンのエクスポート方法
1. 仮想マシン一覧を確認する
```bash
sudo qm list
```
```bash
  VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
  1001 windows11            stopped    32768            480.00 0         
  4002 UbuntuServer         stopped    16384             32.00 0         
  9990 FedoraServer         running    16384            256.00 2250
```

2. 仮想マシン情報を確認する
```bash
sudo qm config 4002
```
```bash
  agent: 1
  bios: ovmf
  boot: order=scsi0;net0
  cores: 4
  cpu: host
  efidisk0: local-lvm:vm-4002-disk-0,efitype=4m,size=4M
  machine: q35
  memory: 16384
  meta: creation-qemu=9.2.0,ctime=1743183156
  name: UbuntuServer
  net0: virtio=BC:24:11:41:89:96,bridge=vmbr0,firewall=1
  numa: 0
  ostype: l26
  scsi0: local-lvm:vm-4002-disk-1,iothread=1,size=32G
  scsihw: virtio-scsi-single
  smbios1: uuid=971b23c4-83e0-4326-8401-a7f7ea45c63d
  sockets: 1
  vmgenid: f5fef1e7-bc9d-4f67-b749-51346cea02cf
```

3. 仮想マシンの論理ボリュームのパスを確認する
```bash
sudo lvdisplay | grep 4002
```
```bash
  LV Path                /dev/local-lvm/vm-4002-disk-0
  LV Name                vm-4002-disk-0
  LV Path                /dev/local-lvm/vm-4002-disk-1
  LV Name                vm-4002-disk-1
```

4. 仮想マシンをQCOW2イメージでエクスポートする（EFIディスクのエクスポートは不要）
```bash
sudo qemu-img convert -O qcow2 /dev/local-lvm/vm-3002-disk-1 ~/ubuntuserver.qcow2  
```
```bash
Usage: qemu-img convert [-O output_format] <input_image_file> <output_image_file>
```

---

### ProxmoxにQCOW2イメージをインポートする
1. エクスポートした仮想マシンのQCOW2イメージを転送する  
scpコマンド等を使ってイメージファイルをproxmoxに転送する

2. Proxmoxに移行先のVMを作成する  
ブラウザからエクスポート方法の項番2で確認した仮想マシン情報を参考に作成する  
ただし、メディアは不要、ディスクは不要(初期設定のディスクを削除)

3. QCOW2イメージを作成した仮想マシンにインポートする
```bash
sudo qm importdisk 101 ubuntuserver.qcow2 local-lvm
```
```bash
Usage: qm importdisk <VMID> <input_image_file> <論理ボリューム名>
```

4. インポートしたディスクの有効化  
ブラウザから仮想マシンを選択し、「ハードウェア」->「未使用のディスク」->「編集」->「OK」を押下しディスクを有効化する

5. 起動順序設定  
ブラウザから仮想マシンを選択し、「オプション」->「ブート順」->「編集」を押下し有効化したディスクの起動順が1番となるように順序を変更する

---

### ProxmoxにOVAファイルをインポートする
1. ovaファイルをovfファイル、vmdkファイルに展開する
```bash
tar -xvf <filename>.ova
```

2. 展開したVMDKファイルをProxmoxに転送する  
scpコマンド等を使ってvmdkファイルをproxmoxに転送する

3. Proxmoxに移行先のVMを作成する  
ブラウザから仮想マシンを作成する(移行元の仮想マシン情報が分かる場合は参考とすること)  
ただし、メディアは不要、ディスクは不要(初期設定のディスクを削除)

4. VMDKファイルを作成した仮想マシンにインポートする
```bash
sudo qm importdisk -f qcow2 <VMID> <filename>.vmdk <論理ボリューム名>
```

5. インポートしたディスクの有効化  
ブラウザから仮想マシンを選択し、「ハードウェア」->「未使用のディスク」->「編集」->「OK」を押下しディスクを有効化する

6. 起動順序設定  
ブラウザから仮想マシンを選択し、「オプション」->「ブート順」->「編集」を押下し有効化したディスクの起動順が1番となるように順序を変更する

---
