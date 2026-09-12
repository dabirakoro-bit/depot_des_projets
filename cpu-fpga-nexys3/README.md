# CPU 8 bits — FPGA Nexys 3

CPU 8 bits complet, conçu et implémenté en VHDL sur carte Digilent Nexys 3 (Xilinx Spartan-6, synthèse via ISE). Ce projet part d'une ALU FPGA de base pour aboutir à un processeur fonctionnel avec jeu d'instructions complet, exécution monocycle, et mémoire programme/données.

## Fonctionnalités

- Architecture monocycle 8 bits, jeu d'instructions de 23 opérations (15 ALU + 8 spéciales)
- 4 registres généraux (R0–R3)
- Mémoire programme : 64 instructions de 16 bits
- Mémoire de données : 64 octets, avec instructions LOAD/STR
- Sauts conditionnels (JZ, JC, JN) et inconditionnel (JMP)
- Registre de flags persistant (V, C, N, Z), avec chaînage de retenue automatique (ADC/SBB)
- Affichage 6 vues sélectionnables (résultat, PC, instruction, flags, registres) + mode hexadécimal 16 bits
- Jeu d'instructions entièrement validé par 4 programmes de test sur la carte réelle

## Documentation

- [`docs/isa.md`](docs/isa.md) — Jeu d'instructions complet (format, mnémoniques, encodage)
- [`docs/architecture.md`](docs/architecture.md) — Architecture interne, les 8 modules, schéma-bloc
- [`docs/test-programs.md`](docs/test-programs.md) — Programmes de test avec résultats attendus et méthode d'observation

## Schéma-bloc de l'architecture

```
┌─────────────────┐
│  ProgramMemory   │
│  (PC + 64 instr) │
└────────┬─────────┘
         │ instr (16 bits)
         ▼
┌─────────────────┐
│ InstructionFields│
└────────┬─────────┘
         │ class_bit, subop, rd_field, rs1, rs2, imm, addr_field
         ▼
┌─────────────────┐        ┌─────────────────┐
│   ControlUnit    │───────▶│   AddressMux     │
│                  │ rd_role│                  │
└────────┬─────────┘        └────────┬─────────┘
         │                           │ addr_a, addr_b, addr_w
         │ reg_write_enable          ▼
         │ wb_sel, mem_we    ┌─────────────────┐
         │ jump_enable       │  RegisterFile    │
         │ jump_addr, halt   └────────┬─────────┘
         │                            │ data_a, data_b
         │         ┌──────────────────┴──────────────────┐
         │         ▼                                      ▼
         │  ┌─────────────────┐                  ┌─────────────────┐
         │  │    ALU_Unit      │                  │   DataMemory     │
         │  └────────┬─────────┘                  └────────┬─────────┘
         │           │ alu_res, flags_reg                  │ data_mem_out
         │           │                                      │
         │           └──────────────┬───────────────────────┘
         │                          ▼
         │                 ┌─────────────────┐
         │                 │  WritebackMux    │
         │                 └────────┬─────────┘
         │                          │ data_w
         │                          ▼
         └─────────────────▶  (retour vers RegisterFile.we + addr_w
                                et vers ProgramMemory pour les sauts)
```

Une vue RTL générée par Xilinx ISE (View RTL Schematic) est disponible dans `docs/images/` pour référence technique.

## Interface matérielle

| Bouton | Fonction |
|--------|----------|
| btnL | Charge l'adresse mémoire programme |
| btnC | Charge le poids fort de l'instruction |
| btnR | Charge le poids faible (+auto-incrémentation) |
| btnU | Marche/pause de l'exécution |
| btnD | Reset du compteur de programme (PC) |

| Switches | Fonction |
|----------|----------|
| sw(5:0) | Adresse ou donnée lors du chargement manuel |
| sw(7:5) | Sélecteur de la vue d'affichage (voir `docs/test-programs.md`) |

## Utilisation

1. Charger un programme, soit manuellement via les boutons (adresse + poids fort + poids faible de chaque instruction), soit pré-écrit directement dans l'initialisation VHDL de `program_mem` (méthode utilisée pour tous les tests, voir `docs/test-programs.md`)
2. `btnD` pour réinitialiser le PC
3. Choisir la vue d'affichage voulue via `sw(7:5)`
4. `btnU` pour lancer — une nouvelle instruction s'exécute chaque seconde
5. `btnU` à nouveau pour mettre en pause à tout moment (utile pour lire une valeur tranquillement)

## Structure du dépôt

```
cpu-fpga-nexys3/
├── src/            (modules VHDL)
├── constraints/    (fichier .ucf)
├── docs/           (ISA, architecture, tests, images)
└── LICENSE
```

## Limitations connues

- Pas de multiplication ni division
- Une seule rotation (ROL via carry)
- Pas d'adressage indirect (les adresses sont toujours des valeurs immédiates dans l'instruction)
- Aucun debounce logiciel sur les boutons dans les modules "de base" — géré au niveau du top-level (`ButtonPulse`)

## Roadmap

Un environnement de développement complet est en cours de conception : assembleur Python pour ce jeu d'instructions, interface web (Flask) avec éditeur intégré, programmation du FPGA via microcontrôleur, et monitoring temps réel (PC, registres, flags, cycles) avec mode debug pas à pas.

## Licence

MIT