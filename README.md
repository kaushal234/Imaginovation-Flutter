# Task Manager — Flutter App

A Flutter client for the Task Management API, built with **feature-first clean
architecture**, **event-driven BLoCs**, **get_it** for dependency injection, and
**dartz `Either<Failure, T>`** for functional error handling.

It talks to the Laravel backend over a token-authenticated REST API and provides
four screens: Login, Task List, Add/Edit Task, and Task Detail.

---

## 1. Tech stack

| Concern | Package |
| --- | --- |
| State management | `flutter_bloc` (BLoCs, not Cubits) |
| Value equality | `equatable` |
| Dependency injection | `get_it` (service locator) |
| Functional errors | `dartz` (`Either<Failure, T>`) |
| Networking | `dio` (with a token interceptor) |
| Routing | `go_router` (with auth redirect) |
| Secure token storage | `flutter_secure_storage` |
| Date formatting | `intl` |
| Lints | `flutter_lints` + stricter analyzer settings |

---

## 2. Architecture

### The dependency rule

```
presentation  ->  domain  <-  data
```

- **domain** depends on nothing (no Flutter, no Dio, no JSON). Pure entities,
  repository *contracts* (abstract classes), and use cases.
- **data** implements the domain contracts: models (JSON ⇄ entity), remote data
  sources (Dio), and repository implementations that translate exceptions into
  `Failure`s.
- **presentation** talks to domain **only through use cases**. BLoCs receive
  entities or failures — never Dio or raw JSON.

### Project structure

```
lib/
├── core/                          # shared infrastructure
│   ├── constants/api_constants.dart      # base URL
│   ├── error/                            # exceptions (data) + failures (domain)
│   ├── network/dio_client.dart           # Dio + bearer-token interceptor
│   ├── observer/app_bloc_observer.dart   # global bloc logging
│   ├── storage/token_storage.dart        # secure token storage
│   ├── usecase/usecase.dart              # base UseCase<Type, Params>
│   └── router/app_router.dart            # go_router + auth redirect
├── features/
│   ├── auth/
│   │   ├── domain/      # User entity, AuthRepository, login/logout use cases
│   │   ├── data/        # UserModel, remote data source, repository impl
│   │   └── presentation/# AuthBloc + login screen
│   └── tasks/
│       ├── domain/      # Task entity, TaskRepository, 6 use cases
│       ├── data/        # TaskModel, remote data source, repository impl
│       └── presentation/# 3 BLoCs (list/form/detail) + screens + widgets
├── injection_container.dart       # get_it registrations
└── main.dart
```

---

## 3. Setup & running

### Prerequisites

- Flutter SDK (Dart 3.x) — verify with `flutter --version`
- An Android emulator or iOS simulator (or a physical device)
- The **Laravel backend running** (see the backend README) — by default at
  `http://127.0.0.1:8000`

### Steps

1. The project package name must be `imaginovation_app` (every internal import
   is `package:imaginovation_app/...`).

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. **Allow cleartext HTTP for local dev** (Android blocks plain `http` by
   default). In `android/app/src/main/AndroidManifest.xml`, on the
   `<application>` tag:
   ```xml
   <application
       android:usesCleartextTraffic="true"
       ... >
   ```

4. **Point at the API.** Edit `lib/core/constants/api_constants.dart`:

   | Target | `baseUrl` |
   | --- | --- |
   | Android emulator | `http://10.0.2.2:8000/api` (default — `10.0.2.2` is the emulator's alias for the host's `127.0.0.1`) |
   | iOS simulator | `http://127.0.0.1:8000/api` |
   | Physical device | `http://<your-machine-LAN-ip>:8000/api` |

5. Run:
   ```bash
   flutter run
   ```

   Seeded login: `test@example.com` / `password`.

---

## 4. Features

**Authentication**
- Email/password login; the token is stored in the platform keystore via
  `flutter_secure_storage` (not plaintext prefs).
- On launch the app checks for a stored token and routes straight to the task
  list if present (no re-login needed).
- Logout revokes the token on the server and clears it locally.

**Task list**
- Paginated list with **infinite scroll** (loads the next page near the bottom).
- **Pull-to-refresh** reloads from page 1.
- **Search** across title/description, and **filters** by status and priority,
  applied server-side.
- Empty, loading, and error states with a retry action.

**Swipe actions** (on each task tile)
- Swipe **left** → mark **Completed**.
- Swipe **right** → **Delete** (with a confirmation dialog).
- Both are **optimistic**: the UI updates instantly and rolls back if the API
  call fails, showing an error.

**Add / Edit**
- Form with title, description, status, priority, and a future-dated due-date
  picker; client-side validation plus server `422` errors surfaced inline.

**Task detail**
- Full task view with status “choice chips” to change status (optimistic, with
  rollback). Editing returns here and refetches.

**Developer experience**
- A global `BlocObserver` logs every event, state change, and error.
- Stricter `analysis_options.yaml` (strict casts/inference/raw-types, enforced
  `package:` imports). The use cases are injected, so each layer is mockable in
  isolation for testing.

