# MONU Dependency Rules

## Allowed Dependency Direction

API
  -> Core
  -> Contracts
  -> Domain

Core
  -> Memory
  -> Providers
  -> Tools
  -> Agents
  -> Workflows

Providers
  -> Contracts

Tools
  -> Contracts

Agents
  -> Contracts
  -> Core Interfaces

Infrastructure
  -> Contracts

## Forbidden Design

Core must not directly depend on a specific provider implementation.

Examples of forbidden coupling:

Core -> Gemini SDK
Core -> Groq SDK
Core -> Specific Search Engine

Instead:

Core -> Provider Interface -> Provider Adapter

## Principle

Interfaces point inward.
Implementations point outward.
