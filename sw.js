// Stadsspel Rotterdam — service worker for offline resilience (V41.6 F-2 fix).
//
// Why this exists: pre-V41.6, hard-reloading Safari while temporarily offline produced
// a blank ERR_INTERNET_DISCONNECTED page. A player whose phone went between bars without
// coverage could lose access to the game until they found wifi.
//
// Strategy: network-first with cache fallback. On every successful fetch of index.html,
// stash a copy in cache. When offline + no cache → serve a friendly offline page so
// the user understands what happened.
//
// Scope: this file is at repo root, so it covers /stadsspel-rotterdam/ when deployed
// to GitHub Pages. iOS Safari has supported service workers since 11.3 (2018) — all
// our players' phones are well above that minimum.

const CACHE_NAME = 'stadsspel-v41.6';
const APP_SHELL_URLS = ['./', './index.html', './offline.html'];

// Install: pre-cache the shell (best-effort — if any of these fail we don't block).
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) =>
      cache.addAll(APP_SHELL_URLS).catch(() => {/* offline at install → tolerate */})
    ).then(() => self.skipWaiting())
  );
});

// Activate: nuke older caches so a deploy can't leave stale shells around.
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Fetch:
//   1. Same-origin navigation → network-first, fall back to cached index.html, then offline.html
//   2. Same-origin static asset → cache-first with network revalidation
//   3. Supabase REST / Realtime / external CDNs → pass through (never cache user data)
self.addEventListener('fetch', (event) => {
  const req = event.request;
  const url = new URL(req.url);

  // Skip non-GET (POST etc.)
  if (req.method !== 'GET') return;

  // Skip cross-origin (Supabase, esm.sh React CDN, etc.) — let the browser handle them
  if (url.origin !== self.location.origin) return;

  // Navigation request (HTML page load)
  if (req.mode === 'navigate' || (req.headers.get('accept') || '').includes('text/html')) {
    event.respondWith(
      fetch(req).then((res) => {
        // Successful fetch → stash a clone of index.html for future offline visits
        if (res && res.status === 200) {
          const clone = res.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put('./index.html', clone));
        }
        return res;
      }).catch(() =>
        caches.match('./index.html').then((cached) =>
          cached || caches.match('./offline.html')
        )
      )
    );
    return;
  }

  // Other same-origin static (CSS/JS/images) — cache-first
  event.respondWith(
    caches.match(req).then((cached) => cached || fetch(req).catch(() => caches.match('./offline.html')))
  );
});
