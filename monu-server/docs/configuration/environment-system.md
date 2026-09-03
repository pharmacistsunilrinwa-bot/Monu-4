# MONU Environment System

## Principle

Configuration must be separated from source code.

Secrets must never be committed to Git.

## Configuration Sources

Priority order:

1. Secure deployment environment variables
2. Authorized secret manager
3. Environment variables
4. Non-sensitive configuration files
5. Safe application defaults

## Environments

- development
- testing
- staging
- production

## Security Rules

- API keys must not be hard-coded.
- Passwords must not be stored in source code.
- Production secrets must use secure deployment settings.
- .env files containing secrets must remain ignored by Git.
- .env.example files may contain placeholders only.
