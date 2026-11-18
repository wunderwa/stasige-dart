```yaml
layout: data
menuShort: Данные
menuLong: Пример данных
title: Данные
```
<!--config-->
## Пример данных{.text-center}

Список ниже отрисован из `data/example.json` через `data.example.tech`.

## Использование переменных и данных в Stasige

### 1. Переменные в `*.md` файлах
В теле Markdown (после разделителя `<!--config-->`) работают **ТОЛЬКО** глобальные переменные из `build.json`.
Синтаксис: `${путь.к.переменной}`

**Доступно:**
- `${meta.title.en}` / `${meta.title.ru}`
- `${meta.description.en}`
- `${links.github.url}`
- `${langs}`

> ⚠️ **Важно:** Данные из папки `data/` в Markdown-файлах **НЕ** подставляются. Они работают только в Pug-шаблонах.

**Пример в `pages/index.en.md`:**
```markdown
### Welcome to ${meta.title.en}
[GitHub](${links.github.url})
```

### 2. Данные из `data/*.json`
Все JSON-файлы из папки `data/` автоматически читаются при сборке и передаются в Pug-шаблоны как глобальный объект `data`.
Имя файла (без расширения `.json`) становится ключом объекта.

**Пример для файла `data/example.json`:**
```json
{
  "tech": {
    "en": [{ "title": "Dart", "url": "https://dart.dev/" }],
    "ru": [{ "title": "Dart", "url": "https://dart.dev/" }]
  }
}
```

**Использование в Pug (`views/layouts/data.pug`):**
```pug
each item in data.example.tech[lang]
  a(href=item.url)= item.title
```

### 3. Меню и навигация в Pug-шаблонах
Генератор автоматически собирает структуру сайта и передает в шаблоны 3 типа данных:

#### А) `mainMenu[lang]`
Массив элементов верхнего уровня для текущего языка (древовидное меню).
Каждый элемент содержит: `lang`, `path`, `pathBase`, `menuShort`, `menuLong`, `title`, `children`.

**Пример рендера (как в `views/partial/header/menu.pug`):**
```pug
include ./partial/header/menu-mix

- const topMenu = mainMenu[lang][0].children
ul.navbar-nav.me-auto.mb-2.mb-lg-0
  each pg in topMenu
    +navItem(pg, path)
```

#### Б) `pageLangs`
Массив доступных переводов **ТЕКУЩЕЙ** страницы.
Свойства элемента: `url`, `title`, `lang`, `disabled` (`true`, если это текущий язык).

**Пример переключателя языков (`views/partial/header/langs.pug`):**
```pug
.btn-group.d-flex
  each pgu in pageLangs
    if pgu.disabled
      a.btn.btn-outline-info.btn-sm.disabled(href='')= pgu.title
    else
      a.btn.btn-outline-info.btn-sm(href=pgu.url)= pgu.title
```

#### В) `linksByDir` и `linksByLang`
Словари для точечного получения ссылки на конкретную страницу.
- `linksByDir[pathBase][lang]` — поиск по директории и языку.
- `linksByLang[lang][pathBase]` — поиск по языку и директории.

**Пример (получить ссылку на `/about`):**
```pug
- var about = linksByDir['/about'] ? linksByDir['/about'][lang] : null
if about
  a(href=about.path) About us
```

---
**Резюме:**
- В `*.md`: только `${meta.*}`, `${links.*}`, `${langs}` из `build.json`.
- В `pug`: `data.<имя_файла>` для данных из `data/*.json`.
- Навигация: `mainMenu[lang]`, `pageLangs`, `linksByDir` / `linksByLang`.
- 