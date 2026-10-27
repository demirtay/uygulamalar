// Yerdeki Sesler ve Sokak Kedisi'nin ortak veritabanı bağlantısı.
// Supabase "app-factory" projesi açılınca url ve key (publishable) buraya yazılır.
window.SUPA = { url: 'https://jqseccozepunvmfwktjf.supabase.co', key: 'sb_publishable_BzTedmJkD4cp1bM_3txyIg_vd02Kw-p' };

window.supaHazir = () => !!(window.SUPA.url && window.SUPA.key);

// İki nokta arası metre
window.mesafeM = (a, b) => {
  const R = 6371000, r = x => x * Math.PI / 180;
  const d1 = r(b.lat - a.lat), d2 = r(b.lon - a.lon);
  const h = Math.sin(d1 / 2) ** 2 + Math.cos(r(a.lat)) * Math.cos(r(b.lat)) * Math.sin(d2 / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
};

// Konumun çevresindeki kutu (yaklaşık), veritabanında hızlı arama için
window.kutu = (k, metre) => {
  const dLat = metre / 111320, dLon = metre / (111320 * Math.cos(k.lat * Math.PI / 180));
  return { minLat: k.lat - dLat, maxLat: k.lat + dLat, minLon: k.lon - dLon, maxLon: k.lon + dLon };
};

window.konumAl = () => new Promise((ok, hata) =>
  navigator.geolocation.getCurrentPosition(p => ok({ lat: p.coords.latitude, lon: p.coords.longitude }), hata,
    { enableHighAccuracy: true, timeout: 15000, maximumAge: 20000 }));
