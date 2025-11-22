# Guía de Despliegue en GitHub Pages

Esta guía te ayudará a desplegar tu aplicación Flutter web en GitHub Pages.

## Opción 1: Despliegue Automático con GitHub Actions (Recomendado)

### Pasos:

1. **Habilita GitHub Pages en tu repositorio:**
   - Ve a Settings > Pages en tu repositorio de GitHub
   - En "Source", selecciona "GitHub Actions"

2. **Ajusta el base-href en el workflow:**
   - Si tu repositorio es `username.github.io`, el base-href debe ser `"/"`
   - Si tu repositorio es `username/repo-name`, el base-href debe ser `"/repo-name/"`
   - Edita `.github/workflows/deploy.yml` y ajusta la línea:
     ```yaml
     run: flutter build web --release --base-href "/TU_REPO_NAME/" --dart-define=FLUTTER_WEB_USE_SKIA=false
     ```

3. **Haz push a la rama main:**
   ```bash
   git add .
   git commit -m "Configurar despliegue en GitHub Pages"
   git push origin main
   ```

4. **Verifica el despliegue:**
   - Ve a la pestaña "Actions" en tu repositorio
   - Espera a que el workflow termine
   - Tu app estará disponible en: `https://username.github.io/repo-name/`

## Opción 2: Despliegue Manual

### Pasos:

1. **Construye la app:**
   ```bash
   flutter build web --release --base-href "/TU_REPO_NAME/" --dart-define=FLUTTER_WEB_USE_SKIA=false
   ```

2. **Crea la rama gh-pages:**
   ```bash
   git checkout --orphan gh-pages
   git rm -rf .
   ```

3. **Copia los archivos de build:**
   ```bash
   cp -r build/web/* .
   touch .nojekyll
   ```

4. **Haz commit y push:**
   ```bash
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push origin gh-pages
   ```

5. **Configura GitHub Pages:**
   - Ve a Settings > Pages
   - Selecciona la rama `gh-pages` como source
   - Guarda los cambios

## Configuración del Base Href

El `base-href` es crucial para que las rutas funcionen correctamente en GitHub Pages:

- **Repositorio raíz** (`username.github.io`): `--base-href "/"`
- **Repositorio con nombre** (`username/repo-name`): `--base-href "/repo-name/"`

## Solución de Problemas

### Las rutas no funcionan al recargar la página

GitHub Pages no soporta rutas del lado del servidor. Necesitas configurar un `404.html` que redirija a `index.html`. Flutter ya incluye esto en el build, pero asegúrate de que esté presente.

### Los assets no se cargan

Verifica que el `base-href` esté correctamente configurado y que coincida con la estructura de tu repositorio.

### CORS o problemas con la API

Si tu backend está en `localhost:8080`, necesitarás:
1. Cambiar las URLs de la API a la URL de producción
2. Configurar CORS en tu backend para permitir requests desde GitHub Pages

## Variables de Entorno

Si necesitas usar variables de entorno diferentes para producción, puedes usar `--dart-define`:

```bash
flutter build web --release --base-href "/mamuka_erp/" \
  --dart-define=FLUTTER_WEB_USE_SKIA=false \
  --dart-define=API_URL=https://tu-api.com
```

Luego accede a estas variables en tu código con:
```dart
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
```


