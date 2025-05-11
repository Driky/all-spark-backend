# Pantheon

A DDD Elixir Phoenix Nutrition Management System.

## Project Overview

Pantheon is a comprehensive nutrition management system that focuses on nutritionist-patient relationships. It enables nutritionists to track patient data over time, including profile information, body composition measurements, nutrition plans, and patient-reported wellness indicators.

## Development Setup

### Prerequisites

- Elixir 1.15+
- Erlang 26+
- Docker and Docker Compose
- PostgreSQL client (optional, for direct DB access)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd pantheon
   ```

2. Start the PostgreSQL database using Docker:
   ```bash
   docker-compose up -d
   ```

3. Install dependencies:
   ```bash
   mix deps.get
   ```

4. Create and migrate the database:
   ```bash
   mix ecto.setup
   ```

5. Set up the EventStore:
   ```bash
   mix do event_store.create, event_store.init
   ```

6. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Running Tests

```bash
mix test
```

### Database Management

- The application uses two databases:
  - A regular PostgreSQL database for Ecto schemas
  - An EventStore database for event sourcing

- To reset the databases:
  ```bash
  mix ecto.reset
  mix event_store.reset
  ```

## Architecture

Pantheon follows Domain-Driven Design principles with CQRS (Command Query Responsibility Segregation) and Event Sourcing.

### Bounded Contexts

- **Patient Management**: Patient profiles and relationships
- **Nutrition Planning**: Nutrition plans and adherence tracking
- **Biometric Tracking**: Body composition measurements
- **Wellness Monitoring**: Mood and fatigue tracking

## Development Workflow

This project uses trunk-based development (working directly on the main branch). Commits should:

- Represent complete, testable units of functionality
- Follow the format: `type(scope): description`
  - Types: feat, fix, docs, style, refactor, test, chore
  - Scope: bounded context or module affected
  - Description: concise explanation of the change

## License

[Add license information here]