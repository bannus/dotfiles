# User Copilot Instructions

## Formatting

- When asked for raw markdown output, print it in a multi-line code block using tildes (`~~~`) so that inner code blocks using backticks render correctly.

## Accuracy

- Do not make assumptions or exaggerate what code does. Be precise about what is verified vs what is inferred.

## Security

- Always prompt me for values that may be considered secrets, such as passwords, API keys, tokens, or connection strings. Never hardcode or assume these values.

## Git

- **Never use `git add -A` or `git add .`** — these stage the entire working tree including unrelated uncommitted changes. Always stage specific files with `git add <file1> <file2> ...`.

## Production Impact

- When proposing changes to data formats, storage, or encryption, proactively assess backward compatibility and migration impact before committing.