---

## 5. Behind the scenes — how it talks to Laravel

### The request pipeline

Every authenticated call goes through one Dio instance configured in
`core/network/dio_client.dart`, which:

1. attaches `Accept: application/json` to every request,
2. reads the stored token and adds `Authorization: Bearer <token>`,
3. on a `401`, clears the stored token.

Responses are parsed by **models** (`*.fromJson`) into **entities**, and any
Dio error is converted to a `ServerException`, then mapped by the repository
into a `Failure` (`ValidationFailure` for `422`, otherwise `ServerFailure`) and
returned as `Either.Left`.

### Action → endpoint map

| User action | Screen | HTTP call | Notes |
| --- | --- | --- | --- |
| Sign in | Login | `POST /api/login` | Body `{email, password}` → `{user, token}`; token saved locally |
| App launch auth check | — | *(no call)* | Reads the local token; `/api/me` is available but not used on launch |
| Load task list | Task List | `GET /api/tasks?page=1&per_page=10` | Returns `{data:[…], meta:{current_page,last_page}}` |
| Infinite scroll | Task List | `GET /api/tasks?page=N` | Appends the next page |
| Pull to refresh | Task List | `GET /api/tasks?page=1` | Resets the list |
| Search / filter | Task List | `GET /api/tasks?search=&status=&priority=` | Server-side filtering |
| Swipe left (complete) | Task List | `PATCH /api/tasks/{id}/status` | Body `{status: "completed"}`; optimistic |
| Swipe right (delete) | Task List | `DELETE /api/tasks/{id}` | After confirm; optimistic |
| Create task | Add | `POST /api/tasks` | Body `{title, description, status, priority, due_date}` |
| Edit task | Edit | `PUT /api/tasks/{id}` | Same body as create |
| Open task | Detail | *(uses passed entity)* | May refetch via `GET /api/tasks/{id}` |
| Change status (chips) | Detail | `PATCH /api/tasks/{id}/status` | Body `{status}`; optimistic |
| Sign out | Task List | `POST /api/logout` | Revokes token, then local token cleared |

`due_date` is sent as `yyyy-MM-dd`; `status` is sent as the API value
(`pending` / `in_progress` / `completed`).

### Worked example A — loading the task list (a read)

```
TaskListScreen
  → dispatches TaskListStarted to TaskListBloc
    → calls GetTasks use case (domain)
      → TaskRepository.getTasks() (contract)
        → TaskRepositoryImpl (data) calls TaskRemoteDataSource
          → Dio GET /api/tasks?page=1&per_page=10
            (interceptor adds Bearer token + Accept: application/json)
          ← Laravel returns paginated JSON
        ← PaginatedTasksModel.fromJson(...) -> PaginatedTasks entity
      ← repository returns Right(PaginatedTasks)
    ← use case returns Either.Right
  → bloc emits TaskListState(success, tasks, currentPage, lastPage)
→ ListView rebuilds with the tiles
```

If the call fails, the data source throws `ServerException`, the repository
returns `Left(ServerFailure)`, and the bloc emits a failure state that renders
the error view with a Retry button.

### Worked example B — completing a task by swipe (an optimistic write)

```
Swipe left on a tile
  → TaskTile fires onComplete -> TaskListBloc.add(TaskListItemCompleted(task))
  → bloc OPTIMISTICALLY emits the list with that task marked completed (UI updates now)
  → calls UpdateTaskStatus use case
    → PATCH /api/tasks/{id}/status  {status: "completed"}
  → on Right: keep the optimistic state
  → on Left:  re-emit the PREVIOUS list + an error snackbar (rollback)
```

The `Dismissible`’s `confirmDismiss` always returns `false`, so the swipe never
removes the row by itself — the **bloc state** is the single source of truth for
what the list shows.

---

## 6. State management notes

- One `AuthBloc` (registered as a get_it singleton, because the router listens to
  its stream to redirect on login/logout).
- Three task BLoCs — `TaskListBloc`, `TaskFormBloc`, `TaskDetailBloc` —
  registered as factories (a fresh instance per screen via `BlocProvider`).
- Every bloc uses sealed event classes and an `Equatable` state, so identical
  states don’t trigger needless rebuilds.
- `dartz` is imported scoped (`show Either, Left, Right, Unit, unit`) to avoid a
  name clash with dartz’s own `Task` type.

---

## 7. Troubleshooting

**All calls fail on Android with a connection/cleartext error** — confirm
`android:usesCleartextTraffic="true"` is set and the base URL is
`http://10.0.2.2:8000/api` (not `127.0.0.1`) on the emulator.

**`401` immediately after login** — the backend must be running and reachable at
the configured base URL; check the request in DevTools → Network to confirm the
`Authorization` header is attached.

**Connection refused** — start the API (`php artisan serve`) and make sure the
port matches the base URL.

**Stale data after editing** — the list refreshes when you navigate back from
detail/edit; pull-to-refresh forces a reload.
