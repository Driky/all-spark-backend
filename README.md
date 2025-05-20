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
- Firecamp (for API testing)

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

5. Run migrations if you've added new ones:
   ```bash
   mix ecto.migrate
   ```

6. Set up the EventStore:
   ```bash
   mix do event_store.create, event_store.init
   ```

7. Configure Supabase authentication:
   ```bash
   cp config/secrets.exs.example config/secrets.exs
   ```
   Then edit `config/secrets.exs` with your actual Supabase credentials.

8. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## API Testing with Firecamp

Pantheon includes a pre-configured Firecamp collection for testing the API endpoints.

### Setting Up Firecamp

1. Download and install [Firecamp](https://firecamp.io/) if you haven't already.

2. Open Firecamp and create a new workspace or use an existing one.

3. Import the Pantheon API collection:
   - Click on the "Import" button in the sidebar
   - Select "Import from file"
   - Navigate to `documentation/pantheon_api_firecamp.json` in your project directory
   - Click "Import"

4. Configure the environment:
   - Select the "Development" environment from the dropdown
   - Verify that the baseUrl is set to `http://localhost:4000`
   - The collection includes variables for test credentials and the auth token

### Using the API Collection

The collection includes the following endpoints:

1. **Register User**
   - Registers a new user with email and password
   - Automatically captures the auth token for subsequent requests

2. **Login User**
   - Authenticates a user and returns a token
   - Automatically captures the auth token for subsequent requests

3. **Send Magic Link**
   - Sends a magic link for passwordless authentication

4. **Get Patients (Authenticated)**
   - Retrieves all patients (requires authentication)
   - Uses the captured auth token

5. **Create Patient (Authenticated)**
   - Creates a new patient (requires authentication)
   - Uses the captured auth token

### Testing Authentication Flow

1. Start the Phoenix server if it's not already running:
   ```bash
   mix phx.server
   ```

2. In Firecamp, execute the "Register User" request to create a new account.
   - The auth token will be automatically stored in the environment variables

3. Test authenticated endpoints like "Get Patients" or "Create Patient"
   - These requests will use the stored auth token

4. If the token expires, use the "Login User" request to get a new token

## Running Tests

```bash
mix test
```

## Database Management

- The application uses two databases:
  - A regular PostgreSQL database for Ecto schemas
  - An EventStore database for event sourcing

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
3. **Refactor** the code while ensuring tests continue to pass
4. **Commit** the changes once a logical unit of work is complete and tested

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
   - **Scope**: Bounded context or module affected (e.g., `patient-management`, `auth`)
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

### Event Sourcing Implementation

We use event sourcing for domains where history and auditability are critical:

1. **Event Definitions**: Events are defined as explicit data structures that capture what happened
2. **Command Handling**: Commands validate input and produce events when successful
3. **Event Application**: Aggregates are reconstructed by replaying events
4. **Versioning**: Events include version information for future evolution
5. **Snapshots**: For performance optimization in aggregates with many events

### CQRS Architecture

We separate commands (writes) from queries (reads):

1. **Command Side**:
   - Commands represent user intent
   - Command handlers validate commands and produce events
   - Events are stored in the event store

2. **Query Side**:
   - Projections subscribe to events and update read models
   - Read models are optimized for specific query scenarios
   - Queries access read models directly without going through aggregates

### Error Handling

1. **Domain Errors**: Represent business rule violations, returned as tagged tuples (`{:error, :reason}`)
2. **Technical Errors**: Handled separately from domain errors, typically through monitoring and logging
3. **Validation**: Input validation happens at the command level before reaching aggregates

### Projections Design

1. **Purpose-Built**: Design projections for specific query needs
2. **Eventual Consistency**: Accept that projections may lag behind the event store
3. **Idempotency**: Ensure projections can handle event replay and out-of-order processing
4. **Versioning**: Include mechanisms to handle schema evolution in projections

## Architecture

Pantheon follows Domain-Driven Design principles with CQRS (Command Query Responsibility Segregation) and Event Sourcing.

### Bounded Contexts

- **Patient Management**: Patient profiles and relationships
- **Nutrition Planning**: Nutrition plans and adherence tracking
- **Biometric Tracking**: Body composition measurements
- **Wellness Monitoring**: Mood and fatigue tracking

### Technical Implementation

- **Elixir and Phoenix**: Core application framework
- **Commanded**: CQRS and Event Sourcing framework
- **EventStore**: Persistence for event streams
- **Ecto**: Database interaction for read models
- **Supabase**: Authentication services

## Authentication

Pantheon uses Supabase for authentication. The following methods are supported:

- Email/password authentication
- Magic link (passwordless) authentication
- JWT token verification for API access

## License

[Add license information here]