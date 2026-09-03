# MONU Credential Naming System

## Core Principle

MONU supports an unlimited number of authorized credentials per provider.

Credentials must not be hard-coded into Python source code.

## Standard Pattern

PROVIDER_API_KEY_1
PROVIDER_API_KEY_2
PROVIDER_API_KEY_3
...

Examples:

GEMINI_API_KEY_1
GEMINI_API_KEY_2

GROQ_API_KEY_1
GROQ_API_KEY_2

COHERE_API_KEY_1
COHERE_API_KEY_2

## Alternative Credential Types

A provider may use tokens instead of API keys:

GITHUB_TOKEN_1
GITHUB_TOKEN_2

HF_TOKEN_1
HF_TOKEN_2

## Dynamic Discovery

MONU Credential Pool must scan environment variables and discover credentials dynamically.

The suffix number is not limited.

Example:

GEMINI_API_KEY_1
GEMINI_API_KEY_2
GEMINI_API_KEY_25
GEMINI_API_KEY_100

All valid credentials can be discovered without changing MONU Core code.

## Credential Metadata

Runtime credential records may track:

- provider
- credential identifier
- status
- health
- rate limit state
- quota state
- failure count
- last used timestamp
- last success timestamp

Raw secrets must never be included in logs or audit output.
