# Chatboot - Mini-Projet Flutter / SOA

Application de chatbot avec authentification, historique par utilisateur et conversations multiples.

## Fonctionnalités

- Inscription et connexion avec validation.
- Authentification utilisateur avec Firebase Authentication.
- Vérification de la session au démarrage et déconnexion.
- Conversations multiples, renommage, suppression et historique persistant.
- Intégration Gemini avec `--dart-define=GEMINI_API_KEY=VOTRE_CLE`.
- Consommation du backend REST Spring Boot avec jeton Bearer.
- Service SOAP JAX-WS avec deux opérations.
- Firebase Authentication pour l’inscription, la connexion et la session.
Firebase est utilisé pour l’authentification. Les conversations sont enregistrées dans
MongoDB Atlas dans la base `Chat`, collection `boot`, avec un `userId` correspondant
à l’UID Firebase.

## Configuration Firebase Android

Le fichier `android/app/google-services.json` est configuré pour le projet Firebase
`chatboot-c4335` avec l’ID Android `com.company.chat`.

Dans Firebase Console:

1. Activez **Authentication > Sign-in method > Email/Password**.
2. Autorisez les utilisateurs Email/Password.
3. La liste Firebase doit contenir au moins un utilisateur pour tester la connexion.

## Configuration MongoDB

Avant de démarrer Spring Boot, définissez la variable d’environnement dans PowerShell:

```powershell
$env:MONGODB_URI="mongodb+srv://<utilisateur>:<mot-de-passe>@cluster0.btniozz.mongodb.net/"
cd backend-rest
mvn spring-boot:run
```

La base `Chat` est définie dans `application.properties`; les conversations sont stockées
dans la collection `boot`. Ne mettez pas votre URI réelle dans le dépôt Git.

## Lancement Flutter

```powershell
flutter pub get
flutter run -d windows --dart-define=GEMINI_API_KEY=VOTRE_CLE
```

Pour Android:

```powershell
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8080 --dart-define=GEMINI_API_KEY=VOTRE_CLE
```

Pour le Web, `google-services.json` ne suffit pas : il configure uniquement Android.
Ajoutez une application Web dans les paramètres du projet Firebase, puis lancez
Chrome avec les valeurs de configuration de cette application :

```powershell
flutter run -d chrome `
  --dart-define=FIREBASE_API_KEY=VOTRE_API_KEY_WEB `
  --dart-define=FIREBASE_APP_ID=VOTRE_APP_ID_WEB `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=VOTRE_SENDER_ID `
  --dart-define=FIREBASE_PROJECT_ID=chatboot-c4335 `
  --dart-define=GEMINI_API_KEY=VOTRE_CLE
```

Récupérez ces valeurs dans la configuration de l’application Web Firebase, et non
dans `google-services.json`.

Sur Windows, si les plugins affichent une erreur de liens symboliques, activez le Mode développeur Windows.

## Backend REST

```powershell
cd backend-rest
mvn spring-boot:run
```

- API: `http://localhost:8080`
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI statique: `docs/openapi.yaml`
- Les endpoints `/api/**` exigent `Authorization: Bearer <token>`.
- `/api/chat` accepte POST avec `{ "message": "Bonjour", "history": [] }`.

## Backend SOAP

```powershell
cd backend-soap
mvn compile
mvn exec:java -Dexec.mainClass=tn.chatboot.SoapServer
```

- WSDL dynamique: `http://localhost:8181/chat?wsdl`
- WSDL livré: `docs/chatservice.wsdl`
- Opérations: `sendMessage`, `getConversationSummary`.

## Tests

Importer `docs/postman_collection.json` dans Postman. Dans les variables de la collection,
renseignez `firebase_api_key` depuis `android/app/google-services.json`, ainsi que
`firebase_email` et `firebase_password` d’un utilisateur Firebase Email/Password.
Exécutez **Firebase - Connexion** une fois : la collection enregistre automatiquement
son `idToken`, utilisé ensuite comme Bearer pour les endpoints REST. Pour créer un compte
de test, utilisez d’abord **Firebase - Inscription**.

Exécutez ensuite Health, Chat, Créer, Lister, Modifier et Supprimer. Health doit répondre
`200`; les opérations protégées utilisent le jeton Firebase. Un `401` signifie que le jeton
est vide, expiré ou ne vient pas du projet Firebase `chatboot-c4335`.

Importer `docs/chatservice.wsdl` dans SoapUI pour tester les deux opérations SOAP.
