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

**Install** in your project's `pubspec.yaml`:

```yaml
dev_dependencies:
  stasige: ^0.1.0
```

**Init** a site in an empty directory:

```
dart pub get
dart run stasige init
```

**Build** via `./wrk`:

```
./wrk -b           # full build -> dist/
./wrk -b -D        # dev build -> dev/ (timekey=dev)
./wrk -b -S        # css only
./wrk -b -H        # html only
./wrk -b -I        # assets only (svg copy, png/jpg -> webp)
./wrk -b -J        # js only (requires esbuild)
./wrk -C -b        # clear + build
./wrk srv          # serve dist/ on :8000
```

**Structure**:

```
build.json      langs / meta / links
pages/          *.md (index.<lang>.md)
data/           *.json (in pug as data.<name>)
views/          *.pug (layouts, partials)
styles/         *.scss -> index.<timekey>.css
scripts/        *.ts   -> index.<timekey>.js (esbuild)
assets/         svg/webp/img -> /a/
css/            vendor (bootstrap) -> /css/
```
