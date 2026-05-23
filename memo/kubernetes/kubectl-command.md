## 【kubectl】でよく使うコマンド

## マニフェストの作成/削除/更新(create/delete/apply)
- リソースの作成  
既に存在する場合はエラーが発生する
```bash
kubectl create -f XXX.yml
```
- リソースの削除  
即時矯正削除は、`--grace-period 0 --force` を利用する
```bash
kubectl delete -f XXX.yml
```
- リソースの更新  
リソースが存在しない場合はリソースの新規作成も行われる
```bash
kubectl apply -f XXX.yml
```

## リソースの情報取得(get)
- Podの一覧を取得(詳細出力)
```bash
kubectl get pods -o wide
```

- ノードの一覧を取得(詳細出力)
```bash
kubectl get nodes -o wide
```

- 全リソースの情報を取得(詳細出力)
```bash
kubectl get all -o wide
```

## リソースの詳細情報の取得(describe)
- Podの詳細情報を取得
```bash
kubectl describe -n <namespace> <pod_name>
```

## Podのログ確認(logs)
- Podのログ確認
```bash
kubectl logs -n <namespace> <pod_name>
```

## Podの手動再起動(rollout)
- NameSpace単位でPodを手動再起動する方法
```bash
kubectl rollout restart deployment -n <namespace>
```
