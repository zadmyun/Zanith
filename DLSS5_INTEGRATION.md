# Integração local DLSS 5 / ReShade no Zanit

## Resultado

No Windows, o Zanit procura a cadeia ao lado de `Zanit.exe` e carrega o
ReShade antes de Qt/libplacebo criarem o dispositivo Vulkan ou OpenGL. Assim,
o `Present` da própria janela do Remote Play passa pelos efeitos e add-ons, sem
abrir o `DLSS5RTX.exe`, sem Windows Graphics Capture e sem uma segunda janela
de vídeo.

A cadeia local é:

`Zanit/libplacebo -> ReShade -> Lumenite Kernel -> DLSS5 Feed -> NGX/DLSS -> RenoDX Neural Rendering -> Sharpen -> tela`

- `Home` abre/fecha o painel do ReShade (`KeyOverlay=36`).
- O contador fica no canto superior direito (`ShowFPS=1`, `FPSPosition=1`).
- Conexão local, PSN/remota e stream por linha de comando usam a mesma janela.
- Se algum arquivo obrigatório faltar, o carregamento é ignorado e o Zanit
  continua com seu renderer normal.
- Para desativar temporariamente: defina `ZANIT_DISABLE_DLSS5=1` antes de abrir.

## Arquivos locais

Os binários e shaders em `dlss5-runtime` foram importados do ZIP instalado
fornecido pelo usuário em 2026-09-08. Eles não foram incorporados ao código do
Zanit; o CMake apenas os copia para a pasta do executável na compilação local.

O ZIP instalado é mais completo que o `dist` da pasta-fonte: ele contém
`lumenite_Kernel.fx`, necessário para o provedor de motion vectors configurado
por `DLSS5_MV_PROVIDER=3`.

## Segurança e redistribuição

Esta é uma integração local/experimental. `nvngx_dlss.dll` possui assinatura
Authenticode válida da NVIDIA. O `nvngx_dlssnr.dll` fornecido tem versão
`310.8.SF.0`, SHA-256
`6EB209E764F39872625DEBD6ABAF45E2BB6322F6F270F781F70C059AE30B3927` e não
possui assinatura Authenticode reconhecida pelo Windows. O log da instalação
existente registra esse mesmo hash como runtime customizado aceito, mas isso
não comprova origem oficial nem autorização de redistribuição.

Não publique nem redistribua o pacote resultante sem verificar separadamente
as licenças e a procedência de RenoDX DLSS5, DLSS5 Feed, LumeniteFX e dos
runtimes NVIDIA. O uso de um vídeo final do Remote Play também significa que
motion vectors e depth são reconstruídos; não é uma integração nativa dentro
do motor do jogo do PS5.

## Validação

Após iniciar, confira `ReShade.log` e `dlss5-feed.log` ao lado do executável.
O estado visual `DLSS 5 PRONTO` confirma que o conjunto foi localizado e o
ReShade foi carregado; a confirmação de processamento neural exige, durante a
sessão, linhas `frame ... delivered` e `inline feature 18 evaluation succeeded`.
