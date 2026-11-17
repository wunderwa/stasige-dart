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

**Установка** в `pubspec.yaml` проекта:

```yaml
dev_dependencies:
  stasige: ^0.1.0
```

**Инициализация** в пустой папке:

```
dart pub get
dart run stasige init
```

**Сборка** через `./wrk`:

```
./wrk -b           # полная сборка -> dist/
./wrk -b -D        # dev-сборка -> dev/ (timekey=dev)
./wrk -b -S        # только css
./wrk -b -H        # только html
./wrk -b -I        # только assets (svg копия, png/jpg -> webp)
./wrk -b -J        # только js (нужен esbuild)
./wrk -C -b        # очистка + сборка
./wrk srv          # сервер dist/ на :8000
```

**Структура**:

```
build.json      langs / meta / links
pages/          *.md (index.<lang>.md)
data/           *.json (в pug как data.<name>)
views/          *.pug (layouts, partials)
styles/         *.scss -> index.<timekey>.css
scripts/        *.ts   -> index.<timekey>.js (esbuild)
assets/         svg/webp/img -> /a/
css/            vendor (bootstrap) -> /css/
```
