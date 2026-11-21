
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', false)
on conflict (id) do nothing;

drop policy if exists "Usuarios autenticados pueden leer fotos de productos" on storage.objects;
drop policy if exists "Los usuarios suben sus propias fotos de productos" on storage.objects;
drop policy if exists "Los usuarios borran sus propias fotos de productos" on storage.objects;

create policy "Usuarios autenticados pueden leer fotos de productos"
on storage.objects for select
to authenticated
using (bucket_id = 'product-images');

create policy "Los usuarios suben sus propias fotos de productos"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'product-images'
  and (storage.foldername(name))[1] = 'products'
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "Los usuarios borran sus propias fotos de productos"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'product-images'
  and (storage.foldername(name))[1] = 'products'
  and (storage.foldername(name))[2] = auth.uid()::text
);

