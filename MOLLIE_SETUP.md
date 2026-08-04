# Setup: echte betalingen via Mollie (iDEAL)

De "Bestelling plaatsen"-knop deed voorheen niets echts — nu start hij een echte
Mollie-betaling. Dit vraagt om een paar eenmalige stappen: een Mollie-account,
een nieuwe database-tabel, en het "deployen" van drie kleine server-functies
(Supabase Edge Functions) die je Mollie-sleutel geheim houden.

**Belangrijk om te weten:** je Mollie-sleutel mag NOOIT in `index.html` staan —
die is voor iedereen zichtbaar in de broncode van je site. Daarom draaien de
betaal-stappen op Supabase's servers (Edge Functions), niet in de browser.

## 1. Mollie-account aanmaken
1. Ga naar https://www.mollie.com/nl en maak een (gratis) account aan.
2. Doorloop de verificatie voor je bedrijf/eenmanszaak (nodig om echt geld te ontvangen —
   dit kan een paar dagen duren; je kunt ondertussen al met de **testmodus** werken).
3. Ga naar **Ontwikkelaars → API-sleutels**. Kopieer eerst de **testsleutel**
   (begint met `test_...`) om alles te testen zonder echt geld. Als alles werkt,
   gebruik je later de **livesleutel** (`live_...`).

## 2. Database-tabel voor bestellingen
1. Supabase-dashboard → **SQL Editor → New query**.
2. Plak de inhoud van `orders-setup.sql` (bijgevoegd) → **Run**.
   (Vereist dat je eerder `supabase-setup.sql` al hebt uitgevoerd.)

## 3. Supabase CLI installeren
Dit heb je nodig om de Edge Functions te uploaden. Open een terminal (op Windows:
PowerShell) en installeer de CLI. Kies één van deze routes:

```bash
# Via npm (als je Node.js hebt geïnstalleerd)
npm install -g supabase

# Of via Scoop (Windows)
scoop install supabase

# Of via Homebrew (Mac)
brew install supabase/tap/supabase
```

Controleer daarna:
```bash
supabase --version
```

## 4. Inloggen en project koppelen
```bash
supabase login
```
Dit opent je browser om in te loggen. Ga daarna naar de map met je website-bestanden
(waar `index.html`, `orders-setup.sql`, en de map `supabase/` in staan) en voer uit:

```bash
supabase link --project-ref kphwbtmvzhcvufdweoez
```

## 5. Geheime sleutels instellen
Deze blijven op de server en zijn nooit zichtbaar in je website:

```bash
supabase secrets set MOLLIE_API_KEY=test_jouwsleutelhier
supabase secrets set SITE_URL=https://ts-023.github.io/JOUW-REPO-NAAM/
```
*(Vervang `SITE_URL` door de echte URL van je GitHub Pages-site — dit is waar
Mollie de klant na betalen naar terugstuurt. `SUPABASE_URL` en
`SUPABASE_SERVICE_ROLE_KEY` hoef je niet zelf in te stellen, die geeft Supabase
automatisch mee aan Edge Functions.)*

## 6. De drie functies deployen
```bash
supabase functions deploy create-payment --no-verify-jwt
supabase functions deploy mollie-webhook --no-verify-jwt
supabase functions deploy get-order-status --no-verify-jwt
```
*(`--no-verify-jwt` is nodig omdat je nieuwe publishable-key geen "gewone" JWT is
— zonder deze vlag weigert Supabase de aanroepen vanaf je website.)*

## 7. Testen
1. Upload de aangepaste `index.html` naar GitHub Pages (zie hoofdstap hieronder).
2. Zet een STL of kunstobject in je winkelwagen en reken af.
3. Mollie's testmodus toont een testbetaalscherm — kies "Betaling gelukt" om het
   volledige pad te testen (bevestiging + downloadlink).
4. Check in Supabase → **Table Editor → orders** of de bestelling er staat met
   status `paid`.

## 8. Live gaan
Zodra je Mollie-verificatie rond is en alles goed test:
```bash
supabase secrets set MOLLIE_API_KEY=live_jouwsleutelhier
```
Verder hoef je niets aan te passen — de functies gebruiken automatisch de nieuwe sleutel.

## Waar zie je je bestellingen?
Supabase-dashboard → **Table Editor → orders**. Daar staan naam, e-mail, adres
(bij kunstobjecten) en de bestelde items — dit is niet zichtbaar voor bezoekers
van de site (de tabel heeft geen leestoegang voor het publiek, alleen de
Edge Functions met de geheime service-sleutel mogen erbij).

## Een belangrijk aandachtspunt
De 3D-preview in het paneel (waar bezoekers het model kunnen ronddraaien) laadt
op dit moment het **volledige** STL-bestand, ook voor bezoekers die niet betaald
hebben — dat bestand staat namelijk in dezelfde publieke Supabase-bucket. Een
technisch onderlegde bezoeker zou dat bestand dus via de browser-devtools kunnen
onderscheppen zonder te betalen. Voor de meeste bezoekers is dit geen probleem,
maar het is geen waterdichte beveiliging tegen misbruik. Als je dit wilt dichttimmeren,
kan ik een aparte lage-kwaliteit previewversie laten genereren die los staat van het
verkoopbare bestand — laat het weten als je dat wilt.
