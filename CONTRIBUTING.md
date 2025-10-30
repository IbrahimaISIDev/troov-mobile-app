# Contribuer à Troov

## Prérequis

- Flutter SDK installé et configuré.
- Exécuter `flutter pub get` avant de lancer l’application.

## Branching

- `main`: stable.
- Créez des branches par feature ou fix: `feature/<nom>` ou `fix/<nom>`.

## Commits

- Messages clairs et concis. Exemple: `feat(auth): ajout du flux de reset password`.

## Qualité & Lint

- Les règles `flutter_lints` sont activées (voir `analysis_options.yaml`).
- Corrigez les warnings avant PR.

## Tests

- Ajoutez des tests unitaires pertinents dans `test/`.
- Exécutez `flutter test` et assurez-vous qu’ils passent.

## Revue de code (PR)

- Décrivez le contexte, la solution et les impacts.
- Ajoutez des captures/vidéos si l’UI change.
- Checklist avant PR:
  - [ ] Lints OK
  - [ ] Tests OK
  - [ ] Docs mises à jour (README/ARCHITECTURE si nécessaire)

## Style de code

- Respectez la structure: `models/`, `services/`, `screens/`, `widgets/`, `utils/`.
- Nommez clairement classes, méthodes et variables.
