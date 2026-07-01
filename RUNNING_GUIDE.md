# ServeConnect Run Guide

This guide explains how to run the ServeConnect backend and Flutter mobile app on Windows.

## What You Have

ServeConnect is split into two parts:
- Backend API: Node.js + TypeScript + Express + MySQL
- Mobile app: Flutter + Riverpod + Dio

The backend lives at the repository root. The Flutter client lives in the `mobile/` folder.

## 1. Prerequisites

Install these tools first:
- Node.js 18 or newer
- npm
- MySQL 8 or newer
- Flutter SDK 3.22 or newer
- Android Studio or another Flutter device target
- mysql command-line client, if you want to run SQL migrations from the terminal

Check versions:

```powershell
node -v
npm -v
flutter --version
mysql --version
```

## 2. Backend Setup

### 2.1 Install dependencies

From the repository root `a:\DO IT\ServeConnect`:

```powershell
npm install
```

### 2.2 Configure environment variables

Create a `.env` file in the repository root using [.env.example](.env.example) as the template.

Minimum required values:

```env
NODE_ENV=development
PORT=4000
DATABASE_URL=mysql://root:password@localhost:3306/serveconnect
JWT_SECRET=replace-with-a-long-random-secret
JWT_EXPIRES_IN=7d
BCRYPT_SALT_ROUNDS=12
CORS_ORIGIN=http://localhost:3000
MYSQL_SSL=false
```

Notes:
- `DATABASE_URL` must point to your MySQL instance.
- `JWT_SECRET` should be long and random.
- `CORS_ORIGIN` can be changed if your frontend runs on a different host.

### 2.3 Create the database

Create a MySQL database named `serveconnect` or use any name you prefer.

Example:

```powershell
mysql -u root -p -e "CREATE DATABASE serveconnect;"
```

If `mysql` is not available, create the database in MySQL Workbench or your database tool of choice.

### 2.4 Run the SQL migration

Apply the schema in [migrations/001_init.sql](migrations/001_init.sql).

Example with `mysql`:

```powershell
mysql -u root -p serveconnect < migrations/001_init.sql
```

What this creates:
- `users`
- `jobs`
- `applications`
- enum columns for user, job, and application status
- indexes and timestamp defaults

### 2.5 Start the backend

Development mode:

```powershell
npm run dev
```

Production build:

```powershell
npm run build
npm start
```

Backend entry points:
- [src/app.ts](src/app.ts)
- [src/server.ts](src/server.ts)

### 2.6 Backend health check

Once running, verify the API:

```powershell
curl http://localhost:4000/health
```

Expected response:

```json
{ "ok": true }
```

## 3. Mobile App Setup

### 3.1 Open the Flutter project

Open the `mobile` folder as a separate Flutter project:

- Folder: [mobile/](mobile)

### 3.2 Install Flutter dependencies

From the `mobile` folder:

```powershell
flutter pub get
```

### 3.3 Run the app in mock mode

The app now defaults to live API mode. To use mock data, pass `USE_MOCK_DATA=true`.

Start it with:

```powershell
flutter run
```

Mock mode is controlled in [mobile/lib/core/config/app_config.dart](mobile/lib/core/config/app_config.dart).

Before running the app after these changes, make sure you refresh Flutter packages so `shared_preferences` is installed:

```powershell
cd mobile
flutter pub get
```

### 3.4 Switch to the live backend

The live backend is already the default. Set the API base URL if needed, or override mock mode explicitly.

Example command:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

To force mock mode instead:

```powershell
flutter run --dart-define=USE_MOCK_DATA=true
```

### 3.5 Session And Profile Behavior

On startup the app now:
- Restores the stored JWT and user profile from local storage
- Validates the session with `GET /api/auth/me`
- Redirects by role to the correct dashboard

Profile data is available through:
- `GET /api/profile`
- `PUT /api/profile`

Admin management screens use:
- `GET /api/admin/users`
- `DELETE /api/admin/users/:id`
- `GET /api/admin/jobs`
- `DELETE /api/admin/jobs/:id`
- `GET /api/admin/applications`
- `DELETE /api/admin/applications/:id`

