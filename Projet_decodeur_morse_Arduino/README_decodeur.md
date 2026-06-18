# Décodeur Morse avec Arduino

## Description du projet

Ce projet consiste à réaliser un **décodeur Morse** à l’aide d’un **Arduino**, d’un **bouton poussoir**, d’une **LED de suivi rythmique** et d’un **écran LCD 20×4 avec module I2C**.

L’utilisateur saisit le code Morse via un bouton :

* **Appui court** → point (`.`)
* **Appui long** → trait (`-`)

Le système décode chaque lettre Morse et l’affiche **en temps réel** sur l’écran LCD.

Un **bouton START / STOP** permet de commencer et terminer une session d’écriture.

---

## Fonctionnalités

* Détection du code Morse avec un bouton
* LED synchronisée avec le rythme Morse
* Décodage lettre par lettre (A–Z)
* Affichage structuré sur LCD 20×4 :

  * Mode d’écriture
  * Code Morse en cours
  * Lettre décodée
  * Texte final
* Mode écriture activable / désactivable

---

## Matériel utilisé

* Arduino Uno / Nano
* Écran LCD 20×4 avec module I2C (PCF8574)
* 2 boutons poussoirs
* 1 LED
* 1 résistance 220 Ω (LED)
* Fils de connexion (Dupont)

---

## Câblage (Wiring)

### 📟 LCD 20×4 I2C

```text
LCD I2C      Arduino
----------------------
VCC   ------ 5V
GND   ------ GND
SDA   ------ A4
SCL   ------ A5
```

> ⚠ Sur Arduino Mega : SDA = 20, SCL = 21

---

### 🔘 Boutons poussoirs

(Boutons câblés vers la masse, avec résistances internes activées)

```text
Bouton Morse :
- Une borne  -> GPIO 2
- Autre borne -> GND

Bouton START / STOP :
- Une borne  -> GPIO 3
- Autre borne -> GND
```

---

### LED de suivi rythmique

```text
Arduino GPIO 13 ---- Résistance 220Ω ---- Anode LED
Cathode LED -------- GND
```

---

## ⏱ Paramètres temporels Morse

| Élément      | Durée (ms) |
| ------------ | ---------- |
| Point (`.`)  | < 300 ms   |
| Trait (`-`)  | ≥ 300 ms   |
| Pause lettre | 1000 ms    |

*(Ces valeurs sont ajustables dans le code)*

---

## Organisation de l’affichage LCD

```text
┌────────────────────┐
│ MODE : ECRITURE ON │
│ MORSE : .-..       │
│ LETTRE : L         │
│ TEXTE : HEL        │
└────────────────────┘
```

---

## Architecture logicielle

* `decodeMorse()` : convertit un code Morse en lettre
* `buffer[]` : stocke les points et traits en cours
* LED : visualisation de l’appui bouton
* LCD : affichage utilisateur

---

## Améliorations possibles

* Gestion des espaces entre mots
* Ajout d’un buzzer sonore
* Effacement du texte par appui long
* Sauvegarde du texte
* Version ESP8266 / ESP32

---

## Auteur

Projet **personnel**, réalisé à des fins **pédagogiques et expérimentales**, dans le but de :

* comprendre le code Morse
* maîtriser la gestion du temps (`millis()`)
* apprendre l’interfaçage LCD I2C
* travailler la logique événementielle (boutons)
* structurer un projet Arduino réel

---

## Licence

Projet libre à usage éducatif
