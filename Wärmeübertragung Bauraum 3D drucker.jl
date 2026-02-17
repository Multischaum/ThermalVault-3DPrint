### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ aba6d2aa-2eca-4daf-a3fe-f8a10b194f37
using PlutoUI


# ╔═╡ 12a93e1f-050b-4b72-8cd8-d159917a62f1
using Plots

# ╔═╡ 8c662252-ccac-443e-a3bf-f8cd8d3c25eb
md"""
# 🚀 Mission: Bauraum-Isolierung (150°C High-Performance Edition)

Willkommen im Labor! Wir konstruieren hier das thermische Rückgrat für einen High-Performance-FDM-Drucker. Unser Ziel: Den Bauraum stabil auf **150°C** halten, während die Außenhülle berührungssicher bleibt. 

In diesem Notebook lassen wir zwei Welten der Thermodynamik im direkten Vergleich antreten: 
Was ist schlauer? Den knappen Bauraum mit klassischer Dämmwolle füllen oder die Physik der Photonen nutzen und die Hitze mittels **polierter Hitzeschilde** einfach dorthin zurückspiegeln, wo sie hingehört?

### 🛠️ Was unter der Haube passiert
Hinter den Schiebereglern steckt echte Numerik. Da Wärmestrahlung nichtlinear mit der Temperatur ($T^4$) steigt, berechnen wir die Werte nicht einfach mit dem Taschenrechner, sondern lösen ein **7x7-Matrix-Gleichungssystem** in einer iterativen Schleife. So nähern wir uns Schritt für Schritt der physikalischen Realität an.

### 📐 Skalierbarkeit & Watt-Leistung
**Wichtiger Hinweis:** Alle berechneten Wärmeströme ($\dot{Q}$) beziehen sich im Modell auf eine Normfläche von **$1 \, m^2$**. 
Das macht es für dich extrem einfach: Wenn dein geplanter Drucker eine Gesamtoberfläche von z. B. $1,2 \, m^2$ hat, multiplizierst du den Ergebniswert einfach mit 1,2 und weißt sofort, wie viel Watt deine Heizung mindestens leisten muss, um die Verluste auszugleichen.

**Spielanleitung:**
1.  **Konfiguriere** deinen Aufbau in der Bauteil-Sektion (Materialien, Dicken, Politur).
2.  **Beobachte** im Live-Graphen, wie die Temperaturen in den verschiedenen Schichten „stürzen“.
3.  **Vergleiche** die Watt-Zahl: Wo sparst du am Ende bares Geld bei den Stromkosten?

*Hinweis: Ein hoher Temperaturabfall im Luftspalt ist dein Ziel – eine hohe Innenwandtemperatur bei guter Dämmung hingegen beweist nur, dass die Wärme im Ofen gefangen ist. Viel Erfolg beim Optimieren!*
"""

