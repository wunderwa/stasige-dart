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
