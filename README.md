# RideLink

Academic mobile project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Tasks
- Badr : Home | Search | Ride Detail
- Mouad: Profile | Settings | Dashboard 
- Brahim : Notifications | Booking requests | No rides founs
- Khalil : 3 Create Ride | Leave a Review


# pick_them/

```text
pick_them/
│
├── app/                          # Flutter app
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/           # Supabase init, env
│   │   │   ├── constants/        # colors, strings, routes
│   │   │   ├── services/         # supabase client, maps, auth
│   │   │   ├── utils/            # helpers, validators
│   │   │   └── widgets/          # reusable widgets
│   │   │
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── rides/
│   │   │   ├── booking/
│   │   │   ├── chat/
│   │   │   ├── tracking/
│   │   │   ├── profile/
│   │   │   └── notifications/
│   │   │
│   │   ├── shared/
│   │   │   ├── models/           # user, ride, booking models
│   │   │   └── widgets/
│   │   │
│   │   └── main.dart
│   │
│   └── pubspec.yaml
│
├── supabase/                     # Backend Supabase
│   ├── migrations/               # DB schema versioning
│   │   ├── 0001_init_users.sql
│   │   ├── 0002_vehicles.sql
│   │   ├── 0003_rides.sql
│   │   ├── 0004_bookings.sql
│   │   ├── 0005_messages.sql
│   │   ├── 0006_tracking.sql
│   │   ├── 0007_reviews.sql
│   │   └── 0008_notifications.sql
│   │
│   ├── seed.sql                  # fake data for testing
│   ├── functions/                # Edge Functions
│   │   ├── create_booking/
│   │   ├── calculate_price/
│   │   └── send_notification/
│   │
│   └── config.toml              # Supabase CLI config
│
├── docs/                         # Project documentation
│   ├── erd.txt                   # ER diagram code
│   ├── architecture.txt
│   └── api_flow.md
│
├── .env                          # Supabase keys
├── .gitignore
└── README.md
