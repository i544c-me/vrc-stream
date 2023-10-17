# VRC Stream

MediaMTX をデプロイするだけのコード群です。

基本的に `packer build .` と `terraform apply` だけでサーバーを構築できます。


## Requirements
- AWS Credentials
- Cloudflare Credentials


## Images

MediaMTX をインストールし、起動するだけのイメージを作成します。

```
packer init .
packer build .
```


## Infra

作ったイメージを使ってサーバーや周辺のリソースを構築します。

```
terraform init
terraform apply
```