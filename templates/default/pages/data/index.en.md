```yaml
layout: data
menuShort: Data
menuLong: Data example
title: Data
```
<!--config-->
## Data example{.text-center}

List below is rendered from `data/example.json` via `data.example.tech`.

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
