// Forja Gym: permite abrir la app sin cobertura (en el gimnasio). Siempre intenta la versión nueva primero.
const CACHE = 'forja-v5';
const BASE = ['./', './index.html', './config.js', './manifest.json', './icon-192.png', './apple-touch-icon.png',
  './supabase.js?v=2.45.4', './591.supabase.js'];
self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => Promise.all(BASE.map(u => c.add(u).catch(() => null)))).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const req = e.request, url = new URL(req.url);
  if (req.method !== 'GET' || url.hostname.endsWith('supabase.co')) return;   // los datos van siempre a la nube
  const propio = url.origin === location.origin, cdn = url.hostname === 'cdn.jsdelivr.net' || url.hostname.endsWith('gstatic.com') || url.hostname === 'fonts.googleapis.com';
  if (!propio && !cdn) return;
  e.respondWith(fetch(req).then(r => {
    if (r && (r.ok || r.type === 'opaque')) { const copia = r.clone(); caches.open(CACHE).then(c => c.put(req, copia)); }
    return r;
  }).catch(() => caches.match(req).then(r => r || (req.mode === 'navigate' ? caches.match('./index.html') : undefined))));
});
