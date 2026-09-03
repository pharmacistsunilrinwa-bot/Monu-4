# MONU Core Contracts

## Provider Contract

Every external intelligence or specialized provider must expose:

- name
- health_check
- capabilities
- execute

## Tool Contract

Every tool must expose:

- name
- capabilities
- execute

## Memory Contract

Every memory backend must expose:

- store
- retrieve
- delete

## Node Contract

Every execution node must expose:

- node_id
- health_check
- capabilities
- execute

## Future Compatibility

Implementations may change.

Contracts should remain stable unless a versioned migration is introduced.
