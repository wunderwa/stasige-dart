# stasige

Static site generator on Dart — Markdown, Pug, SCSS, multi-language.

## Quick start

Install once (before publication on pub.dev — via git; later — `dart pub global activate stasige`):

```bash
dart pub global activate stasige
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
dart pub global activate stasige
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

## Using Variables and Data in Stasige{.text-center}


### 1. Variables in `*.md` files
In the Markdown body (after the `<!--config-->` separator), **ONLY** global variables from `build.json` are available.
Syntax: `${path.to.variable}`

**Available:**
- `${meta.title.en}` / `${meta.title.ru}`
- `${meta.description.en}`
- `${links.github.url}`
- `${langs}`

> ⚠️ **Important:** Data from the `data/` folder is **NOT** substituted in Markdown files (it only works in Pug templates).

**Example in `pages/index.en.md`:**
```markdown
### Welcome to ${meta.title.en}
[GitHub](${links.github.url})
```

### 2. Data from `data/*.json`
All JSON files in the `data/` folder are automatically read during the build and passed into Pug templates as the global `data` object.
The filename (without the `.json` extension) becomes the object key.

**Example for `data/example.json`:**
```json
{
  "tech": {
    "en": [{ "title": "Dart", "url": "https://dart.dev/" }],
    "ru": [{ "title": "Dart", "url": "https://dart.dev/" }]
  }
}
```

**Usage in Pug (`views/layouts/data.pug`):**
```pug
each item in data.example.tech[lang]
  a(href=item.url)= item.title
```

### 3. Menus and navigation in Pug templates
The generator automatically builds the site structure and passes 3 types of data into templates:

#### A) `mainMenu[lang]`
An array of top-level items for the current language (tree-structured menu).
Each item contains: `lang`, `path`, `pathBase`, `menuShort`, `menuLong`, `title`, `children`.

**Rendering example (as in `views/partial/header/menu.pug`):**
```pug
include menu-mix
- const topMenu = mainMenu[lang][0].children
ul.navbar-nav.me-auto.mb-2.mb-lg-0
  each pg in topMenu
    +navItem(pg, path)
```

#### B) `pageLangs`
An array of available translations for the **CURRENT** page.
Item properties: `url`, `title`, `lang`, `disabled` (`true` if this is the current language).

**Language switcher example (`views/partial/header/langs.pug`):**
```pug
.btn-group.d-flex
  each pgu in pageLangs
    if pgu.disabled
      a.btn.btn-outline-info.btn-sm.disabled(href='')= pgu.title
    else
      a.btn.btn-outline-info.btn-sm(href=pgu.url)= pgu.title
```

#### C) `linksByDir` and `linksByLang`
Dictionaries for fetching a link to a specific page.
- `linksByDir[pathBase][lang]` — lookup by directory and language.
- `linksByLang[lang][pathBase]` — lookup by language and directory.

**Example (get link to `/about`):**
```pug
- var about = linksByDir['/about'] ? linksByDir['/about'][lang] : null
if about
  a(href=about.path) About us
```

---
**Summary:**
- In `*.md`: only `${meta.*}`, `${links.*}`, `${langs}` from `build.json`.
- In `pug`: `data.<filename>` for data from `data/*.json`.
- Navigation: `mainMenu[lang]`, `pageLangs`, `linksByDir` / `linksByLang`.

## License

MIT
