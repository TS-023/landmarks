# Europa in 3D — interactieve landmarkkaart

Eén zelfstandig HTML-bestand (`index.html`) met een interactieve kaart van Europa, iconische landmarks, 3D-weergaves (three.js + STL), winkelwagen/checkout-demo en een admin-paneel.

## Hosten op GitHub Pages
1. Maak een nieuwe GitHub-repository aan (of gebruik een bestaande).
2. Upload `index.html` naar de root van de repository (of naar een `docs/`-map).
3. Ga naar **Settings → Pages** in de repository.
4. Kies als bron de branch en map waar `index.html` staat (bijv. `main` / `root` of `main` / `docs`).
5. Na een paar minuten is de site live op `https://<gebruikersnaam>.github.io/<repository-naam>/`.

Geen build-stap nodig — het bestand laadt Leaflet, three.js en Google Fonts rechtstreeks vanaf een CDN.

## Belangrijk om te weten
- **Admin-wachtwoord**: staat als plaintext in de broncode (`ADMIN_PASSWORD` in `index.html`) — puur voor een prototype, niet geschikt als echte beveiliging.
- **Opslag**: geüploade STL-bestanden, foto's, prijzen en de winkelwagen worden lokaal opgeslagen in de browser (IndexedDB/localStorage) van elke bezoeker afzonderlijk — er is geen gedeelde database. Wat de beheerder uploadt op zijn eigen laptop, zien andere bezoekers dus niet automatisch.
- **Checkout**: is een demo-scherm zonder echte betaalverwerking.
- Voor een productieklare versie met een gedeelde database, echte betalingen en beveiligde login is een backend nodig — dat is met dit bestand alleen nog niet gedekt.