# ╔═╡ 683f75d3-e3c7-47d1-a263-7e0e151455a8
md"""
### Bauteil-Konfiguration

Bitte wähle die passenden Parameter für das aktuelle Modell aus.

**0. Umgebungsbedingungen**
Hier definierst du die Temperaturen des Heißluftstroms und der Umgebung.

| Eigenschaft | Konfiguration / Auswahl |
| :--- | :--- |
| **Temperatur Innen (Heißluft)** | $(@bind T_innen NumberField(20.0:10.0:1000.0, default=150.0)) °C |
| **Temperatur Außen (Raumluft)** | $(@bind T_aussen NumberField(-20.0:1.0:100.0, default=20.0)) °C |

**1. Innere Schicht (Heißluft-Seite)**
Hier definierst du die erste Wand und ihre Beschichtung.

| Eigenschaft | Konfiguration / Auswahl |
| :--- | :--- |
| **Beschichtung** | $(@bind beschichtung Select(["Keine", "Kapton HN", "Cerakote"], default="Keine")) |
| **Beschichtungsdicke** | $(@bind dickeBeschichtung NumberField(0.01:0.01:2.0, default=0.1)) mm |
| **Grundmaterial** | $(@bind Grundmaterial Select(["Aluminium EN AW-7075","Edelstahl V2", "Stahl" ],default="Edelstahl V2"))  |
| **Materialstärke 1** | $(@bind dickeGrundmaterial NumberField(0.5:0.5:5.0, default=2.0)) mm |

**2. Erster Luftspalt & Zwischenwand**
Die erste Isolationsschicht. Hier stellst du die Oberflächenbeschaffenheit der beiden Wände ein, die sich im ersten Spalt "anschauen".

| Eigenschaft | Konfiguration / Auswahl |
| :--- | :--- |
| **Oberfläche Wand 1 (Außen)** | $(@bind oberflaeche_w1_aussen Select(["Matt", "Poliert"], default="Matt")) |
| **Luftspalt 1 Dicke** | $(@bind d_gap1_mm NumberField(1.0:1.0:20.0, default=8.0)) mm |
| **Oberfläche Zwischenwand (Innen)** | $(@bind oberflaeche_zw_innen Select(["Matt", "Poliert"], default="Matt")) |
| **Material Zwischenwand** | $(@bind Zwischenmaterial Select(["Aluminium EN AW-7075","Edelstahl V2", "Stahl" ],default="Edelstahl V2")) |
| **Materialstärke 2** | $(@bind dickeZwischenwand NumberField(0.5:0.5:5.0, default=1.0)) mm |

**3. Zweiter Luftspalt & Außenwand (Kaltluft-Seite)**
Der äußere Abschluss des Gehäuses. Auch hier kannst du die Strahlung separat blockieren.

| Eigenschaft | Konfiguration / Auswahl |
| :--- | :--- |
| **Oberfläche Zwischenwand (Außen)** | $(@bind oberflaeche_zw_aussen Select(["Matt", "Poliert"], default="Matt")) |
| **Luftspalt 2 Dicke** | $(@bind d_gap2_mm NumberField(1.0:1.0:20.0, default=8.0)) mm |
| **Oberfläche Außenwand (Innen)** | $(@bind oberflaeche_aw_innen Select(["Matt", "Poliert"], default="Matt")) |
| **Material Außenwand** | $(@bind Aussenmaterial Select(["Aluminium EN AW-7075","Edelstahl V2", "Stahl" ],default="Edelstahl V2")) |
| **Materialstärke 3** | $(@bind dickeAussenwand NumberField(0.5:0.5:5.0, default=2.0)) mm |
"""

# ╔═╡ 0df3c255-6507-4e08-94bc-35663d122752
md"""
### 🧱 Alternative: Klassische Dämmung (Gefüllt)
Was passiert, wenn wir die Luftspalte stattdessen komplett mit Dämmmaterial ausstopfen? (Die Dicken der Wände und Spalte werden 1:1 aus der Konfiguration oben übernommen).

| Eigenschaft | Konfiguration / Auswahl |
| :--- | :--- |
| **Füllmaterial Spalte** | $(@bind daemmstoff Select(["Steinwolle", "Glaswolle", "Keramikfaser", "Aerogel"], default="Steinwolle")) |
"""

