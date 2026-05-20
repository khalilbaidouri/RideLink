-- supabase/migrations/20260506155909_auth_schema.sql
-- Single source of truth for the full RideLink schema.
-- Run order: this file supersedes 20260506153522_init_schema.sql (delete that file).

-- =============================================
-- USERS
-- =============================================
create table public.users (
  id            uuid        primary key references auth.users(id) on delete cascade,
  full_name     text,
  email         text        unique not null,
  phone         text,
  avatar_url    text,
  role          text        check (role in ('driver', 'passenger')),
  rating        float       default 0,
  total_reviews int         default 0,
  created_at    timestamptz default now()
);

-- RLS is enabled via policies defined below
-- alter table public.users enable row level security;

-- RLS policies will be created directly via SQL commands
-- create policy "users_can_read_own_profile"
--   on public.users
--   for select
--   to authenticated
--   using (auth.uid() = id);
--
-- create policy "users_can_update_own_profile"
--   on public.users
--   as permissive
--   for update
--   to authenticated
--   using (auth.uid() = id);

-- =============================================
-- CITIES
-- =============================================
create table public.cities (
  id   bigint generated always as identity primary key,
  name text   not null,
  lat  float,
  lng  float
);

-- alter table public.cities
--   enable row level security;
--
-- create policy "Cities are readable by all authenticated users"
--   on public.cities
--   as permissive
--   for select
--   to authenticated
--   using (true);

-- =============================================
-- VEHICLES
-- =============================================
create table public.vehicles (
  id           bigint generated always as identity primary key,
  driver_id    uuid        references public.users(id) on delete cascade,
  brand        text,
  model        text,
  color        text,
  plate_number text,
  seats        int,
  created_at   timestamptz default now()
);

-- alter table public.vehicles
--   enable row level security;
--
-- create policy "Drivers manage own vehicles"
--   on public.vehicles
--   as permissive
--   for all
--   to authenticated
--   using (auth.uid() = driver_id);

-- =============================================
-- RIDES
-- =============================================
create table public.rides (
  id                  bigint      generated always as identity primary key,
  driver_id           uuid        references public.users(id) on delete cascade,
  vehicle_id          bigint      references public.vehicles(id) on delete set null,
  departure_city_id   bigint      references public.cities(id),
  destination_city_id bigint      references public.cities(id),
  departure_address   text,
  destination_address text,
  departure_time      timestamptz,
  price               decimal,
  available_seats     int,
  status              text        check (status in ('active', 'completed', 'cancelled')),
  created_at          timestamptz default now()
);

-- alter table public.rides
--   enable row level security;
--
-- create policy "Rides are readable by all authenticated users"
--   on public.rides
--   as permissive
--   for select
--   to authenticated
--   using (true);
--
-- create policy "Drivers manage own rides"
--   on public.rides
--   as permissive
--   for all
--   to authenticated
--   using (auth.uid() = driver_id);

-- =============================================
-- BOOKINGS
-- =============================================
create table public.bookings (
  id             bigint      generated always as identity primary key,
  ride_id        bigint      references public.rides(id) on delete cascade,
  passenger_id   uuid        references public.users(id) on delete cascade,
  seats_reserved int,
  total_price    decimal,
  status         text        check (status in ('pending', 'confirmed', 'cancelled')),
  booked_at      timestamptz default now()
);

-- alter table public.bookings
--   enable row level security;

-- Passenger sees their own bookings
-- create policy "Passengers see own bookings"
--   on public.bookings
--   as permissive
--   for select
--   to authenticated
--   using (auth.uid() = passenger_id);
--
-- Driver sees bookings for their rides
-- create policy "Drivers see bookings on own rides"
--   on public.bookings
--   as permissive
--   for select
--   to authenticated
--   using (
--     exists (
--       select 1 from public.rides
--       where rides.id = bookings.ride_id
--         and rides.driver_id = auth.uid()
--     )
--   );
--
-- Passenger inserts their own bookings
-- create policy "Passengers insert own bookings"
--   on public.bookings
--   as permissive
--   for insert
--   to authenticated
--   with check (auth.uid() = passenger_id);
--
-- Driver updates status (accept/reject)
-- create policy "Drivers update bookings on own rides"
--   on public.bookings
--   as permissive
--   for update
--   to authenticated
--   using (
--     exists (
--       select 1 from public.rides
--       where rides.id = bookings.ride_id
--         and rides.driver_id = auth.uid()
--     )
--   );
--
-- Passenger can cancel their own booking
-- create policy "Passengers update own bookings"
--   on public.bookings
--   as permissive
--   for update
--   to authenticated
--   using (auth.uid() = passenger_id);

