// Önce internetten al (güncel sürüm gelsin), internet yoksa önbellekten aç
const ONBELLEK = 'v3';
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(
  caches.keys().then(k => Promise.all(k.filter(a => a !== ONBELLEK).map(a => caches.delete(a)))).then(() => self.clients.claim())));
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET' || new URL(e.request.url).origin !== location.origin) return;
  e.respondWith(fetch(e.request).then(r => {
    const kopya = r.clone();
    caches.open(ONBELLEK).then(c => c.put(e.request, kopya));
    return r;
  }).catch(() => caches.match(e.request)));
});
