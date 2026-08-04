# Setup: van lokale opslag naar gedeeld Supabase-account

De site is aangepast: STL-bestanden, foto's, en prijzen worden nu opgeslagen in
een gedeeld Supabase-project in plaats van lokaal in de browser. Volg deze stappen
één keer om het werkend te krijgen.

## 1. Supabase-project aanmaken
1. Ga naar https://supabase.com en maak een gratis account/project aan.
2. Kies een naam en wachtwoord voor de database (bewaar dit ergens veilig, je hebt het verder niet nodig).
3. Wacht tot het project klaar is (±2 min).

## 2. Database-tabel aanmaken
1. Ga in het Supabase-dashboard naar **SQL Editor** → **New query**.
2. Plak de inhoud van `supabase-setup.sql` (bijgevoegd) en klik **Run**.
   Dit maakt de tabel `products` aan met de juiste beveiligingsregels
   (iedereen mag lezen, alleen jij als ingelogde beheerder mag schrijven).

## 3. Storage buckets aanmaken (voor STL-bestanden en foto's)
1. Ga naar **Storage** in het linkermenu.
2. Maak twee buckets aan, allebei met **Public bucket** aangevinkt:
   - `landmarks-stl`
   - `landmarks-photos`
3. Ga voor elke bucket naar **Policies** en voeg toe:
   - Een policy die `SELECT` toestaat voor iedereen (`true`) — nodig zodat bezoekers de bestanden kunnen zien/downloaden.
   - Een policy die `INSERT`, `UPDATE` en `DELETE` toestaat alleen voor `authenticated` gebruikers — zodat alleen jij als ingelogde beheerder kunt uploaden/wijzigen.

   (Supabase biedt hiervoor kant-en-klare policy-templates aan: "Give users authenticated access" en "Give anon users read access" — die kun je direct gebruiken.)

## 4. Beheerdersaccount aanmaken
1. Ga naar **Authentication → Users → Add user**.
2. Vul jouw e-mailadres en een sterk wachtwoord in (vink "Auto Confirm User" aan).
3. Dit is nu het enige account dat kan inloggen op het beheerpaneel van de site.
   *Zorg dat "Enable email signups" bij Authentication → Settings uitstaat, zodat niemand anders zelf een account kan aanmaken.*

## 5. API-sleutels invullen in de site
1. Ga naar **Project Settings → API**.
2. Kopieer de **Project URL** en de **anon public key**.
3. Open `index.html` en vervang bovenaan de `<script>`-sectie:
   ```js
   const SUPABASE_URL = 'https://JOUW-PROJECT.supabase.co';
   const SUPABASE_ANON_KEY = 'JOUW-ANON-KEY';
   ```
   door jouw eigen waarden.

## 6. Uploaden naar GitHub Pages
Upload de aangepaste `index.html` zoals eerder — de rest van de hostingstappen blijft hetzelfde.

## Wat is er veranderd?
- STL-bestanden → gedeelde Supabase Storage bucket `landmarks-stl` (was: IndexedDB, alleen lokaal).
- Foto's → gedeelde Supabase Storage bucket `landmarks-photos` (was: base64 in localStorage, alleen lokaal).
- Prijzen → gedeelde tabel `products` in Supabase (was: localStorage, alleen lokaal).
- Beheerderslogin → echte Supabase Auth-login met e-mail + wachtwoord (was: plaintext wachtwoord in de broncode).
- Winkelwagen blijft bewust **lokaal per bezoeker** (in de browser) — dat hoort niet gedeeld te worden.

## Let op
- De `anon` key is bedoeld om publiek zichtbaar te zijn in client-side code — dat is normaal bij Supabase. De beveiliging zit in de RLS-policies (stap 2 en 3), niet in het geheimhouden van deze key.
- Gratis Supabase-tier heeft limieten (o.a. 1 GB storage, project pauzeert na 1 week inactiviteit). Voor een hobbyproject is dat ruim voldoende; voor productie kun je later upgraden.
