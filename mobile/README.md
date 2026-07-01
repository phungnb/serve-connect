# ServeConnect Mobile

Flutter client for the ServeConnect marketplace.

## Structure

- `lib/main.dart` - app entry point
- `lib/app.dart` - MaterialApp bootstrap
- `lib/core/` - config, network, theme, and shared widgets
- `lib/features/auth/` - login/register UI and role-aware auth gate
- `lib/features/jobs/` - jobs data models, mock/remote repository, state, and role-specific screens

## Key Screens

- Shared auth screen with STUDENT/CATERER toggle
- Student job feed and job details with apply state
- Caterer dashboard with create-job flow
- Applicants list with accept/reject actions

## Run

1. Open the `mobile` folder in Flutter-capable tooling.
2. Run `flutter pub get`.
3. Start with mock data enabled by default.
4. Set `USE_MOCK_DATA=false` and `API_BASE_URL` when connecting to the Node API.
