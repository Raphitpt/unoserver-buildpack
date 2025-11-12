# Unoserver Buildpack for Scalingo

Buildpack simple pour déployer une application utilisant Bun, LibreOffice et unoserver sur Scalingo.

## Composants installés

- LibreOffice Writer
- Python3 et pip
- unoserver
- Fonts Liberation et DejaVu
- Bun runtime
- Netcat (pour les health checks)

## Utilisation

### 1. Créer un dépôt Git pour votre buildpack

```bash
# Initialiser le dépôt git dans le dossier du buildpack
git init
git add .
git commit -m "Initial buildpack commit"

# Pousser vers un dépôt distant (GitHub, GitLab, etc.)
git remote add origin <URL_DE_VOTRE_DEPOT>
git push -u origin main
```

### 2. Configurer votre application Scalingo

Dans le dossier de votre application :

```bash
# Créer un fichier .buildpacks
echo "https://github.com/<VOTRE_USER>/<VOTRE_REPO>.git" > .buildpacks

# Ou définir via la variable d'environnement
scalingo env-set BUILDPACK_URL=https://github.com/<VOTRE_USER>/<VOTRE_REPO>.git
```

### 3. Structure de votre application

Votre application doit contenir :

```
votre-app/
├── server.sh          # Script de démarrage (obligatoire)
├── package.json       # Dépendances Bun
├── bun.lock          # Lock file Bun
├── fonts/            # Polices personnalisées (optionnel)
│   └── *.ttf
└── .buildpacks       # Configuration buildpack
```

### 4. Déployer

```bash
git push scalingo main
```

## Détection

Le buildpack se déclenche automatiquement si un fichier `server.sh` est présent à la racine de votre application.

## Process par défaut

Le buildpack lance automatiquement :
```bash
/bin/bash ./server.sh --dev
```

Pour modifier le process de démarrage, utilisez un `Procfile` :
```
web: /bin/bash ./server.sh --production
```

## Variables d'environnement

Le buildpack configure automatiquement :
- `PATH` : inclut `/app/.bun/bin` pour accéder à Bun

## Polices personnalisées

Si vous avez un dossier `fonts/` dans votre application, les polices seront automatiquement installées et le cache de polices sera mis à jour.

## Support

Pour les problèmes liés au buildpack, créez une issue sur le dépôt du buildpack.