# ╔═╡ 0dd06838-d1ee-46f5-ad1e-fd1f900280f6
ergebnisse = begin
    # --- 1. Hilfsfunktionen ---
    function get_lambda(mat_name)
        if mat_name == "Aluminium EN AW-7075" return 130.0
        elseif mat_name == "Edelstahl V2" return 15.0
        elseif mat_name == "Stahl" return 50.0
        else return 15.0 end
    end

    function get_coat_lambda(coat_name)
        if coat_name == "Kapton HN" return 0.12
        elseif coat_name == "Cerakote" return 2.0
        else return 1000.0 end
    end

    # Neu: Hilfsfunktion für den Emissionsgrad
    function get_epsilon(oberflaeche)
        return (oberflaeche == "Poliert") ? 0.1 : 0.6
    end

    # --- 2. Strahlungsparameter berechnen ---
    # Emissionsgrade der 4 Flächen auslesen
    eps_w1_a = get_epsilon(oberflaeche_w1_aussen)
    eps_zw_i = get_epsilon(oberflaeche_zw_innen)
    eps_zw_a = get_epsilon(oberflaeche_zw_aussen)
    eps_aw_i = get_epsilon(oberflaeche_aw_innen)

    # Resultierende Emissionsgrade für beide Spalte berechnen
    eps_res_gap1 = 1.0 / ( (1.0/eps_w1_a) + (1.0/eps_zw_i) - 1.0 )
    eps_res_gap2 = 1.0 / ( (1.0/eps_zw_a) + (1.0/eps_aw_i) - 1.0 )
    
    sigma_SB = 5.67e-8 # Stefan-Boltzmann Konstante

    # --- 3. Variablen wandeln ---
    λ_coat = get_coat_lambda(beschichtung)
    d_coat_m = (beschichtung == "Keine") ? 1e-6 : (dickeBeschichtung / 1000.0)
    
    λ_wand1 = get_lambda(Grundmaterial)
    d_wand1_m = dickeGrundmaterial / 1000.0
    d_gap1_m = d_gap1_mm / 1000.0
    
    λ_wand2 = get_lambda(Zwischenmaterial)
    d_wand2_m = dickeZwischenwand / 1000.0
    d_gap2_m = d_gap2_mm / 1000.0
    
    λ_wand3 = get_lambda(Aussenmaterial)
    d_wand3_m = dickeAussenwand / 1000.0

    # --- 4. Leitwerte (G) Festkörper ---
    A_fläche = 1.0 # m²
    
    α_in = 10.0
    α_out = 5.0
    α_konv_gap = 3.0 # Fester Anteil für Konvektion (ruhende Luft)

    G_in   = α_in * A_fläche
    G_coat = (λ_coat / d_coat_m) * A_fläche
    G_w1   = (λ_wand1 / d_wand1_m) * A_fläche
    G_w2   = (λ_wand2 / d_wand2_m) * A_fläche
    G_w3   = (λ_wand3 / d_wand3_m) * A_fläche
    G_out  = α_out * A_fläche

    # --- 5. Iteratives Lösen der Matrix ---
    T_knoten = fill(T_aussen, 7) 
    
    K = zeros(7, 7)
    Q = zeros(7)
    Q[1] = G_in * T_innen
    Q[7] = G_out * T_aussen

    for iter in 1:10
        # Temperaturen der Spaltwände in Kelvin
        T2_K = T_knoten[2] + 273.15 # Wand 1 Außen
        T3_K = T_knoten[3] + 273.15 # Zwischenwand Innen
        T4_K = T_knoten[4] + 273.15 # Zwischenwand Außen
        T5_K = T_knoten[5] + 273.15 # Außenwand Innen

        # Strahlungskoeffizient dynamisch berechnen (mit den separaten eps_res!)
        α_str_gap1 = eps_res_gap1 * sigma_SB * (T2_K^2 + T3_K^2) * (T2_K + T3_K)
        α_str_gap2 = eps_res_gap2 * sigma_SB * (T4_K^2 + T5_K^2) * (T4_K + T5_K)

        G_g1 = (α_konv_gap + α_str_gap1) * A_fläche
        G_g2 = (α_konv_gap + α_str_gap2) * A_fläche

        K[1,1] = G_in + G_coat;   K[1,2] = -G_coat
        K[2,1] = -G_coat;         K[2,2] = G_coat + G_w1;  K[2,3] = -G_w1
        K[3,2] = -G_w1;           K[3,3] = G_w1 + G_g1;    K[3,4] = -G_g1
        K[4,3] = -G_g1;           K[4,4] = G_g1 + G_w2;    K[4,5] = -G_w2
        K[5,4] = -G_w2;           K[5,5] = G_w2 + G_g2;    K[5,6] = -G_g2
        K[6,5] = -G_g2;           K[6,6] = G_g2 + G_w3;    K[6,7] = -G_w3
        K[7,6] = -G_w3;           K[7,7] = G_w3 + G_out

        # In-Place Zuweisung (.=), damit die Variable T_knoten aktualisiert wird
        T_knoten .= K \ Q
    end
    
    
      (
        T_Beschichtung_Innen = round(T_knoten[1], digits=2),
        T_Wand1_Innen = round(T_knoten[2], digits=2),
        T_Wand1_Aussen = round(T_knoten[3], digits=2),
        T_Zwischenwand_Innen = round(T_knoten[4], digits=2),
        T_Zwischenwand_Aussen = round(T_knoten[5], digits=2),
        T_Aussenwand_Innen = round(T_knoten[6], digits=2),
        T_Aussen_Oberflaeche = round(T_knoten[7], digits=2),
		Waermeverlust_W = round(G_in * (T_innen - T_knoten[1]), digits=1)
    )
    # Wärmestrom berechnen: Q_punkt = G_in * (T_in - T_oberfläche_innen)
    #Q_punkt = G_in * (T_innen - T_knoten[1])
    # T_knoten[7] ist hier die Außenoberfläche
end

