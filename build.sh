#!/bin/sh
# Install Flutter SDK (web-only to save time)
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /tmp/flutter 2>&1
export PATH="/tmp/flutter/bin:$PATH"
flutter config --no-analytics 2>&1

# Build web with env vars from Vercel
# Trim whitespace from env vars
URL=$(echo "$SUPABASE_URL" | tr -d '[:space:]')
KEY=$(echo "$SUPABASE_ANON_KEY" | tr -d '[:space:]')

flutter build web --release \
  --dart-define=SUPABASE_URL="$URL" \
  --dart-define=SUPABASE_ANON_KEY="$KEY" 2>&1
