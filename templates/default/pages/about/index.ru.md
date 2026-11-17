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
