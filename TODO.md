# Dotfiles TODO

## Shell / Prompt
- [ ] Add [Starship](https://starship.rs) or [Oh My Posh](https://ohmyposh.dev) config to replace manual PS1 / prompt setup in `.bashrc`

## Search Tools
- [ ] Add `.ripgreprc` config (default flags, type definitions, ignore patterns)

## Editor
- [ ] Add VS Code `settings.json` and `extensions.json`

## Dependencies / Maintenance
- [ ] Migrate to [chezmoi](https://www.chezmoi.io) — replace the custom Node.js `install` script with chezmoi primitives; port Windows Terminal work-profile merging logic to a `run_onchange_` PowerShell script


- [ ] Update `shelljs` from `~0.3.0` to `^0.8.5` in `package.json` — note `exec()` return value changed to an object with `.stdout`/`.code`, so audit usages in `install` script
- [ ] Replace `.jshintrc` with ESLint flat config (`eslint.config.js`) targeting ES2020+; add Prettier config (`.prettierrc`)
