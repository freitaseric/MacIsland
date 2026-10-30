<p align="center">
  <img src="docs/icon-256.png" width="128" alt="Ícone do MacIsland">
</p>

<h1 align="center">MacIsland</h1>

<p align="center">
  <a href="README.md">English</a> · <a href="README.pt-BR.md">Português (Brasil)</a>
</p>

<p align="center">
  <strong>Uma dynamic island para o seu Mac. Mídia, timers e mais.</strong>
</p>

<p align="center">
  <a href="https://github.com/freitaseric/MacIsland/actions/workflows/build.yml"><img src="https://github.com/freitaseric/MacIsland/actions/workflows/build.yml/badge.svg" alt="Build"></a>
  <a href="https://github.com/freitaseric/MacIsland/releases"><img src="https://img.shields.io/github/v/release/freitaseric/MacIsland?display_name=tag&sort=semver" alt="Última release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="Licença MIT"></a>
  <a href="#requisitos"><img src="https://img.shields.io/badge/macOS-14%2B-black.svg" alt="macOS 14+"></a>
</p>

<p align="center">
  <img src="docs/preview-expanded.png" width="760" alt="MacIsland expandido mostrando uma mídia e os controles">
</p>

O MacIsland transforma a área em volta do notch do MacBook em algo útil. A
ilha é o produto: uma superfície pequena e sempre presente para o que você
precisa ver de relance. A versão 1 combina um player de mídia caprichado com um
timer de foco, e a ilha foi feita para receber mais integrações com o tempo.

Feito em SwiftUI, com um `NSPanel` sem borda que fica acima da menu bar. Sem
contas e sem analytics: ele lê a mídia que o seu Mac já está reproduzindo.

## A ideia

O notch está sempre à vista. O MacIsland dá a ele um propósito além da câmera.
Hoje é mídia e timers de foco; a mesma superfície pode crescer para eventos da
agenda, ações do sistema e o que mais merecer um relance.

## Recursos

- **Feito para o notch** — a superfície preta se funde ao notch e se expande em
  um cartão compacto de player.
- **Feita para crescer** — a ilha é o produto, não um widget de player. Mídia é
  a primeira integração, não o teto.
- **Timer de foco** — presets de 5, 15 e 25 minutos com iniciar, pausar,
  reiniciar e uma notificação local no fim.
- **Seletor de features** — alterne entre Mídia e timer sem sair da ilha.
- **O que está tocando** — capa, título, artista, álbum, tempo decorrido e
  duração de qualquer app ou site que publique no macOS.
- **Controles** — play/pause em todos os casos; anterior e próxima quando a
  fonte suportar.
- **Atualização automática** — segue a sessão de mídia ativa e reage quando a
  reprodução começa, pausa ou muda.
- **Hover, Escape e clique fora** — expanda ao passar o mouse, recolha com
  Escape ou clicando fora. O clique também continua funcionando.
- **Progresso suave** — interpolado entre polls de dois segundos, sem saltos.
- **Sai da frente** — fica fora de apps em tela cheia nativos e volta quando
  você retorna à área de trabalho.
- **Estados claros** — telas para nada tocando, controles de mídia indisponíveis
  e erros inesperados.
- **Menu bar enxuto** — mostrar/ocultar a ilha, abrir no login, sobre e sair.
- **Inglês e português do Brasil** — segue o idioma do sistema.
- **Sem ícone no Dock** — um utilitário focado na menu bar.
- **Releases universais e notarizadas** — Apple Silicon e Intel, assinadas com
  Developer ID e notarizadas pela Apple.

## Capturas de tela

<p align="center">
  <img src="docs/preview-compact.png" width="320" alt="Timer compacto do MacIsland junto ao notch">
</p>

<p align="center">
  <img src="docs/preview-timer.png" width="760" alt="Timer de foco do MacIsland com presets e controles">
</p>

## Requisitos

- macOS **14 Sonoma** ou superior.
- Mídia de qualquer app ou site que publique na sessão Now Playing do macOS,
  como Spotify, Apple Music, Podcasts, Safari (YouTube, Netflix, Instagram) ou
  Chrome.
- Um MacBook com notch para o visual pretendido. Em outras telas, o MacIsland
  vira uma pílula flutuante logo abaixo da menu bar.
- Mac com Apple Silicon ou Intel.

## Instalação

> **Código-fonte disponível agora.** O primeiro binário assinado e notarizado
> está sendo preparado. Até ele chegar em Releases, compile a partir do código.