-- =============================================
-- NOTIFICATIONS
-- =============================================
create table public.notifications (
  id         bigint      generated always as identity primary key,
  user_id    uuid        not null references public.users(id) on delete cascade,
  type       text        not null default 'system' check (
               type in (
                 'booking_accepted',
                 'booking_rejected',
                 'booking_request',
                 'ride_cancelled',
                 'ride_reminder',
                 'review_received',
                 'system'
               )
             ),
  title      text        not null,
  body       text        not null,
  payload    jsonb       not null default '{}',
  is_read    boolean     not null default false,
  created_at timestamptz not null default now()
);

create index notifications_user_created
  on public.notifications (user_id, created_at desc);

-- alter table public.notifications
--   enable row level security;
--
-- create policy "Users see own notifications"
--   on public.notifications
--   as permissive
--   for select
--   to authenticated
--   using (auth.uid() = user_id);
--
-- create policy "Users update own notifications"
--   on public.notifications
--   as permissive
--   for update
--   to authenticated
--   using (auth.uid() = user_id);
--
-- create policy "Users delete own notifications"
--   on public.notifications
--   as permissive
--   for delete
--   to authenticated
--   using (auth.uid() = user_id);

-- =============================================
-- CONVERSATIONS
-- =============================================
create table public.conversations (
  id         bigint      generated always as identity primary key,
  ride_id    bigint      references public.rides(id) on delete cascade,
  created_at timestamptz default now()
);

-- alter table public.conversations
--   enable row level security;
--
-- create policy "Ride participants see conversations"
--   on public.conversations
--   as permissive
--   for select
--   to authenticated
--   using (
--     exists (
--       select 1 from public.rides
--       where rides.id = conversations.ride_id
--         and rides.driver_id = auth.uid()
--     )
--     or
--     exists (
--       select 1 from public.bookings
--       where bookings.ride_id = conversations.ride_id
--         and bookings.passenger_id = auth.uid()
--     )
--   );

-- =============================================
-- MESSAGES
-- =============================================
create table public.messages (
  id              bigint      generated always as identity primary key,
  conversation_id bigint      references public.conversations(id) on delete cascade,
  sender_id       uuid        references public.users(id) on delete cascade,
  content         text,
  is_read         boolean     default false,
  sent_at         timestamptz default now()
);

-- alter table public.messages
--   enable row level security;
--
-- create policy "Participants see messages in their conversations"
--   on public.messages
--   as permissive
--   for select
--   to authenticated
--   using (
--     exists (
--       select 1 from public.conversations
--       join public.rides on rides.id = conversations.ride_id
--       where conversations.id = messages.conversation_id
--         and (
--           rides.driver_id = auth.uid()
--           or exists (
--             select 1 from public.bookings
--             where bookings.ride_id = rides.id
--               and bookings.passenger_id = auth.uid()
--           )
--         )
--     )
--   );
--
-- create policy "Participants send messages"
--   on public.messages
--   as permissive
--   for insert
--   to authenticated
--   with check (auth.uid() = sender_id);

-- =============================================
-- REVIEWS
-- =============================================
create table public.reviews (
  id               bigint      generated always as identity primary key,
  ride_id          bigint      references public.rides(id) on delete cascade,
  reviewer_id      uuid        references public.users(id) on delete cascade,
  reviewed_user_id uuid        references public.users(id) on delete cascade,
  rating           float       check (rating >= 1 and rating <= 5),
  comment          text,
  created_at       timestamptz default now()
);

-- alter table public.reviews
--   enable row level security;
--
-- create policy "Reviews are readable by all authenticated users"
--   on public.reviews
--   as permissive
--   for select
--   to authenticated
--   using (true);

-- create policy "Users insert own reviews"
--   on public.reviews
--   as permissive
--   for insert
--   to authenticated
--   with check (auth.uid() = reviewer_id);