# ╔═╡ 4e392c5d-b609-4b5c-a57d-7e601bbf459c
ergebnisse_gefuellt = let
    # --- 1. Wärmeleitfähigkeit des Dämmstoffs ---
    function get_daemm_lambda(mat_name)
        if mat_name == "Steinwolle" return 0.040
        elseif mat_name == "Glaswolle" return 0.035
        elseif mat_name == "Keramikfaser" return 0.060
        elseif mat_name == "Aerogel" return 0.015
        else return 0.040 end
    end

    λ_daemm = get_daemm_lambda(daemmstoff)
    
    # --- 2. Bekannte Parameter laden ---
    A_fläche = 1.0 
    α_in = 10.0; α_out = 5.0
    
    function get_lambda_local(mat_name)
        if mat_name == "Aluminium EN AW-7075" return 130.0
        elseif mat_name == "Edelstahl V2" return 15.0
        elseif mat_name == "Stahl" return 50.0
        else return 15.0 end
    end

    function get_coat_lambda_local(coat_name)
        if coat_name == "Kapton HN" return 0.12
        elseif coat_name == "Cerakote" return 2.0
        else return 1000.0 end
    end

    λ_coat = get_coat_lambda_local(beschichtung)
    d_coat_m = (beschichtung == "Keine") ? 1e-6 : (dickeBeschichtung / 1000.0)
    λ_wand1 = get_lambda_local(Grundmaterial); d_wand1_m = dickeGrundmaterial / 1000.0
    λ_wand3 = get_lambda_local(Aussenmaterial); d_wand3_m = dickeAussenwand / 1000.0
    
    # NEU: Der gesamte Zwischenraum wird addiert!
    d_daemm_ges_m = (d_gap1_mm + dickeZwischenwand + d_gap2_mm) / 1000.0

    # --- 3. Leitwerte (G) berechnen ---
    G_in   = α_in * A_fläche
    G_coat = (λ_coat / d_coat_m) * A_fläche
    G_w1   = (λ_wand1 / d_wand1_m) * A_fläche
    G_daemm = (λ_daemm / d_daemm_ges_m) * A_fläche
    G_w3   = (λ_wand3 / d_wand3_m) * A_fläche
    G_out  = α_out * A_fläche

    # --- 4. Matrix K aufbauen (jetzt 5x5) ---
    K = zeros(5, 5)
    Q = zeros(5)
    Q[1] = G_in * T_innen
    Q[5] = G_out * T_aussen

    K[1,1] = G_in + G_coat;   K[1,2] = -G_coat
    K[2,1] = -G_coat;         K[2,2] = G_coat + G_w1;  K[2,3] = -G_w1
    K[3,2] = -G_w1;           K[3,3] = G_w1 + G_daemm; K[3,4] = -G_daemm
    K[4,3] = -G_daemm;        K[4,4] = G_daemm + G_w3; K[4,5] = -G_w3
    K[5,4] = -G_w3;           K[5,5] = G_w3 + G_out

    T_knoten_daemm = K \ Q

    (
        T_Beschichtung_Innen = round(T_knoten_daemm[1], digits=2),
        T_Wand1_Innen = round(T_knoten_daemm[2], digits=2),
        T_Wand1_Aussen = round(T_knoten_daemm[3], digits=2),
        T_Aussenwand_Innen = round(T_knoten_daemm[4], digits=2),
        T_Aussen_Oberflaeche = round(T_knoten_daemm[5], digits=2),
		Waermeverlust_W = round(G_in * (T_innen - T_knoten_daemm[1]), digits=1)
    )
	
    #Q_punkt_gefuellt = G_in * (T_innen - T_knoten_daemm[1])
    # T_knoten_daemm[5] ist hier die Außenoberfläche
end

# ╔═╡ 51029a7d-0136-4de8-ade5-d299e1dcc4ce
md"""
### 📊 Ergebnisse der Wärmeberechnung: Der Vergleich

Hier siehst du die Temperaturen an den wichtigsten Schichtgrenzen sowie den resultierenden Wärmeverlust im direkten Vergleich.

| Schichtgrenze / Ort | Hitzeschild (Dein Aufbau) | Gefüllt (Vergleich) |
| :--- | :--- | :--- |
| 🌡️ **Heißluft (Innen)** | **$(T_innen) °C** | **$(T_innen) °C** |
| Innenwand (Oberfläche) | $(ergebnisse.T_Beschichtung_Innen) °C | $(ergebnisse_gefuellt.T_Beschichtung_Innen) °C |
| Wand 1 (Innen) | $(ergebnisse.T_Wand1_Innen) °C | $(ergebnisse_gefuellt.T_Wand1_Innen) °C |
| Wand 1 (Außenseite) | $(ergebnisse.T_Wand1_Aussen) °C | $(ergebnisse_gefuellt.T_Wand1_Aussen) °C |
| Zwischenwand (Innen) | $(ergebnisse.T_Zwischenwand_Innen) °C | – (entfällt) |
| Zwischenwand (Außen) | $(ergebnisse.T_Zwischenwand_Aussen) °C | – (entfällt) |
| Außenwand (Innenseite) | $(ergebnisse.T_Aussenwand_Innen) °C | $(ergebnisse_gefuellt.T_Aussenwand_Innen) °C |
| **Außenwand (Berührung)** | **$(ergebnisse.T_Aussen_Oberflaeche) °C** | **$(ergebnisse_gefuellt.T_Aussen_Oberflaeche) °C** |
| ❄️ **Raumluft (Außen)** | **$(T_aussen) °C** | **$(T_aussen) °C** |
| | | |
| ⚡ **Wärmeverlust ($\dot{Q}$)** | **$(ergebnisse.Waermeverlust_W) Watt** | **$(ergebnisse_gefuellt.Waermeverlust_W) Watt** |

*(Hinweis: Der Wärmeverlust bezieht sich auf die definierte Fläche von $1.0 m^2$. Für die Berührungssicherheit sollte die Außenwand-Temperatur idealerweise unter 45-50 °C liegen.)*
"""

