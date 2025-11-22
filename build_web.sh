#!/bin/bash

# Script para construir la app Flutter web para GitHub Pages
# Uso: ./build_web.sh

echo "🔨 Construyendo Flutter Web para GitHub Pages..."

# Limpiar builds anteriores
flutter clean

# Obtener dependencias
flutter pub get

# Construir para web
# Si tu repo es username.github.io, usa --base-href "/"
# Si tu repo es username.github.io/repo-name, usa --base-href "/repo-name/"
flutter build web --release --base-href "/mamuka_erp/" --dart-define=FLUTTER_WEB_USE_SKIA=false

# Crear archivo .nojekyll para evitar que GitHub Pages procese los archivos con Jekyll
touch build/web/.nojekyll

echo "✅ Build completado! Los archivos están en build/web/"
echo "📦 Para desplegar manualmente, copia el contenido de build/web/ a la rama gh-pages"


