# Haven: Arborele Sufletelor (Spectral Roots)

Un prototip de joc dezvoltat in **Godot 4.7+** inspirat din tema:
> *"Esti o fantoma care trebuie sa isi descopere arborele genealogic pentru a putea da ascend in haven. Dupa fiecare level apare cate o ramura noua (un nou stramos de descoperit). La fiecare stramos vei retrai o amintire grea din viata (puzzle/platformer)."*

---

## Povestea si Conceptul Jocului

Esti **Corin**, un spirit ratacitor prins intre lumi. Nu te poti inalta in **Haven** deoarece radacinile tale sunt legate de suferintele si regretele nevindecate ale stramosilor tai.

Pe masura ce explorezi **Arborele Genealogic al Sufletelor**, intri in amintirile grele ale stramosilor:
1. **Lucian - Ceasornicarul Regretelor (Tatal)**:
   - *Amintirea*: "Ceasornicul Inghetat". A vrut sa opreasca timpul, dar s-a izolat intr-o colivie de roti dintate.
   - *Mecanica*: Foloseste **Forma Eterica (`Shift`)** pentru a trece prin barierele mecanismului si revino in forma fizica pentru a reintoarce cele 2 arcuri ale ceasului.
2. **Elena - Pastratoarea Farului (Bunica)**:
   - *Amintirea*: "Furtuna din Suflet". A vegheat la malul marii asteptand o corabie pierduta.
   - *Mecanica*: Infrunta vantul marin, pluteste peste prapastie, coboara podul si reaprinde Focul Farului.
3. **Gabriel - Minerul din Adancuri (Strabunicul)**:
   - *Amintirea*: "Colivia cu Speranta". Prins intr-o surpare subterana, ghidat doar de cantecul unui canar de aur.
   - *Mecanica*: Manifesta-te fizic pentru a impinge vagonetul pe placuta hidraulica si elibereaza canarul de aur.
4. **Ascension in Haven (Finalul / Climax)**:
   - Dupa vindecarea tuturor ramurilor, Arborele se deschide in lumina calda.
   - Spiritele stramosilor te insotesc pe scara cereasca spre Haven!

---

## Controale

| Actiune | Taste | Descriere |
| :--- | :--- | :--- |
| **Miscare** | `A` / `D` sau `Sageti` | Deplasare lina cu inertie |
| **Salt & Plutire** | `Space` / `W` | Salt cu coyote time si jump buffering. Tine apasat in aer pentru plutire. |
| **Forma Spectrala** | `Shift` / `J` | Alterneaza intre **Forma Fizica** (poti apasa butoane/impinge obiecte) si **Forma Eterica** (treci prin bariere). |
| **Actiune / Interactiune** | `E` / `Enter` | Activeaza manete si mecanisme |
| **Meniu de Pauza** | `ESC` sau `P` | Deschide meniul de pauza curat (Continua, Restart, Arbore) |
| **Restart Rapid** | `R` | Reincepe nivelul curent |

---

## Directia Vizuala & Arhitectura Tehnica

- **Paleta Calda si Cozy**:
  - Tonalitati calde de nuc, miere, pergament, teracota si lavanda blanda (fara albastru electric rece).
  - Grafica curata, fara artefacte zgomotoase.
  - UI aerisit, minimalist, fara emoji-uri.
- **Meniu de Pauza Dedicat (`PauseMenu`)**:
  - Disponibil oricand la `ESC` sau `P`, cu optiuni de continuare, restart si intoarcere la Arbore.
- **Sintetizator Audio Procedural**:
  - Generare dinamica de tonuri PCM (`AudioStreamWAV`), fara dependente de fisiere externe.