# ╔═╡ 82908196-15b8-4249-b602-3975df42cd5c
let
    # --- 1. X-Achse (Geometrie für den Hintergrund) ---
    d_coat_mm = (beschichtung == "Keine") ? 0.0 : dickeBeschichtung
    
    x0 = 0.0
    x1 = x0 + d_coat_mm
    x2 = x1 + dickeGrundmaterial
    x3 = x2 + d_gap1_mm
    x4 = x3 + dickeZwischenwand
    x5 = x4 + d_gap2_mm
    x6 = x5 + dickeAussenwand
    
    x_positions_schild = [x0, x1, x2, x3, x4, x5, x6]
    
    # Für das gefüllte Modell überspringen wir die Mitte!
    x_positions_gefuellt = [x0, x1, x2, x5, x6]
    
    # --- 2. Y-Achsen (Daten laden) ---
    y_temps_schild = [
        ergebnisse.T_Beschichtung_Innen, ergebnisse.T_Wand1_Innen, ergebnisse.T_Wand1_Aussen,
        ergebnisse.T_Zwischenwand_Innen, ergebnisse.T_Zwischenwand_Aussen,
        ergebnisse.T_Aussenwand_Innen, ergebnisse.T_Aussen_Oberflaeche
    ]
    
    y_temps_gefuellt = [
        ergebnisse_gefuellt.T_Beschichtung_Innen, 
        ergebnisse_gefuellt.T_Wand1_Innen, 
        ergebnisse_gefuellt.T_Wand1_Aussen,
        ergebnisse_gefuellt.T_Aussenwand_Innen, 
        ergebnisse_gefuellt.T_Aussen_Oberflaeche
    ]
    
    # --- 3. Basis-Graph zeichnen (Hitzeschild) ---
    p = plot(x_positions_schild, y_temps_schild, 
        label="Hitzeschild (Luftspalte)", 
        linewidth=3, color=:red, marker=:circle, markersize=6, markercolor=:white,
        xlabel="Wanddicke (mm) -> von Innen (0) nach Außen", ylabel="Temperatur (°C)",
        title="Vergleich: Hitzeschild vs. Klassische Dämmung",
        legend=:topright, grid=true, dpi=150, size=(800, 500)
    )
    
    # --- 4. ZWEITE Kurve (Modell 2: Gefüllt) ---
    plot!(p, x_positions_gefuellt, y_temps_gefuellt, 
        label="Vollflächig gefüllt ($daemmstoff)", 
        linewidth=3, color=:green, linestyle=:dash, marker=:square, markersize=5
    )
    
    # --- 5. Schichten im Hintergrund farblich markieren ---
    if beschichtung != "Keine"
        vspan!(p, [x0, x1], label="", color=:orange, alpha=0.3)
    end
    vspan!(p, [x1, x2], label="", color=:gray, alpha=0.3)
    
    # Den Isolationsraum farblich anpassen
    vspan!(p, [x2, x5], label="Isolationsraum (Luft oder Dämmstoff)", color=:lightgreen, alpha=0.1)
    
    # Das Zwischenblech des Hitzeschilds als schmalen Streifen andeuten
    vspan!(p, [x3, x4], label="Zwischenblech (nur Hitzeschild)", color=:gray, alpha=0.5)
    
    vspan!(p, [x5, x6], label="", color=:gray, alpha=0.7)
    
    # --- 6. Umgebungsbedingungen ---
    hline!(p, [T_innen], label="Heißluft ($T_innen °C)", linestyle=:dash, color=:orange)
    hline!(p, [T_aussen], label="Raumluft ($T_aussen °C)", linestyle=:dash, color=:blue)
    
    p
end

