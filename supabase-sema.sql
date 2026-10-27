-- Yerdeki Sesler + Sokak Kedisi ortak veritabanı (Supabase "app-factory" projesi)
-- Giriş yok: herkes anonim okur/ekler; kötüye kullanım şikâyet sayacıyla gizlenir.

create table if not exists public.sesler (
  id uuid primary key default gen_random_uuid(),
  lat double precision not null,
  lon double precision not null,
  baslik text not null check (char_length(baslik) between 1 and 80),
  dosya text not null,
  sure_sn int check (sure_sn between 1 and 60),
  sikayet int not null default 0,
  olusturma timestamptz not null default now()
);
create index if not exists sesler_konum on public.sesler (lat, lon);

create table if not exists public.kediler (
  id uuid primary key default gen_random_uuid(),
  ad text not null check (char_length(ad) between 1 and 40),
  not_ text check (char_length(not_) <= 300),
  asili boolean not null default false,
  kisir boolean not null default false,
  foto text not null,
  lat double precision not null,
  lon double precision not null,
  sikayet int not null default 0,
  olusturma timestamptz not null default now()
);
create index if not exists kediler_konum on public.kediler (lat, lon);

create table if not exists public.mama_kayitlari (
  id bigint generated always as identity primary key,
  kedi_id uuid not null references public.kediler(id) on delete cascade,
  zaman timestamptz not null default now()
);
create index if not exists mama_kedi on public.mama_kayitlari (kedi_id, zaman desc);

alter table public.sesler enable row level security;
alter table public.kediler enable row level security;
alter table public.mama_kayitlari enable row level security;

create policy "sesler oku" on public.sesler for select to anon using (sikayet < 3);
create policy "sesler ekle" on public.sesler for insert to anon with check (sikayet = 0);
create policy "kediler oku" on public.kediler for select to anon using (sikayet < 3);
create policy "kediler ekle" on public.kediler for insert to anon with check (sikayet = 0);
create policy "mama oku" on public.mama_kayitlari for select to anon using (true);
create policy "mama ekle" on public.mama_kayitlari for insert to anon with check (true);

-- Şikâyet ve aşı/kısır güncellemesi doğrudan update yerine fonksiyonla (sadece ilgili alan değişsin)
create or replace function public.sikayet_et(tablo text, kayit uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if tablo = 'sesler' then update sesler set sikayet = sikayet + 1 where id = kayit;
  elsif tablo = 'kediler' then update kediler set sikayet = sikayet + 1 where id = kayit;
  end if;
end $$;

create or replace function public.kedi_saglik(kayit uuid, yeni_asili boolean, yeni_kisir boolean) returns void
language sql security definer set search_path = public as $$
  update kediler set asili = yeni_asili, kisir = yeni_kisir where id = kayit;
$$;

revoke execute on function public.sikayet_et(text, uuid) from public;
revoke execute on function public.kedi_saglik(uuid, boolean, boolean) from public;
grant execute on function public.sikayet_et(text, uuid) to anon;
grant execute on function public.kedi_saglik(uuid, boolean, boolean) to anon;

-- Dosyalar: ses kayıtları ve kedi fotoğrafları (herkese açık okunur, anonim yüklenir, boyut sınırlı)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('sesler', 'sesler', true, 2000000, array['audio/webm','audio/ogg','audio/mp4','audio/mpeg']),
       ('kediler', 'kediler', true, 1500000, array['image/jpeg','image/webp'])
on conflict (id) do nothing;

create policy "ses yukle" on storage.objects for insert to anon with check (bucket_id = 'sesler');
create policy "kedi foto yukle" on storage.objects for insert to anon with check (bucket_id = 'kediler');
