# 🚀 ThermalVault-3DPrint: Bauraum-Simulation für Hochleistungs-FDM

Dieses Projekt ist aus einer ganz praktischen Frage entstanden: **Wie isoliere ich einen 3D-Drucker-Bauraum für 150°C, wenn ich kaum Platz habe?**

Anstatt mich auf mein Bauchgefühl zu verlassen, habe ich dieses interaktive Tool in **Julia** und **Pluto.jl** entwickelt. Es vergleicht zwei grundlegende Isolations-Konzepte: Klassische Dämmung vs. reflektierende Hitzeschilde.

Live Demo: https://multischaum.github.io/ThermalVault-3DPrint/W%C3%A4rme%C3%BCbertragung%20Bauraum%203D%20drucker.html

---

## 🛠️ Der Hintergrund (Vom Tüftler für Tüftler)
Ich bin kein Profi-Softwareentwickler, sondern ein begeisterter 3D-Druck-Enthusiast. Ich wollte wissen, ob das Polieren von Edelstahlblechen ("Thermoskannen-Prinzip") wirklich den entscheidenden Vorteil gegenüber Steinwolle bringt.

Dieses Notebook nutzt ein **7x7-Matrix-Gleichungssystem** (thermische Leitwertmatrix), um die Temperaturen an jeder Schichtgrenze zu berechnen. Da Wärmestrahlung nichtlinear ist, rechnet das Tool iterativ, bis die Physik "stimmt".

### Was simuliert wird:
* **Hitzeschild-Aufbau:** Mehrwandiges Design mit Fokus auf die Reduzierung von Wärmestrahlung durch Politur (Emissionsgrad).
* **Klassische Dämmung:** Vollflächige Füllung mit Materialien wie Steinwolle, Aerogel oder Keramikfaser.
* **Normierung:** Alle Werte beziehen sich auf **1 m² Wandfläche**, damit du sie leicht auf die Größe deines Druckers hochrechnen kannst.

---

## 📊 Visualisierung
Das Notebook generiert ein dynamisches Temperaturprofil. Du siehst exakt, in welcher Schicht die Temperatur "stürzt" und ob deine Außenwand berührungssicher (ideal < 50°C) bleibt.



---

## 🚀 Wie man das Notebook startet
Um das interaktive Tool zu nutzen, benötigst du **Julia**.

1. **Julia installieren:** Lade sie von [julialang.org](https://julialang.org/downloads/) herunter.
2. **Pluto starten:** Öffne das Julia-Terminal (REPL) und gib folgendes ein:
   ```julia
   import Pkg; Pkg.add("Pluto")
   import Pluto; Pluto.run()