# ╔═╡ cce389a8-e09a-4847-b16c-45a427e77733
md"""
### 📚 Physikalische und Mathematische Grundlagen

Um die Berechnungen nachvollziehbar zu machen, sind hier alle verwendeten Formeln dokumentiert. Das Modell basiert auf dem **1D-Wärmewiderstandsnetzwerk**. 
Um Brüche im Gleichungssystem zu vermeiden, rechnen wir direkt mit dem **thermischen Leitwert** $G$ (in $W/K$), welcher der Kehrwert des thermischen Widerstands $R$ ist ($G = 1/R$).

**1. Wärmeleitung (Festkörper & Dämmstoffe)**
Für die Wärmeleitung durch eine ebene Wand (z.B. Edelstahl, Kapton, Steinwolle) berechnet sich der Leitwert über die Materialdicke $d$, die Wärmeleitfähigkeit $\lambda$ und die betrachtete Fläche $A$:

$$G_{\lambda} = \frac{\lambda \cdot A}{d}$$

**2. Konvektion (Luftschichten & Oberflächen)**
Der Wärmeübergang von einer Wand an ein strömendes oder ruhendes Fluid (Luft) wird über den Wärmeübergangskoeffizienten $\alpha_{Konv}$ beschrieben:

$$G_{Konv} = \alpha_{Konv} \cdot A$$

**3. Wärmestrahlung (In den Luftspalten)**
Besonders bei hohen Temperaturen ($>100^\circ C$) überträgt sich Wärme in Hohlräumen massiv durch Infrarotstrahlung. Um dies in das lineare Matrix-System einzubinden, linearisieren wir die Strahlung über einen **äquivalenten Wärmeübergangskoeffizienten $\alpha_{Str}$**.

Für zwei parallele Platten berechnet sich zunächst der resultierende Emissionsgrad $\varepsilon_{res}$ aus den Einzel-Emissionsgraden $\varepsilon_1$ und $\varepsilon_2$ der gegenüberliegenden Oberflächen:

$$\frac{1}{\varepsilon_{res}} = \frac{1}{\varepsilon_1} + \frac{1}{\varepsilon_2} - 1$$

Der Strahlungskoeffizient $\alpha_{Str}$ berechnet sich unter Einbezug der Stefan-Boltzmann-Konstante ($\sigma = 5.67 \cdot 10^{-8} \frac{W}{m^2 K^4}$). *Hinweis: Die Temperaturen $T_1$ und $T_2$ müssen hierfür zwingend in Kelvin (K) umgerechnet werden!*

$$\alpha_{Str} = \varepsilon_{res} \cdot \sigma \cdot \frac{T_1^4 - T_2^4}{T_1 - T_2}$$

Um eine Division durch Null (wenn $T_1 = T_2$) im Code zu vermeiden, nutzen wir die binomische Auflösung:

$$\alpha_{Str} = \varepsilon_{res} \cdot \sigma \cdot (T_1^2 + T_2^2) \cdot (T_1 + T_2)$$

Der kombinierte Leitwert eines Luftspalts ist somit die Parallelschaltung (Addition) von Konvektion und Strahlung:

$$G_{Spalt} = (\alpha_{Konv} + \alpha_{Str}) \cdot A$$

**4. Das Gleichungssystem (Matrix-Formulierung)**
Nach dem 1. Kirchhoffschen Gesetz (Knotenregel) muss die Summe der Wärmeströme an jeder Schichtgrenze (Knoten $j$) null sein. Für das Innere der Wand gilt:

$$-G_{j-1} \cdot T_{j-1} + (G_{j-1} + G_j) \cdot T_j - G_j \cdot T_{j+1} = 0$$

Aufgestellt für alle $n$ Knoten ergibt sich ein lineares Gleichungssystem der Form:

$$[K] \cdot \vec{T} = \vec{Q}$$

Hierbei ist $[K]$ die Wärmeleitfähigkeitsmatrix (Stiffness Matrix), $\vec{T}$ der gesuchte Temperaturvektor und $\vec{Q}$ der Lastvektor der bekannten Randbedingungen ($T_{innen}$ und $T_{aussen}$). Da die Strahlung temperaturabhängig ist, wird dieses System in einer Schleife iterativ gelöst.
"""