The new loading widgets and error mapping are already wired into the mobile app shell and API client.

Use this base URL depending on the target:
- Android emulator: `http://10.0.2.2:4000/api`
- iOS simulator: `http://localhost:4000/api`
- Physical device: your machine's LAN IP, for example `http://192.168.1.25:4000/api`

The network client lives in [mobile/lib/core/network/api_service.dart](mobile/lib/core/network/api_service.dart).

## 4. Login And Role Behavior

The mobile app has a shared auth screen with a role toggle:
- `STUDENT`
- `CATERER`

Once logged in:
- Students see the job feed and job details screen
- Caterers see the dashboard, create job form, and applicants screen

Relevant files:
- [mobile/lib/features/auth/views/auth_screen.dart](mobile/lib/features/auth/views/auth_screen.dart)
- [mobile/lib/features/auth/views/auth_gate.dart](mobile/lib/features/auth/views/auth_gate.dart)
- [mobile/lib/features/jobs/state/marketplace_controller.dart](mobile/lib/features/jobs/state/marketplace_controller.dart)

## 5. Working End To End

### Student flow

1. Start the backend.
2. Run the Flutter app.
3. Log in or register as a `STUDENT`.
4. Browse jobs on the feed.
5. Open job details.
6. Tap `Apply Now`.

### Caterer flow

1. Start the backend.
2. Run the Flutter app.
3. Log in or register as a `CATERER`.
4. Open the caterer dashboard.
5. Create a job.
6. Open the applicants screen.
7. Accept or reject applicants.

## 6. Important API Notes

Backend routes currently used by the app:
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/jobs`
- `POST /api/jobs`
- `GET /api/jobs/:jobId/applicants`
- `POST /api/applications/apply`
- `PUT /api/applications/status`

The applicants endpoint requires:
- Bearer JWT authentication
- `CATERER` role
- Ownership of the job

## 7. Troubleshooting

### Backend fails to start

Check:
- `.env` exists
- `DATABASE_URL` is correct
- MySQL is running
- Port `4000` is free

### Login fails in the mobile app

Check:
- Backend is running
- `USE_MOCK_DATA=false` if you expect live API calls
- `API_BASE_URL` points to the correct host and port
- JWT secret matches backend environment

### Mobile app shows no jobs

Check:
- In mock mode, the seeded data should show sample jobs
- In live mode, the backend `GET /api/jobs` endpoint should return open jobs
- The backend database should contain inserted jobs

### Applicants screen is empty

Check:
- You are logged in as a `CATERER`
- The caterer owns that job
- Students have submitted applications
- The backend endpoint `GET /api/jobs/:jobId/applicants` is available

### Android emulator cannot reach backend

Use `10.0.2.2` instead of `localhost`:

```powershell
flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

## 8. Recommended Daily Workflow

1. Start MySQL.
2. Start the backend with `npm run dev`.
3. Run the Flutter app with mock mode for quick UI work, or live mode for integration work.
4. Use the student flow and caterer flow to verify behavior.

## 9. Files That Matter Most

Backend:
- [package.json](package.json)
- [tsconfig.json](tsconfig.json)
- [migrations/001_init.sql](migrations/001_init.sql)
- [src/server.ts](src/server.ts)
- [src/app.ts](src/app.ts)

Mobile:
- [mobile/pubspec.yaml](mobile/pubspec.yaml)
- [mobile/lib/main.dart](mobile/lib/main.dart)
- [mobile/lib/app.dart](mobile/lib/app.dart)
- [mobile/lib/core/network/api_service.dart](mobile/lib/core/network/api_service.dart)
- [mobile/lib/features/jobs/state/marketplace_controller.dart](mobile/lib/features/jobs/state/marketplace_controller.dart)
- [mobile/lib/features/jobs/views/view_applicants_screen.dart](mobile/lib/features/jobs/views/view_applicants_screen.dart)

## 10. Short Version

Backend:

```powershell
npm install
copy .env.example .env
mysql -u root -p serveconnect < migrations/001_init.sql
npm run dev
```

Mobile:

```powershell
cd mobile
flutter pub get
flutter run
```

Live API mode:

```powershell
flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```
