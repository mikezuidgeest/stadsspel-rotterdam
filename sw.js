// Stadsspel Rotterdam — service worker for offline resilience.
//
// Why this exists: pre-V41.6, hard-reloading Safari while temporarily offline produced
// a blank ERR_INTERNET_DISCONNECTED page. A player whose phone went between bars without
// coverage could lose access to the game until they found wifi.
//
// V53 (audit F8): the app boots from React / ReactDOM / Babel / Leaflet / markercluster
// (unpkg.com) + Supabase (cdn.jsdelivr.net) + fonts (Google). Pre-V53 the SW skipped ALL
// cross-origin requests, so if unpkg was slow/down at the venue the app could not boot at
// all — even for a phone that had opened it before. Now: those CDN library/font assets
// are served cache-first, so any phone that has loaded the game once is immune to a CDN
// outage on a later visit. (User data — *.supabase.co REST/realtime — is still never
// cached.) The libraries get cached as a side effect of the first successful page load,
// so no fragile install-time precache of redirecting versioned URLs is needed.
//
// Strategy:
//   - same-origin navigation  → network-first, fall back to cached index.html, then offline.html
//   - same-origin static      → cache-first with network revalidation
//   - CDN library/font assets → cache-first with background revalidation
//   - everything else x-origin (Supabase data) → pass through, never cached
//
// Scope: this file is at repo root, so it covers the deployed site on GitHub Pages.

const CACHE_NAME = 'stadsspel-v53';
const APP_SHELL_URLS = ['./', './index.html', './offline.html'];

// Static CDN hosts whose assets are safe to cache (libraries + fonts — never user data).
const CDN_HOSTS = ['unpkg.com', 'cdn.jsdelivr.net', 'fonts.googleapis.com', 'fonts.gstatic.com'];

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

// Fetch.
self.addEventListener('fetch', (event) => {
  const req = event.request;
  const url = new URL(req.url);

  // Skip non-GET (POST etc.)
  if (req.method !== 'GET') return;

  // CDN library / font assets (cross-origin but static + safe) → cache-first.
  // A cached hit is served immediately; a copy is refreshed in the background.
  // This is what makes the app boot even if unpkg/jsdelivr is down at the venue.
  if (url.origin !== self.location.origin && CDN_HOSTS.includes(url.hostname)) {
    event.respondWith(
      caches.match(req).then((cached) => {
        const network = fetch(req).then((res) => {
          // cache.put (unlike cache.add/addAll) tolerates redirected responses,
          // so unpkg's versioned-range URLs (e.g. react@18 → react@18.3.1) cache fine.
          if (res && res.status === 200) {
            const clone = res.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(req, clone));
          }
          return res;
        }).catch(() => cached || Response.error());
        // Cached copy wins for instant boot; otherwise wait on the network
        // (which, if it also fails with nothing cached, yields a clean network
        // error — identical to having no service worker at all).
        return cached || network;
      })
    );
    return;
  }

  // Skip all other cross-origin (Supabase REST / Realtime — user data, never cached).
  if (url.origin !== self.location.origin) return;

  // Navigation request (HTML page load) → network-first.
  if (req.mode === 'navigate' || (req.headers.get('accept') || '').includes('text/html')) {
    event.respondWith(
      fetch(req).then((res) => {
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

  // Other same-origin static (CSS/JS/images) — cache-first.
  event.respondWith(
    caches.match(req).then((cached) => cached || fetch(req).catch(() => caches.match('./offline.html')))
  );
});