# ╔═╡ 43e3a73d-599b-4e6d-9d5c-713c6ee2160c
md"""
### ⚙️ Numerik: Das iterative Matrix-Verfahren (Hintergrund)

Dieses Notebook nutzt eine numerische Lösung, um die Temperaturen an den Schichtgrenzen zu bestimmen. Hier ist das logische Vorgehen für dein Verständnis dokumentiert:

**1. Diskretisierung (Knotenmodell)**
Wir zerlegen die Wand in $n$ Schichten. An den Kontaktstellen sitzen unsere **Knoten**. Zwischen den Knoten fließen Wärmeströme, getrieben durch Temperaturdifferenzen und begrenzt durch thermische Leitwerte $G$.

**2. Die Knotenregel (Energieerhaltung)**
An jedem inneren Knoten $j$ muss die Summe der ein- und ausfließenden Wärmeströme Null ergeben (es gibt keine Wärmequellen in der Wand):
$$(G_{j-1} \cdot T_{j-1}) - (G_{j-1} + G_j) \cdot T_j + (G_j \cdot T_{j+1}) = 0$$
Dieses Muster wiederholt sich für jede Zeile der Matrix $[K]$.

**3. Das nichtlineare Strahlungsproblem**
Wärmeleitung ($\lambda$) ist linear. Wärmestrahlung hingegen ist **nichtlinear**, da sie mit $T^4$ skaliert. Da wir die Temperaturen $T$ erst berechnen wollen, aber für den Strahlungskoeffizienten $\alpha_{Str}$ bereits kennen müssten, entsteht ein mathematischer Zirkelbezug.

**4. Die Lösung: Fixpunkt-Iteration**
Um dieses Problem zu lösen, wendet der Algorithmus ein iteratives Verfahren an:
1. **Initialisierung:** Das System "rät" eine Starttemperatur für alle Knoten (z. B. Umgebungstemperatur).
2. **Leitwert-Update:** Mit den aktuellen Temperaturen wird der Strahlungsanteil $\alpha_{Str}$ für die Luftspalte berechnet.
3. **Matrix-Lösung:** Das lineare Gleichungssystem $[K] \cdot \vec{T} = \vec{Q}$ wird gelöst, um verbesserte Temperaturwerte zu erhalten.
4. **Wiederholung:** Die Schritte 2 und 3 werden mehrfach (hier 10-mal) wiederholt.



**Konvergenz:**
Schon nach wenigen Durchläufen stabilisieren sich die Werte (sie "konvergieren"). Die Änderung der Temperatur zwischen zwei Durchläufen wird so minimal, dass das Ergebnis physikalisch exakt ist. Dies erlaubt es uns, die hochkomplexe Strahlungsphysik in einem einfachen linearen Matrix-System abzubilden.
"""

# ╔═╡ 1e36bd00-a752-42b8-850e-e866b45a5e9f
md"""
**5. Bestimmung des Wärmestroms**
Da im stationären Zustand der Wärmestrom durch jede Schicht der Wand konstant ist, kann er direkt über den ersten Wärmeübergangswiderstand bestimmt werden:

$$\dot{Q} = G_{in} \cdot (T_{innen} - T_{Wand,innen})$$

Alternativ lässt sich der Wärmestrom über den Gesamtwiderstand $R_{ges}$ der Reihenschaltung berechnen:

$$\dot{Q} = \frac{T_{innen} - T_{aussen}}{R_{ges}}$$
"""

