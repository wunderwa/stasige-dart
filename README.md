# stasige

Static site generator on Dart — Markdown, Pug, SCSS, multi-language.

## Quick start

Install once (before publication on pub.dev — via git; later — `dart pub global activate stasige`):

```bash
dart pub global activate --source git https://github.com/wunderwa/stasige-dart.git
```

Create a site:

```bash
mkdir my-site && cd my-site
stasige init          # creates pubspec.yaml + scaffolds template
dart pub get
./wrk -b -D           # dev build -> dev/
```

For local development of stasige itself:

```bash
dart pub global activate --source path /path/to/stasige-dart
```

## Usage

Inside a site (after `stasige init`):

```bash
./wrk -b                   # full build -> dist/
./wrk -b -D                # dev build -> dev/ (timekey=dev)
./wrk -b -S                # css only
./wrk -b -H                # html only
./wrk -b -I                # assets only (svg copy, png/jpg -> webp)
./wrk -b -J                # js only (requires esbuild)
./wrk -C -b                # clear + build
./wrk s                  # serve dist/ on :8000
stasige new about          # create pages/about/index.<lang>.md
```

## Structure

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

## Options

```text
-b    build
-D    dev (output to dev/, timekey=dev)
-C    clear target dir before build
-S    css only
-J    js only (esbuild)
-H    html only
-I    assets only
-h    help
-s    serve target dir on :8000
```

## License

MIT