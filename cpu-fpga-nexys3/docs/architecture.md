# Architecture — CPU 8 bits FPGA

## Vue d'ensemble

Le CPU suit une architecture **monocycle** : chaque instruction est entièrement traitée (lecture, décodage, exécution, écriture) en un seul cycle du signal `tick`, généré à partir de l'horloge 100 MHz de la carte via un diviseur de fréquence.

```
             ┌──────────────┐
             │     clk      │
             │   100 MHz    │
             └──────┬───────┘
                    │
             ┌──────▼───────┐
             │ ClockDivider │
             └──────┬───────┘
                    │ tick (1 Hz)
                    ▼
        ┌─────────────────────────┐
        │   Validation instruction │
        │  (RegisterFile, ALU,     │
        │   DataMemory, PC)        │
        └─────────────────────────┘
```

`clk` cadence tout le matériel en continu ; `tick` indique le moment précis où l'état du CPU (registres, mémoire, PC, flags) peut être modifié — une seule fois par instruction.

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

**Légende des flux principaux** :
- Flèches descendantes : chemin normal d'une instruction (fetch → decode → adressage → registres → calcul/mémoire → écriture)
- `ControlUnit` pilote 5 destinations : `AddressMux`, `RegisterFile`, `DataMemory`, `ProgramMemory`, `WritebackMux`
- `ALU_Unit` renvoie `flags_reg` vers `ControlUnit`, utilisé pour évaluer les sauts conditionnels (JZ, JC, JN)



## Les 8 modules

### 1. `ProgramMemory`
Mémoire de 64 instructions (16 bits chacune) + compteur de programme (PC, 6 bits). Chargement manuel du programme via boutons (adresse + poids fort + poids faible, avec auto-incrémentation), ou initialisation directe dans le code VHDL pour les tests. Le PC avance automatiquement au rythme du `tick`, sauf saut (`jump_enable`/`jump_addr`) ou arrêt (`halt`) demandés par le décodeur. Un signal `run_state` (bascule marche/pause, piloté par bouton) contrôle si le PC avance.

### 2. `InstructionFields`
Extraction combinatoire pure des champs de l'instruction courante : `class_bit`, `alu_op`, `subop`, `rd_field`, `rs1`, `rs2`, `imm`, `addr_field`. Aucune décision, juste un découpage de bits selon le format défini dans `isa.md`.

### 3. `ControlUnit`
Le cœur des décisions : à partir de `class_bit`, `subop`, et `flags_reg`, produit tous les signaux de contrôle — `reg_write_enable`, `wb_sel` (source d'écriture registre), `mem_we` (écriture mémoire de données), `jump_enable` (calculé en croisant le SUBOP avec le flag concerné), `halt`, et `rd_role` (résout l'ambiguïté du champ RD, voir plus bas).

### 4. `AddressMux`
Résout un cas particulier du format d'instruction : le champ RD sert de **destination** pour la plupart des instructions (ALU, LDI, LOAD), mais de **source à lire** pour STR. Ce module aiguille `rd_field`/`rs1`/`rs2` vers les bonnes entrées d'adresse du `RegisterFile` (`addr_a`, `addr_b`, `addr_w`) selon `rd_role`.

### 5. `RegisterFile`
Banc de 4 registres (R0–R3). Deux lectures combinatoires simultanées (`data_a`, `data_b`), une écriture synchrone (`we`, qualifiée par `tick` pour n'écrire qu'une fois par instruction).

### 6. `ALU_Unit`
Calcule les 16 opérations arithmétiques/logiques en parallèle (un additionneur, un soustracteur, une unité logique, une unité de décalage, tous actifs en continu), puis sélectionne le bon résultat via un multiplexeur interne selon `alu_op`. Maintient un registre de flags persistant (`flags_reg`), mis à jour uniquement pour les instructions ALU et qualifié par `tick`.

### 7. `DataMemory`
Mémoire de 64 octets, un seul port d'accès (adresse commune lecture/écriture). Lecture combinatoire, écriture synchrone qualifiée par `tick` et `mem_we` (actif uniquement pour STR).

### 8. `WritebackMux`
Multiplexeur 3-vers-1 sur l'entrée d'écriture du `RegisterFile` : choisit entre le résultat de l'ALU, la valeur immédiate (LDI), ou la donnée lue en mémoire (LOAD), selon `wb_sel`.

## Modules auxiliaires

- **`ButtonPulse`** : convertit un appui bouton physique (maintenu des millions de cycles à 100 MHz) en une impulsion d'un seul cycle, évitant les écritures répétées incontrôlées.
- **`ClockDivider`** : génère le signal `tick` à partir de l'horloge 100 MHz.
- **`Display_Manager`** : gère l'affichage (LEDs + 7-segments), avec 6 vues sélectionnables (résultat ALU, PC, instruction, flags, registres A/B) et un mode hexadécimal 16 bits pour visualiser des résultats étendus sur deux registres.

## Principe de synchronisation

Toutes les écritures d'état (RegisterFile, flags, DataMemory, PC) sont qualifiées par le signal `tick` — sans cette qualification, un signal de contrôle actif pendant toute la durée d'une instruction (jusqu'à 1 seconde, soit 100 millions de cycles à 100 MHz) provoquerait des écritures répétées incontrôlées. C'est un point de conception central de cette architecture, découvert et corrigé après des tests sur la boucle DEC/JZ montrant un comportement erratique du compteur.

## Cas particulier : le champ RD à double rôle

Le format d'instruction spéciale ne réserve qu'un seul champ RD (2 bits) — pour la plupart des instructions, il désigne le registre **destination**. Mais pour STR, il n'y a pas de registre destination (on écrit en mémoire, pas dans un registre) : ce même champ RD désigne alors le registre **source** à lire. `ControlUnit` détecte ce cas (`rd_role`) et `AddressMux` route le champ en conséquence — vers `addr_w` (écriture) dans le cas général, vers `addr_a` (lecture) pour STR