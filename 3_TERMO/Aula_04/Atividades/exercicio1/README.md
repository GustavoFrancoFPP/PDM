# exercicio1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Executar no Windows

Se você encontrar erros de codificação (FormatException) ou mensagens sobre
`engine.stamp` sendo usado por outro processo ao executar em Windows,
use um dos scripts fornecidos abaixo a partir da raiz do projeto:

- PowerShell (recomendado):

	- Execute `run_windows.ps1` para definir a codificação para UTF-8,
		encerrar processos `dart` que possam bloquear arquivos do cache do Flutter
		e iniciar `flutter run -d windows`.

- Batch (cmd):

	- Execute `run_windows.bat` para o mesmo comportamento em ambientes que
		preferem `cmd.exe`.

Esses scripts ajudam a evitar problemas comuns:

- FormatException: Missing extension byte — causado por saída com codificação
	diferente da esperada pelo Flutter/PowerShell.
- Erro "engine.stamp is being used by another process" — causado por processos
	Dart em execução que impedem a atualização do cache da engine.

Se preferir, rode manualmente em PowerShell:

```
chcp 65001 | Out-Null
Get-Process dart,dartvm,dartaotruntime -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
flutter run -d windows
```

