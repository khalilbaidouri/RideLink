# Documentation du projet RideLink

## 1. Resume rapide

RideLink est une application mobile Flutter de covoiturage. L'objectif est de permettre a un utilisateur de:

- s'inscrire et se connecter avec Supabase,
- voyager comme passager,
- proposer des trajets comme conducteur,
- gerer ses vehicules,
- consulter ses activites, notifications et messages.

Le projet utilise une navigation differenciee selon le role de l'utilisateur: **passager** ou **conducteur**. Un troisieme mode, **BOTH**, existe pour un utilisateur qui peut a la fois voyager et conduire.

## 2. Stack technique

- **Flutter**: interface mobile.
- **Riverpod**: gestion d'etat.
- **GoRouter**: navigation et redirections.
- **Supabase**: authentification et base de donnees.
- **google_maps_flutter** / **geolocator** / **geocoding**: fonctions liees a la localisation.
- **http**: requetes reseau.
- **intl**: formats de dates et textes localises.

Le point d'entree principal est [lib/main.dart](lib/main.dart).

## 3. Demarrage de l'application

Dans [lib/main.dart](lib/main.dart), l'application:

1. initialise Flutter,
2. initialise Supabase avec `AppConfig.supabaseUrl` et `AppConfig.supabaseAnonKey`,
3. lance `ProviderScope` pour Riverpod,
4. affiche `MaterialApp.router`, configure avec `appRouter`.

Cela veut dire que la navigation est centralisee dans le routeur et que Supabase est disponible partout dans l'application.

## 4. Architecture generale

La structure suit une logique par fonctionnalite:

- `core/` pour la configuration, le routeur, le theme et les composants communs,
- `features/` pour les ecrans metier,
- `models/` pour les modeles de donnees,
- `supabase/` pour les migrations et le seed,
- `test/` pour les tests Flutter.

### Dossiers importants

- [lib/core/router/app_router.dart](lib/core/router/app_router.dart): routes, redirections et protection d'acces.
- [lib/features/auth/signup.dart](lib/features/auth/signup.dart): inscription et choix du role.
- [lib/features/profile/profile_screen.dart](lib/features/profile/profile_screen.dart): profil et acces aux vehicules.
- [lib/features/vehicles/presentation/screens/vehicles_screen.dart](lib/features/vehicles/presentation/screens/vehicles_screen.dart): liste et formulaire vehicules.
- [lib/features/vehicles/providers/vehicles_provider.dart](lib/features/vehicles/providers/vehicles_provider.dart): logique des vehicules avec Riverpod.

## 5. Systeme de roles

L'application gere trois valeurs dans l'inscription:

- `PASSENGER`
- `DRIVER`
- `BOTH`

### Important pour le controle d'acces

Dans [lib/core/router/app_router.dart](lib/core/router/app_router.dart), la fonction `_isDriverRole()` retourne `true` pour:

- `DRIVER`
- `BOTH`

Donc un utilisateur `BOTH` est considere comme conducteur par la navigation et peut acceder a l'espace conducteur.

### Effet concret

- `PASSENGER` va vers `/passenger/home`
- `DRIVER` va vers `/driver/dashboard`
- `BOTH` va aussi vers `/driver/dashboard`

## 6. Authentification et redirection

Le routeur fait une verification automatique:

1. si l'utilisateur n'est pas connecte, il est renvoye vers `/login` pour les zones proteges,
2. si l'utilisateur est connecte et ouvre une page d'authentification, il est redirige vers sa page d'accueil,
3. si un conducteur essaie d'ouvrir une route passager, il est renvoye vers le tableau de bord conducteur,
4. si un passager essaie d'ouvrir une route conducteur, il est renvoye vers l'accueil passager.

Cette logique se trouve dans `redirect:` du routeur.

## 7. Navigation principale

### Espace passager

Les routes principales sont:

- `/passenger/home`
- `/passenger/rides`
- `/passenger/notifications`
- `/passenger/messages`
- `/passenger/profile`

### Espace conducteur

Les routes principales sont:

- `/driver/dashboard`
- `/driver/activity`
- `/driver/add-ride`
- `/driver/alerts`
- `/driver/profile`

### Vehicules

La gestion des vehicules est branchee dans le profil conducteur:

- `/driver/profile/vehicles`

Le formulaire s'ouvre dans une bottom sheet, pas dans un nouvel ecran complet.

## 8. Fonctionnement des vehicules

La partie vehicules est composee de deux elements:

- le provider Riverpod,
- l'ecran de gestion.

### Provider

Dans [lib/features/vehicles/providers/vehicles_provider.dart](lib/features/vehicles/providers/vehicles_provider.dart):

