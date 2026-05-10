#!/usr/bin/env bash
# =============================================================================
# Arora — First-Run Setup Script
# Run this ONCE from the project root to install Flutter and bootstrap the app.
# =============================================================================
set -e

ARORA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 Project root: $ARORA_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Install Flutter (Arch Linux / AUR)
# ─────────────────────────────────────────────────────────────────────────────
if ! command -v flutter &>/dev/null; then
  echo ""
  echo "⬇  Flutter not found. Installing via AUR..."
  echo "   (Requires yay or paru installed)"

  if command -v yay &>/dev/null; then
    yay -S --noconfirm flutter
  elif command -v paru &>/dev/null; then
    paru -S --noconfirm flutter
  else
    echo ""
    echo "❌  Neither yay nor paru found."
    echo "    Install Flutter manually: https://docs.flutter.dev/get-started/install/linux"
    exit 1
  fi
else
  echo "✅  Flutter already installed: $(flutter --version | head -1)"
fi

# Source updated PATH (AUR installs to /usr/bin/flutter)
export PATH="$PATH:/usr/bin"

# ─────────────────────────────────────────────────────────────────────────────
# Step 2: Enable required platforms
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "🔧  Enabling Flutter platforms..."
flutter config --enable-linux-desktop
flutter config --enable-web
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop

# ─────────────────────────────────────────────────────────────────────────────
# Step 3: flutter create — generates platform folders in existing project
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "🚀  Initialising Flutter platform directories..."
cd "$ARORA_DIR"

# --org sets the bundle identifier (com.arora)
# Running in an existing project only generates missing platform files
# and does NOT overwrite lib/, pubspec.yaml, or any existing source files.
flutter create \
  --org com.arora \
  --project-name arora \
  --platforms android,ios,linux,macos,windows,web \
  .

# ─────────────────────────────────────────────────────────────────────────────
# Step 4: Install Dart dependencies
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "📦  Installing dependencies..."
flutter pub get

# ─────────────────────────────────────────────────────────────────────────────
# Step 5: Code generation (freezed, isar, riverpod)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "⚙   Running build_runner (generates .freezed.dart, .g.dart)..."
flutter pub run build_runner build --delete-conflicting-outputs

# ─────────────────────────────────────────────────────────────────────────────
# Step 6: Verify
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "🔍  Running flutter analyze..."
flutter analyze || true

echo ""
echo "✅  Setup complete!"
echo ""
echo "Next steps:"
echo "  flutter run -d linux       # Run on Linux desktop"
echo "  flutter run -d chrome      # Run in browser"
echo "  flutter run                # Run on connected Android/iOS device"
echo "  flutter test               # Run unit tests"
