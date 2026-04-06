# User Copilot Instructions

## Formatting

- When asked for raw markdown output, print it in a multi-line code block using tildes (`~~~`) so that inner code blocks using backticks render correctly.

## Accuracy

- Do not make assumptions or exaggerate what code does. Be precise about what is verified vs what is inferred.

## Security

- Always prompt me for values that may be considered secrets, such as passwords, API keys, tokens, or connection strings. Never hardcode or assume these values.

## Git

- **Never use `git add -A` or `git add .`** — these stage the entire working tree including unrelated uncommitted changes. Always stage specific files with `git add <file1> <file2> ...`.
- Use **Markdown** formatting (inline code, bullet lists, etc.) in commit message bodies. Do **not** hard-wrap lines — let the renderer handle line breaks.

## Testing

- Don't remove or weaken existing tests unless explicitly asked.

## Production Impact

- When proposing changes to data formats, storage, or encryption, proactively assess backward compatibility and migration impact before committing.

## Azure DevOps

- Unless I specify otherwise, create ADO work items in Area Path `Intune\Mgmt\Android Mobility\MAM Android`.
