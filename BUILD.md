# Build Pixelity

Pixelity utilise `LÖVE 11.5`.

Le projet peut etre lance en dev avec :

```bash
love .
```

## Principe

Les scripts de build creent d'abord un fichier `Pixelity.love`, puis l'emballent avec un runtime officiel de `LÖVE`.

Les runtimes ne sont pas dans le repo : il faut les ajouter dans `tools/`.

## Fichiers A Ajouter

### Linux

Extrais l'archive officielle Linux x64 de `LÖVE 11.5` dans :

```text
tools/love-linux64/
```

Le dossier doit au minimum contenir :

```text
tools/love-linux64/love
```

et les librairies `.so` fournies avec la distribution officielle.

### Windows

Extrais l'archive officielle Windows x64 de `LÖVE 11.5` dans :

```text
tools/love-win64/
```

Le dossier doit contenir :

```text
tools/love-win64/love.exe
```

plus toutes les `DLL` de la distribution officielle.

## Scripts

### Point d'entree unique

```bash
./scripts/build.sh love
./scripts/build.sh linux
./scripts/build.sh windows
```

Ce script appelle simplement le bon script specialise.

### Windows PowerShell

Sur Windows, tu peux aussi utiliser :

```powershell
.\scripts\build.ps1
```

Si `love.exe` n'est pas detecte automatiquement :

```powershell
.\scripts\build.ps1 -LoveExePath "C:\Program Files\LOVE\love.exe"
```

Ou en donnant directement le dossier du runtime :

```powershell
.\scripts\build.ps1 -RuntimeDir "C:\Program Files\LOVE"
```

Le script :
- cree `dist\Pixelity.love`
- cree `dist\Pixelity-windows\`
- copie les DLL et fichiers du runtime
- genere `Pixelity.exe`

Pour nettoyer les sorties :

```powershell
.\scripts\clean.ps1
```

### Generer seulement le `.love`

```bash
./scripts/build_love.sh
```

Sortie :

```text
dist/Pixelity.love
```

### Build Linux

```bash
./scripts/build_linux.sh
```

Sortie :

```text
dist/Pixelity-linux/
```

Dedans :
- `Pixelity`
- `Pixelity.love`
- le runtime `LÖVE`

### Build Windows

```bash
./scripts/build_windows.sh
```

Sortie :

```text
dist/Pixelity-windows/
```

Dedans :
- `Pixelity.exe`
- les `DLL`
- les autres fichiers du runtime `LÖVE`

## Remarques

- Windows : oui, il faut garder les `DLL` a cote de `Pixelity.exe`.
- Linux : oui, il faut garder le runtime et ses `.so` dans le dossier distribue.
- Les scripts ne telechargent rien automatiquement.
- Les scripts supposent `zip` installe sur la machine de build.
