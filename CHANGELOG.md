## 0.1.0

- Initial release.
- `stasige init` — scaffold site from `templates/default/`.
- `stasige new <path>` — create md pages per lang from `build.json`.
- `stasige build` with `-D/-S/-J/-H/-I` flags.
- `./wrk` shell entry in scaffold: `-b`, `-D`, `-C`, `-s`.
- Tasks: html (pug + markdown), css (sass), vendor (css/ -> dist/css/), assets (svg/webp), js (esbuild, optional).