1. Baixe o `MacIsland-x.y.z.zip` mais recente em
   [Releases](https://github.com/freitaseric/MacIsland/releases).
2. Descompacte e arraste o **MacIsland.app** para `/Applications`.
3. Abra o MacIsland e clique na ilha compacta para abrir o player.

As releases oficiais são assinadas com um certificado Developer ID e
notarizadas pela Apple. Se você compilar o app por conta própria, isso não é
necessário para uso local.

## Uso

- **Expandir / recolher**: clique na ilha compacta para expandir e no chevron
  no canto superior direito para recolher.
- **Reprodução**: use play/pause; anterior e próxima aparecem quando a fonte
  atual suporta navegação entre faixas.
- **Ícone na menu bar**: mostrar/ocultar a ilha, ativar **Abrir no login**, ver
  **Sobre** ou sair.
- **Abrir no login**: ative pela menu bar. O macOS pode pedir aprovação em
  **Ajustes do Sistema → Geral → Itens de Login**. O app funciona melhor quando
  está em `/Applications`.
- **Múltiplas telas**: o MacIsland prioriza a tela integrada com notch. Em uma
  tela sem notch, ele aparece como uma pílula flutuante abaixo da menu bar.
- **Apps em tela cheia**: a ilha se esconde automaticamente enquanto outro app
  está em tela cheia e volta quando você sai.

## Mídia suportada

O MacIsland lê a sessão Now Playing do sistema, então funciona com qualquer app
ou site que publique mídia no macOS: Spotify, Apple Music, Podcasts, Safari
(YouTube, Netflix, Instagram), Chrome e outros.

O que aparece depende da fonte. Título, capa e play/pause são comuns; artista,
álbum, duração, posição e anterior/próxima aparecem quando a fonte fornece esses
dados. Nenhuma permissão de Automação é necessária.

## Compilar do código-fonte

Você precisa do **Xcode 26.6 ou superior** (testado com o 27.1) e do SDK do
macOS 14 ou superior. Versões mais antigas podem não suportar as opções
de concorrência do Swift usadas aqui.

```bash
git clone https://github.com/freitaseric/MacIsland.git
cd MacIsland
open MacIsland.xcodeproj
```

No Xcode:

1. Selecione o target **MacIsland** → **Signing & Capabilities**.
2. Escolha seu time (ou **Sign to Run Locally** se for só rodar localmente).
3. Pressione **Run**.

A pasta `Vendor` contém o adaptador universal pré-compilado e a licença, então
não é preciso configuração extra.

Build pela linha de comando:

```bash
xcodebuild \
  -project MacIsland.xcodeproj \
  -scheme MacIsland \
  -configuration Debug \
  -destination 'platform=macOS' \
  build
```

## Como funciona

- Um `NSPanel` sem borda e não ativável fica no nível `.statusBar` e é ancorado
  no topo da tela.
- `NSScreen.auxiliaryTopLeftArea` e `safeAreaInsets` detectam o notch e a
  altura da menu bar, para a ilha crescer para baixo a partir do notch.
- Um `MediaService` consulta a sessão Now Playing do sistema a cada dois segundos
  por um adaptador empacotado e carregado dinamicamente, lendo título, artista,
  álbum, capa, estado, duração e posição.
- Os comandos usam o mesmo canal do sistema que as teclas de mídia, com estado
  otimista e refresh depois de cada comando.
- O app não usa App Sandbox. Ele usa Hardened Runtime e não pede acesso de
  Automação.

Como o macOS 15.4 e posteriores só respondem a processos assinados pela Apple, o
MacIsland empacota o
[mediaremote-adapter](https://github.com/ungive/mediaremote-adapter), licenciado
em BSD-3, e o carrega via `/usr/bin/perl`. A licença acompanha o app e também
está em `Vendor/MediaRemoteAdapter.LICENSE`.

## Privacidade

- Sem contas, analytics, telemetria ou rastreamento.
- Nenhuma credencial é lida ou armazenada.
- Os metadados de mídia são lidos localmente da sessão Now Playing do sistema; a
  capa vem do app que controla a sessão.
- A única permissão do sistema é **notificações** (pedida só quando você inicia
  o timer).
- O código é aberto — dá para auditar cada linha.

## Limitações conhecidas

- A versão 1 traz duas integrações: mídia e um timer de foco. Ainda não há
  sistema de plugins para features de terceiros.
- O suporte a mídia depende do que cada app ou site publica na sessão Now
  Playing do sistema. Algumas fontes expõem só título e play/pause, e streams
  com DRM podem omitir metadados.
- A integração com o Now Playing usa um framework privado do macOS, então pode
  mudar ou parar de funcionar em uma versão futura.
- O timer para se o app for fechado.
- Ainda não há atualização automática.
- Distribuído fora da Mac App Store, então roda sem App Sandbox.
- O layout do notch é pensado para a tela integrada do MacBook; monitores
  externos recebem a pílula flutuante.

## Roadmap

- Mais integrações: modos de foco, agenda e ações do sistema.
- Uma superfície de integração para ações de terceiros.
- Metadados mais ricos por fonte e seleção explícita de fonte.
- Histórico de timers e persistência entre reinícios do app.
- Atualizações automáticas com Sparkle.
- Homebrew Cask.
- Mais opções de aparência e comportamento.

## Contribuindo

Issues e pull requests são bem-vindos. Mantenha as mudanças focadas e teste com
`xcodebuild` antes de abrir um PR. Para mudanças maiores, abra uma issue primeiro.

## Licença

[MIT](LICENSE) © 2026 Eric Freitas Sampaio.

## Aviso

O MacIsland é um projeto independente. Não é afiliado, endossado ou patrocinado
pelo Spotify ou pela Apple. Spotify é uma marca da Spotify AB. MacBook e Mac são
marcas da Apple Inc.

---

[![](https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=flat-square&logo=deepseek&logoColor=white)](https://github.com/deepseek-ai/deepseek-harness)
