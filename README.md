# 観光情報提供アプリ

APIと連携して観光情報を表示するスマホアプリのサンプルです。

Keycloakなどの統合認証認可サーバにクライアント登録とユーザ登録設定を行い、
「lib/home.dart」にその設定を行うことで再利用が可能です。

OpenAPI仕様をもとにクライアントプログラムを自動生成してくれます。
下の例は、「myapi/spots/openapi.json」にOpenAPI文書がある場合のコマンド実行の例です。
```
$ openapi-generator-cli generate -i myapi01/spots/openapi.json -g dart -DbrowserClient=false,apiTests=false,apiDocs=false,modelTests=false,modelDocs=false -o ./client
```
