// Çevrimdışı açılabilsin diye dosyaları önbelleğe al
const ONBELLEK = 'hesap-v1';
const DOSYALAR = ['./', 'index.html', 'manifest.json', 'icon.svg'];
self.addEventListener('install', e => e.waitUntil(caches.open(ONBELLEK).then(c => c.addAll(DOSYALAR))));
self.addEventListener('fetch', e => e.respondWith(caches.match(e.request).then(r => r || fetch(e.request))));
