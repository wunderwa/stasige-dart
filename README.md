# stasige

Static site generator on Dart — Markdown, Pug, SCSS, multi-language.

## Install

```yaml
dev_dependencies:
  stasige: ^0.1.0
```

```bash
dart pub get
```

## Usage

In an empty directory:

```bash
dart run stasige init      # scaffold from templates/default
./wrk -b                   # build -> dist/
./wrk -b -D                # dev build -> dev/ (timekey=dev)
./wrk -b -S                # css only
./wrk -b -H                # html only
./wrk -b -I                # assets only (svg copy, png/jpg -> webp)
./wrk -b -J                # js only (requires esbuild)
./wrk -C -b                # clear + build
./wrk srv                  # serve dist/ on :8000
dart run stasige new about # create pages/about/index.<lang>.md
```

## Structure

```
build.json      langs / meta / links
pages/          *.md (index.<lang>.md)
data/           *.json (in pug as data.<name>)
views/          *.pug (layouts, partials)
styles/         *.scss -> index.<timekey>.css
scripts/        *.ts   -> index.<timekey>.js (esbuild, optional)
assets/         svg/webp/img -> /a/
css/            vendor (bootstrap) -> /css/
```

## License

MIT
