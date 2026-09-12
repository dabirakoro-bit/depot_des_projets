# ALU 8 bits — FPGA Nexys 3

ALU (Arithmetic Logic Unit) 8 bits implémentée en VHDL sur carte Digilent Nexys 3 (Xilinx Spartan-6, synthèse via ISE). Ce projet est la brique de calcul de base d'un futur projet de CPU 8 bits complet.

## Fonctionnalités

- 16 opérations : arithmétique (ADD, ADDS, ADC, INC, SUB, SBB, DEC, NEG), logique (AND, OR, XOR, NOT), décalage/rotation (SHL, SHR, ROL), et passe-plat (MOV)
- Calcul signé et non signé sur 8 bits (-128 à +127 / 0 à 255)
- Registre de flags persistant (V, C, N, Z), avec retenue chaînée automatiquement entre opérations (type ADC/SBB d'un vrai CPU)
- Interface physique complète : chargement par boutons dédiés, affichage 7-segments avec gestion du signe, LEDs de donnée, affichage du code opération sur port d'extension

## Architecture

L'ALU suit une approche "calcule tout en parallèle, sélectionne après" : chaque unité de calcul (additionneur, soustracteur, unité logique, unité de décalage) fonctionne en continu et indépendamment. Un multiplexeur (`ALU_Mux`) sélectionne ensuite, selon le code opération, quel résultat et quels flags envoyer en sortie.

```
DataRegisterManager → [RegA, RegB, alu_op]
                              │
        ┌──────────┬──────────┼──────────┬──────────┐
     Adder8   Subtractor8  LogicUnit8  ShiftRotate8    (calcul en parallèle)
        └──────────┴──────────┼──────────┴──────────┘
                              │
                          ALU_Mux
                              │
                    [alu_res, flags]
```

## Interface matérielle

| Bouton | Fonction |
|--------|----------|
| btnL | Valide le code opération (alu_op) |
| btnC | Valide le registre A |
| btnR | Valide le registre B |
| btnU | Affiche le registre B |
| btnD | Affiche le résultat de l'ALU |

| Entrée/Sortie | Fonction |
|----------------|----------|
| sw(7:0) | Valeur à charger (opérande ou code opération) |
| led(7:0) | Affichage brut de la donnée sélectionnée |
| seg/an/dp | Affichage décimal signé/non signé sur 4 digits |
| JA1 (led_op) | Affichage du code opération actuellement chargé |

![Carte en fonctionnement](docs\images\carte-fonctionnement.jpg)

## Table des opérations

| Code | Nom | Unité | Description |
|------|------|-------|-------------|
| 0000 | ADD | Adder8 | A + B, non signé |
| 0001 | ADDS | Adder8 | A + B, signé |
| 0010 | ADC | Adder8 | A + B + retenue |
| 0011 | INC | Adder8 | A + 1 |
| 0100 | SUB | Subtractor8 | A - B, non signé |
| 0101 | SBB | Subtractor8 | A - B - retenue, signé |
| 0110 | DEC | Subtractor8 | A - 1 |
| 0111 | NEG | Adder8 | Complément à 2 de A |
| 1000 | AND | LogicUnit8 | A AND B |
| 1001 | OR | LogicUnit8 | A OR B |
| 1010 | XOR | LogicUnit8 | A XOR B |
| 1011 | NOT | LogicUnit8 | NOT A |
| 1100 | SHL | ShiftRotate8 | Décalage à gauche |
| 1101 | SHR | ShiftRotate8 | Décalage à droite |
| 1110 | ROL | ShiftRotate8 | Rotation via carry |
| 1111 | MOV | — | Passe-plat de A |

## Registre de flags

| Bit | Nom | Signification |
|-----|-----|----------------|
| 3 | V | Overflow (dépassement signé) |
| 2 | C | Carry / Borrow |
| 1 | N | Negative (bit de signe) |
| 0 | Z | Zero |

Le registre de flags est persistant : il se met à jour à chaque validation d'une nouvelle opération, et son bit C est automatiquement réinjecté comme retenue d'entrée pour l'opération suivante.

## Programmation

1. Ouvrir le projet dans Xilinx ISE
2. Lancer Synthesize → Implement → Generate Programming File
3. Programmer le bitstream (`.bit`) sur la carte via Adept ou iMPACT
4. Charger les opérandes et l'opcode via les switches et boutons décrits ci-dessus

## Limitations connues

- Largeur fixe de 8 bits (pas de 16/32 bits)
- Pas de multiplication ni division
- Une seule rotation disponible (ROL via carry), pas de ROR/RCL/RCR
- Pas de debounce matériel sur les boutons

## Roadmap

Ce projet constitue la base d'un futur CPU 8 bits complet (séquenceur d'instructions, mémoire programme, contrôle de flux basé sur les flags).

## Licence

MIT