- les vehicules sont charges depuis Supabase,
- ils sont filtres par `driver_id = currentUser.id`,
- l'etat garde la liste, le chargement et les erreurs,
- les operations disponibles sont:
  - ajouter un vehicule,
  - modifier un vehicule,
  - supprimer un vehicule,
  - definir un vehicule par defaut.

### Ecran vehicules

Dans [lib/features/vehicles/presentation/screens/vehicles_screen.dart](lib/features/vehicles/presentation/screens/vehicles_screen.dart):

- la liste des vehicules est affichee,
- un bouton permet d'ajouter un vehicule,
- un autre permet d'en ajouter depuis l'etat vide,
- le formulaire contient:
  - marque,
  - modele,
  - immatriculation,
  - couleur,
  - annee,
  - categorie,
  - nombre de places.

### Point important pour expliquer au professeur

Quand l'utilisateur clique sur **Add Vehicle**, l'application doit aller vers:

- `/driver/profile/vehicles`

Pas vers une route passager. C'est pour cela que le role conducteur/BOTH est necessaire.

## 9. Inscription

Dans [lib/features/auth/signup.dart](lib/features/auth/signup.dart):

- l'utilisateur renseigne nom, email, telephone et mot de passe,
- il choisit son role,
- apres creation du compte, un enregistrement est ajoute dans la table `users` de Supabase,
- la page suivante depend du role choisi.

### Traduction simple du flux

- PASSENGER: je voyage seulement,
- DRIVER: je propose des trajets et je gere mes vehicules,
- BOTH: je peux faire les deux.

## 10. Supabase

Supabase sert a:

- authentifier l'utilisateur,
- stocker le profil utilisateur,
- stocker les vehicules,
- probablement gerer les trajets, reservations, notifications et messages.

Le dossier [supabase/](supabase/) contient:

- `config.toml`,
- `seed.sql`,
- `migrations/`.

### A savoir pour l'oral

Si ton professeur demande "ou sont stockees les donnees ?", reponds:

- dans Supabase,
- avec authentification et tables Postgres,
- et la logique d'acces est principalement pilotee cote application via le routeur et les providers.

## 11. Fichiers a connaitre pour l'examen

### Fichiers principaux

- [lib/main.dart](lib/main.dart)
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart)
- [lib/features/auth/signup.dart](lib/features/auth/signup.dart)
- [lib/features/profile/profile_screen.dart](lib/features/profile/profile_screen.dart)
- [lib/features/vehicles/presentation/screens/vehicles_screen.dart](lib/features/vehicles/presentation/screens/vehicles_screen.dart)
- [lib/features/vehicles/providers/vehicles_provider.dart](lib/features/vehicles/providers/vehicles_provider.dart)

### Ce qu'il faut retenir de chaque fichier

- `main.dart`: demarrage de l'app et initialisation Supabase.
- `app_router.dart`: navigation, roles, protection des routes.
- `signup.dart`: creation du compte et choix du role.
- `profile_screen.dart`: acces au profil et aux vehicules.
- `vehicles_screen.dart`: affichage et ajout/modification/suppression des vehicules.
- `vehicles_provider.dart`: logique d'etat et communication avec Supabase.

## 12. Questions probables du professeur

### 1. Quel est le but de l'application ?
RideLink est une application de covoiturage qui relie passagers et conducteurs.

### 2. Quelle technologie utilisez-vous ?
Flutter pour le frontend mobile, Riverpod pour l'etat, GoRouter pour la navigation, Supabase pour l'authentification et la base de donnees.

### 3. Comment gerez-vous les roles ?
Au moment de l'inscription, l'utilisateur choisit PASSENGER, DRIVER ou BOTH. Le routeur lit le role dans la table `users` et redirige vers la bonne zone.

### 4. Qui peut ajouter un vehicule ?
Le conducteur et le role BOTH.

### 5. Ou sont les vehicules stockes ?
Dans Supabase, avec association a l'utilisateur conducteur via `driver_id`.

### 6. Pourquoi utiliser GoRouter ?
Pour gerer proprement les routes, les sous-routes et les redirections selon le role.

## 13. Phrase simple pour presenter le projet

"RideLink est une application Flutter de covoiturage connectee a Supabase. Elle separa les espaces passager et conducteur grace a GoRouter, et permet a un utilisateur conducteur ou BOTH de gerer ses vehicules, ses trajets et son profil."

## 14. Conseils pour l'oral

- Commence par expliquer le but du projet en 1 phrase.
- Puis parle de la stack technique.
- Ensuite explique le systeme de roles.
- Termine par le cas d'usage vehicule, car c'est facile a montrer.
