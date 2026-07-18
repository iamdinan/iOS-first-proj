# PlayHub

PlayHub is an iOS project built with SwiftUI. The application provides a small arcade-style game hub with three game modes, local score tracking, a statistics screen, a map view for recorded play locations, and optional daily challenge notifications.

## Architecture Overview

The project follows a lightweight SwiftUI structure with separate areas for app entry, views, view models, models, services, and shared UI components.

```text
iOS-101/
+-- PlayHubApp/
|   +-- App/             # App entry point
|   +-- Models/          # Game modes, sessions, trivia data, and game state models
|   +-- Services/        # Persistence, trivia API, location, and notification services
|   +-- ViewModels/      # Game and statistics logic
+-- Views/
|   +-- Games/           # Tap Frenzy, Light It Up, and Quiz Rush screens
|   +-- Tabs/            # Home, Stats, Map, and Settings tabs
+-- Shared/              # Reusable SwiftUI components and theme definitions
+-- Assets.xcassets/     # App icon, accent color, and asset catalog files
```

The app starts in `PlayHubApp.swift`, where the root SwiftUI scene is created and `LocationService` is injected into the environment. `RootTabView` defines the main tab-based navigation, giving users access to Home, Stats, Map, and Settings.

The game screens use view models to keep gameplay logic separate from the SwiftUI layout:

- `TapFrenzyVM` manages the timed tapping game, score multiplier, button colour changes, and high score submission.
- `LightItUpVM` manages the card grid, level changes, lives, timers, score changes, and high score submission.
- `QuizRushVM` loads trivia questions from the Open Trivia Database API and manages answer selection, scoring, streaks, and round completion.
- `StatsVM` loads stored game sessions and calculates summary values for the statistics screen.

Persistence is handled locally through `UserDefaults`. `SessionStore` stores completed game sessions, while `HighScoreStore` keeps the top 10 scores for each game mode. This keeps the project simple and suitable for a coursework-scale mobile application without requiring a backend database.

The main external platform features used are:

- `SwiftUI` for the user interface.
- `Charts` for score visualisation.
- `MapKit` and `CoreLocation` for displaying recorded game locations.
- `UserNotifications` for daily challenge reminders.
- `URLSession` for fetching Quiz Rush trivia questions.

## Features List

- Tab-based SwiftUI app structure with Home, Stats, Map, and Settings sections.
- Three playable game modes:
  - Tap Frenzy: a 10-second tapping game with score multipliers, bonus states, trap states, and moving button positions.
  - Light It Up: a 60-second reaction game with a changing card grid, levels, lives, penalties, and visual feedback.
  - Quiz Rush: a multiple-choice trivia game using online questions from the Open Trivia Database.
- Local high score tracking for each game mode, storing the top 10 scores.
- Shared result screen with final score, new high score feedback, replay option, high score list, and score sharing.
- Game session history saved after completed rounds.
- Statistics tab showing per-mode summaries, recent games, and a bar chart of scores.
- Map tab showing saved game sessions that include valid location coordinates.
- Settings tab for daily challenge notification scheduling and clearing stored game history.
- Reusable theme and shared UI components for a consistent arcade-style appearance.

## Known Limitations

These limitations reflect the current coursework scope and are useful areas for future improvement:

- Data is stored with `UserDefaults`, which is suitable for small local records but not intended for large datasets, account syncing, or multi-device persistence.
- Quiz Rush depends on an internet connection and the availability of the Open Trivia Database API. If the API is unavailable, rate-limited, or the device is offline, the app shows an error and allows retrying.
- Location is recorded only from the latest available device location. If location permission is denied, unavailable, or not yet updated, the session may be saved without a meaningful map coordinate.
- The Map screen filters out sessions with a latitude of `0`, which avoids displaying placeholder records but may also hide any real-world location with that exact latitude.
- Daily notifications are local device notifications only. There is no server-side challenge system or shared leaderboard.
- High scores and session history are local to the current installation and can be lost if the app data is removed.

## Reflection

This project demonstrates how a SwiftUI application can combine multiple iOS concepts within a focused game hub. The implementation separates gameplay rules into view models, keeps UI components reusable, and uses services for persistence, location, notifications, and network access. This structure makes the app easier to understand because the main screens are not responsible for every detail of scoring, storage, or platform integration.

The strongest part of the project is the range of iOS features used in a coherent way. The games provide different interaction styles, while the statistics and map screens give meaning to completed sessions after gameplay ends. The app also shows practical use of local persistence, API loading, charts, sharing, and notification scheduling.

The main improvement areas are reliability, polish, and test coverage. A future version could replace `UserDefaults` session storage with SwiftData or Core Data, add automated tests for scoring rules, and improve handling of missing location data. These improvements would make the project more robust while preserving the current coursework-friendly architecture.
