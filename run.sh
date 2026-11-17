#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

cat > templates/default/pages/about/index.en.md <<'MD'
```yaml
layout: default
menuShort: About
menuLong: About this site
title: About
```
<!--config-->
## About{.text-center}

### Markdown attrs

Text centered with `{.text-center}`
{.text-center}

A colored block with `{.alert .alert-info}`
{.alert .alert-info}

### Build variables

Site title from `build.json`: **${meta.title.en}**
{.text-center}

### Menus

Multi-level from `pathBase`. See navbar above.
{.text-center}

### Links

[GitHub](${links.github.url}){.btn .btn-secondary}

### Usage

**Install once** (before publication on pub.dev — via git; later `dart pub global activate stasige`):

```bash
dart pub global activate --source git https://github.com/wunderwa/stasige-dart.git
```

**Create a site**:

```bash
mkdir my-site && cd my-site
stasige init
dart pub get
./wrk -b -D
```

**Build** via `./wrk`:

```bash
./wrk -b           # full build -> dist/
./wrk -b -D        # dev build -> dev/ (timekey=dev)
./wrk -b -S        # css only
./wrk -b -H        # html only
./wrk -b -I        # assets only (svg copy, png/jpg -> webp)
./wrk -b -J        # js only (requires esbuild)
./wrk -C -b        # clear + build
./wrk srv          # serve dist/ on :8000
stasige new about  # create pages/about/index.<lang>.md
```

**Structure**:

```text
build.json      langs / meta / links
pages/          *.md (index.<lang>.md)
data/           *.json (in pug as data.<name>)
views/          *.pug (layouts, partials)
styles/         *.scss -> index.<timekey>.css
scripts/        *.ts   -> index.<timekey>.js (esbuild, optional)
assets/         svg/webp/img -> /a/
css/            vendor (bootstrap) -> /css/
```
MD

cat > templates/default/pages/about/index.ru.md <<'MD'
```yaml
layout: default
menuShort: О сайте
menuLong: Об этом сайте
title: О сайте
```
<!--config-->
## О сайте{.text-center}

### Атрибуты Markdown

Текст по центру через `{.text-center}`
{.text-center}

Цветной блок через `{.alert .alert-info}`
{.alert .alert-info}

### Переменные сборки

Название сайта из `build.json`: **${meta.title.ru}**
{.text-center}

### Меню

Многоуровневое из `pathBase`. Смотрите navbar выше.
{.text-center}

### Ссылки

[GitHub](${links.github.url}){.btn .btn-secondary}

### Использование

**Установка** (до публикации на pub.dev — через git; позже `dart pub global activate stasige`):

```bash
dart pub global activate --source git https://github.com/wunderwa/stasige-dart.git
```

**Создание сайта**:

```bash
mkdir my-site && cd my-site
stasige init
dart pub get
./wrk -b -D
```

**Сборка** через `./wrk`:

```bash
./wrk -b           # полная сборка -> dist/
./wrk -b -D        # dev-сборка -> dev/ (timekey=dev)
./wrk -b -S        # только css
./wrk -b -H        # только html
./wrk -b -I        # только assets (svg копия, png/jpg -> webp)
./wrk -b -J        # только js (нужен esbuild)
./wrk -C -b        # очистка + сборка
./wrk srv          # сервер dist/ на :8000
stasige new about  # создать pages/about/index.<lang>.md
```

**Структура**:

```text
build.json      langs / meta / links
pages/          *.md (index.<lang>.md)
data/           *.json (в pug как data.<name>)
views/          *.pug (layouts, partials)
styles/         *.scss -> index.<timekey>.css
scripts/        *.ts   -> index.<timekey>.js (esbuild, optional)
assets/         svg/webp/img -> /a/
css/            vendor (bootstrap) -> /css/
```
MD

echo "==> sync root"
rm -rf pages && cp -r templates/default/pages ./pages

echo "==> build"
rm -rf dev && ./wrk -b -D

echo "==> usage markers in about"
grep -q 'dart pub global activate --source git' dev/about/index.html && echo "OK  en install" || echo "MISS en install"
grep -q 'dart pub global activate --source git' dev/ru/about/index.html && echo "OK  ru install" || echo "MISS ru install"
grep -q 'stasige new about' dev/about/index.html && echo "OK  en new" || echo "MISS en new"
grep -q 'stasige new about' dev/ru/about/index.html && echo "OK  ru new" || echo "MISS ru new"