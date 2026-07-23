#!/bin/sh
# Install Flutter SDK
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /tmp/flutter 2>&1
export PATH="/tmp/flutter/bin:$PATH"
flutter precache 2>&1

# Build with env vars from Vercel
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" 2>&1
