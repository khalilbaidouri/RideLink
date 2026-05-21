-- =============================================
-- USERS
-- =============================================
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text unique not null,
  phone text,
  avatar_url text,
  role text check (role in ('driver', 'passenger')),
  rating float default 0,
  total_reviews int default 0,
  created_at timestamptz default now()
);
-- alter table public.users enable row level security;

-- =============================================
-- CITIES
-- =============================================
create table public.cities (
  id    bigint generated always as identity primary key,
  name  text not null,
  lat   float,
  lng   float
);
-- alter table public.cities enable row level security;

-- =============================================
-- VEHICLES
-- =============================================
create table public.vehicles (
  id           bigint generated always as identity primary key,
  driver_id    bigint references public.users(id) on delete cascade,
  brand        text,
  model        text,
  color        text,
  plate_number text,
  seats        int,
  created_at   timestamptz default now()
);
-- alter table public.vehicles enable row level security;

-- =============================================
-- RIDES
-- =============================================
create table public.rides (
  id                  bigint generated always as identity primary key,
  driver_id           bigint references public.users(id) on delete cascade,
  vehicle_id          bigint references public.vehicles(id) on delete set null,
  departure_city_id   bigint references public.cities(id),
  destination_city_id bigint references public.cities(id),
  departure_address   text,
  destination_address text,
  departure_time      timestamptz,
  price               decimal,
  available_seats     int,
  status              text check (status in ('active', 'completed', 'cancelled')),
  created_at          timestamptz default now()
);
-- alter table public.rides enable row level security;

-- =============================================
-- BOOKINGS
-- =============================================
create table public.bookings (
  id             bigint generated always as identity primary key,
  ride_id        bigint references public.rides(id) on delete cascade,
  passenger_id   bigint references public.users(id) on delete cascade,
  seats_reserved int,
  total_price    decimal,
  status         text check (status in ('pending', 'confirmed', 'cancelled')),
  booked_at      timestamptz default now()
);
-- alter table public.bookings enable row level security;


-- =============================================
-- CONVERSATIONS
-- =============================================
create table public.conversations (
  id         bigint generated always as identity primary key,
  ride_id    bigint references public.rides(id) on delete cascade,
  created_at timestamptz default now()
);
-- alter table public.conversations enable row level security;

-- =============================================
-- MESSAGES
-- =============================================
create table public.messages (
  id              bigint generated always as identity primary key,
  conversation_id bigint references public.conversations(id) on delete cascade,
  sender_id       bigint references public.users(id) on delete cascade,
  content         text,
  is_read         boolean default false,
  sent_at         timestamptz default now()
);
-- alter table public.messages enable row level security;

-- =============================================
-- REVIEWS
-- =============================================
create table public.reviews (
  id               bigint generated always as identity primary key,
  ride_id          bigint references public.rides(id) on delete cascade,
  reviewer_id      bigint references public.users(id) on delete cascade,
  reviewed_user_id bigint references public.users(id) on delete cascade,
  rating           float check (rating >= 1 and rating <= 5),
  comment          text,
  created_at       timestamptz default now()
);
-- alter table public.reviews enable row level security;