# ╔═╡ 78d76e33-a672-4df6-a5e5-549066559f6b
md"""
**6. Berechnung des Wärmestroms (Leistung)**
Der Wärmestrom $\dot{Q}$ (in Watt) gibt an, wie viel Energie pro Zeiteinheit durch die Wand verloren geht. Da wir ein stationäres System betrachten, ist dieser Strom an jeder Stelle der Wand identisch. Wir berechnen ihn am einfachsten über den inneren Wärmeübergang:

$$\dot{Q} = G_{in} \cdot (T_{innen} - T_{1})$$

Dabei ist $T_1$ die Temperatur der innersten Oberfläche (Knoten 1). 

**Wichtig für die Auslegung:**
Dieser Wert bezieht sich auf die im Modell definierte Fläche $A$ (hier $1 m^2$). Für die gesamte Heizleistung des Ofens muss dieser Wert auf die Gesamtoberfläche des Gehäuses hochgerechnet werden.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Plots = "~1.41.4"
PlutoUI = "~0.7.79"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.4"
manifest_format = "2.0"
project_hash = "ba0cbd4d2ac4ed11fc138a76b49e39f1285c41ed"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fde3bf89aead2e723284a8ff9cdf5b551ed700e8"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.5+0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "e357641bb3e0638d353c4b29ea0e40ea644066a6"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.3"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "27af30de8b5445644e8ffe3bcb0d72049c089cf1"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.7.3+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "95ecf07c2eea562b5adbd0696af6db62c0f52560"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.5"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "01ba9d15e9eae375dc1eb9589df76b3572acd3f2"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.0.1+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "2c5512e11c791d1baed2049c5652441b28fc6a31"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "b7bfd56fa66616138dfe5237da4dc13bbd83c67f"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.1+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "f305bdb91e1f3fcc687944c97f2ede40585b1bd5"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.19"

    [deps.GR.extensions]
    GRIJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "de439fbc02b9dc0e639e67d7c5bd5811ff3b6f06"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.19+1"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "6b4d2dc81736fe3980ff0e8879a9fc7c33c44ddf"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.86.2+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5e6fe50ae7f23d171f44e311c2960294aaa0beb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.19"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "f923f9a774fcf3f5cb761bfa43aeadd689714813"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.1+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "b3ad4a0255688dcb895a52fafbaae3023b588a90"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.4.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6893345fd6658c8e475d40155789f4860ac3b21"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.4+0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "44f93c47f9cd6c7e431f2f2091fcba8f01cd7e8f"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.10"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3acf07f130a76f87c041cfb2ff7d7284ca67b072"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.41.2+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "f04133fe05eff1667d2054c53d59f9122383fe05"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.2+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2a7a12fc0a4e7fb773450d17975322aa77142106"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.41.2+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f00544d95982ea270145636c181ceda21c4e2575"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.2.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ff69a2b1330bcb730b9ac1ab7dd680176f5896b8"
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.1010+0"

[[deps.Measures]]
git-tree-sha1 = "b513cedd20d9c914783d8ad83d08120702bf2c77"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.3"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "NetworkOptions", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "1d1aaa7d449b58415f97d2839c318b70ffb525a0"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.6.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "39a11854f0cba27aa41efaedf43c77c5daa6be51"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.0+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0662b083e11420952f2e62e17eddae7fc07d5997"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.57.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "26ca162858917496748aad52bb5d3be4d26a228a"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.4"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "063ef757a1e0e15af77bbe92be92da672793fd4e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.41.4"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "3ac7038a98ef6977d44adeadc73cc6f596c08109"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.79"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "07a921781cab75691315adc645096ed5e370cb77"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "522f093a29b31a93e34eaea17ba055d850edea28"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "34f7e5d2861083ec7596af8b8c092531facf2192"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.8.2+2"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "da7adf145cce0d44e892626e647f9dcbe9cb3e10"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.8.2+1"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "9eca9fc3fe515d619ce004c83c31ffd3f85c7ccf"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.8.2+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "8f528b0851b5b7025032818eb5abbeb8a736f853"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.8.2+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "4f96c596b8c8258cc7d3b19797854d368f243ddc"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "aceda6f4e598d331548e04cc6b2124a6148138e3"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.10"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "9297459be9e338e546f5c4bedb59b3b5674da7f1"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.6.2"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "9cce64c0fdd1960b597ba7ecda2950b5ed957438"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.2+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "b5899b25d17bf1889d25906fb9deed5da0c15b3b"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.12+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a4c0ee07ad36bf8bbce1c3bb52d21fb1e0b987fb"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.7+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "a376af5c7ae60d29825164db40787f15c80c7c54"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.3+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a5bc75478d323358a90dc36766f3c99ba7feb024"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.6+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "aff463c82a773cb86061bce8d53a0d976854923e"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.5+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "e3150c7400c41e207012b41659591f083f3ef795"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.3+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "9750dc53819eba4e9a20be42349a6d3b86c7cdf8"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.6+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "00af7ebdc563c9217ecc67776d1bbf037dbcebf4"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.44.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "371cc681c00a3ccc3fbc5c0fb91f58ba9bec1ecf"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.13.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "125eedcb0a4a0bba65b657251ce1d27c8714e9d6"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.4+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "6ab498eaf50e0495f89e7a5b582816e2efb95f64"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.54+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "a1fc6507a40bf504527d0d4067d718f8e179b2b8"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.13.0+0"
"""

# ╔═╡ Cell order:
# ╟─8c662252-ccac-443e-a3bf-f8cd8d3c25eb
# ╟─aba6d2aa-2eca-4daf-a3fe-f8a10b194f37
# ╟─12a93e1f-050b-4b72-8cd8-d159917a62f1
# ╟─683f75d3-e3c7-47d1-a263-7e0e151455a8
# ╟─0df3c255-6507-4e08-94bc-35663d122752
# ╟─0dd06838-d1ee-46f5-ad1e-fd1f900280f6
# ╟─4e392c5d-b609-4b5c-a57d-7e601bbf459c
# ╟─51029a7d-0136-4de8-ade5-d299e1dcc4ce
# ╟─82908196-15b8-4249-b602-3975df42cd5c
# ╟─cce389a8-e09a-4847-b16c-45a427e77733
# ╟─43e3a73d-599b-4e6d-9d5c-713c6ee2160c
# ╟─1e36bd00-a752-42b8-850e-e866b45a5e9f
# ╟─78d76e33-a672-4df6-a5e5-549066559f6b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
