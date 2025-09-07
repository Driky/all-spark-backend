# Allspark

A DDD Elixir Phoenix a bootstrapping project.

## Project Overview

AllSpark is a bootstrapping project. It will be used as the base for future projects.

## Development Setup

### Prerequisites

- Elixir 1.15+
- Erlang 26+
- Docker and Docker Compose
- PostgreSQL client (optional, for direct DB access)
- Firecamp (for API testing)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <project_folder>
   ```

2. Start the PostgreSQL database using Docker:
   ```bash
   docker-compose up -d
   ```

3. Install dependencies:
   ```bash
   mix deps.get
   ```

4. Configure Supabase authentication:
   ```bash
   cp config/secrets.exs.example config/secrets.exs
   ```
   Then edit `config/secrets.exs` with your actual Supabase credentials

5. Create and migrate the database:
   ```bash
   mix ecto.setup
   ```

6 Run migrations if you've added new ones:
   ```bash
   mix ecto.migrate
   ```

7. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running Tests

```bash
mix test
```

## Database Management

- The application uses one database:
  - A regular PostgreSQL database for Ecto schemas

- To reset the databases:
  ```bash
  mix ecto.reset
  mix event_store.reset
  ```

## Development Guidelines

### Test-Driven Development (TDD)

We strictly follow a test-first approach for all development:

1. **Write a failing test** that describes the expected behavior or feature
2. **Implement the minimal code** needed to make the test pass
3. **Commit** the changes once a logical unit of work is complete and tested
4. **Refactor** the code while ensuring tests continue to pass
5. **Commit** the changes once a logical unit of work is complete and tested

This approach ensures complete test coverage and guides our implementation by focusing on requirements first.

### Commit Strategy

We use trunk-based development (working directly on the main branch) with the following guidelines:

1. **Frequent small commits** that represent logical units of work
2. **Always commit in a "green" state** where all tests are passing
3. **Follow the commit message format**: `type(scope): description`
   - **Types**:
     - `feat`: New feature
     - `fix`: Bug fix
     - `docs`: Documentation changes
     - `style`: Code style/formatting changes (no logic changes)
     - `refactor`: Code refactoring (no functional changes)
     - `test`: Adding or modifying tests
     - `chore`: Maintenance tasks, dependency updates, etc.
   - **Scope**: Bounded context or module affected (e.g., `user-management`, `auth`)
   - **Description**: Concise explanation of the change (imperative mood)
4. **Example commit messages**:
   - `feat(biometrics): implement measurement recording`
   - `fix(auth): handle expired tokens correctly`
   - `test(nutrition): add tests for meal plan creation`

### Code Organization

- **Module naming**: Clear and consistent module naming that reflects the bounded context and responsibility
- **Function naming**: Descriptive function names that clearly indicate purpose
- **Specs and typespecs**: Include `@spec` annotations for all public functions
- **Documentation**: Add `@moduledoc` and `@doc` to all modules and public functions
- **File organization**: Follow the DDD-oriented directory structure

## Software Design Guidelines

### Domain-Driven Design Principles

We organize our codebase around business domains and bounded contexts:

1. **Ubiquitous Language**: Use consistent terminology across code, documentation, and discussion
2. **Bounded Contexts**: Maintain clear boundaries between different domains
3. **Entities and Value Objects**: Model domain objects appropriately based on identity vs. characteristics
4. **Aggregates**: Design aggregates as consistency boundaries with clear transactional limits
5. **Domain Events**: Express domain changes as explicit events
6. **Domain Services**: Use services for operations that don't belong to a specific entity

### Error Handling

1. **Domain Errors**: Represent business rule violations, returned as tagged tuples (`{:error, :reason}`)
2. **Technical Errors**: Handled separately from domain errors, typically through monitoring and logging
3. **Validation**: Input validation happens at the command level before reaching aggregates

## Architecture

all-spark-backend follows Domain-Driven Design principles.

### Bounded Contexts

- **User Management**: Patient profiles and relationships

### Technical Implementation

- **Elixir and Phoenix**: Core application framework
- **Ecto**: Database interaction
- **Supabase**: Authentication services

## Authentication

Allspark uses Supabase for authentication. The following methods are supported:

- Email/password authentication
- Magic link (passwordless) authentication
- JWT token verification for API access

## License

[Add license information here]