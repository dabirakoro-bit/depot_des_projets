# Programmes de test — Validation du CPU

## Méthode de chargement des programmes de test

Pour ces tests, le programme n'est **pas** chargé manuellement via les switches/boutons après programmation du FPGA — il est directement écrit dans la valeur d'initialisation du signal `program_mem`, à l'intérieur du fichier `ProgramMemory.vhd`, **avant** synthèse et implémentation :

```vhdl
signal program_mem : mem_array := (
    0 => "...",
    1 => "...",
    ...
    others => (others => '0')
);
```

Cette approche élimine tout risque d'erreur de frappe sur les switches lors du chargement manuel, et rend chaque test reproductible à l'identique. Pour changer de programme de test, il faut modifier cette initialisation et **reprogrammer le FPGA** (attention : cela réinitialise aussi `DataMemory`, qui repart à zéro à chaque nouvelle synthèse).

## Rappel : sélecteur d'affichage

Le contenu affiché sur LEDs/7-segments dépend de `sw(7:5)`, lu en continu (pas besoin de bouton) :

| sw(7:5) | Vue |
|---------|-----|
| 000 | `alu_res` (résultat courant de l'ALU) |
| 001 | `pc_out` (position dans le programme) |
| 010 | `instr_out` (poids faible de l'instruction en cours) |
| 011 | `flags_reg` (V, C, N, Z) |
| 100 | `data_a` (registre pointé par RS1, ou RD si STR) |
| 101 | `data_b` (registre pointé par RS2) |
| 110 | Mode hexadécimal 16 bits (`data_a` = poids fort, `data_b` = poids faible) |

**Méthode générale de lecture** : commencer en vue `pc_out` (`sw(7:5)="001"`) pour suivre le déroulement du programme, puis basculer vers `data_a`/`data_b`/hexa une fois le PC stabilisé sur l'instruction finale — pas besoin d'arrêter le CPU pour changer de vue.

## Test 1 — Compte à rebours (DEC + JZ)

**Objectif** : valider DEC, JZ, JMP, et le chaînage boucle/flags.

```vhdl
signal program_mem : mem_array := (
    0 => "1000000000000101", -- LDI R0,5
    1 => "0011000000000000", -- DEC R0
    2 => "1010000000000101", -- JZ 5
    3 => "1001000000000001", -- JMP 1
    4 => "1101000000000000", -- STP (remplissage)
    5 => "1101000000000000", -- STP (fin réelle)
    others => (others => '0')
);
```

**Où observer** : dès `btnU`, mets `sw(7:5)="001"` pour voir le PC osciller entre 1, 2, 3 pendant environ 15 secondes (5 tours de boucle). Une fois le PC stabilisé sur **5**, bascule vers `sw(7:5)="100"` (`data_a`) — tu dois voir **0**, stable indéfiniment.

## Test 2 — Addition 16 bits (ADD + ADC)

**Objectif** : valider le chaînage de retenue entre deux additions 8 bits.

```vhdl
signal program_mem : mem_array := (
    0 => "1000000011001000", -- LDI R0,200   (poids faible de A)
    1 => "1000010001100100", -- LDI R1,100   (poids faible de B)
    2 => "0000010000100000", -- ADD R2,R0,R1
    3 => "1000000000000001", -- LDI R0,1     (poids fort de A)
    4 => "1000010000000010", -- LDI R1,2     (poids fort de B)
    5 => "0001011000100000", -- ADC R3,R0,R1
    6 => "1101000111000000", -- STP (rs1=R3, rs2=R2 encodés pour l'affichage)
    others => (others => '0')
);
```

**Où observer** : programme court (7 secondes) — attends 7-8 secondes après `btnU`, puis mets directement `sw(7:5)="110"` (mode hexadécimal). Résultat attendu : **`042C`** (1068 en décimal = 456+612).

## Test 3 — Jeu d'instructions complet (12 opérations ALU)

**Objectif** : valider INC, SUB, NEG, OR, XOR, NOT, SHL, SHR, ROL, ADDS, SBB, PASSA.

Code complet (64 instructions) : voir `src/test_programs/test3_alu_complet.vhd`.

Résultats attendus, dans l'ordre de relecture :

| Résultat # | Opération | Valeur attendue |
|---|---|---|
| 1 | INC | 6 |
| 2 | SUB | 7 |
| 3 | NEG | 251 |
| 4 | OR | 14 |
| 5 | XOR | 6 |
| 6 | NOT | 240 |
| 7 | SHL | 2 |
| 8 | SHR | 64 |
| 9 | ROL | 1 |
| 10 | ADDS | 150 |
| 11 | SBB | 7 (voir note ci-dessous) |
| 12 | PASSA | 77 |

**Où observer** : bloc de calcul (~39 secondes), puis à partir de la 40e seconde environ, `sw(7:5)="100"` avec pause (`btnU`) à chaque paire `LOAD`+`PASSA` (2 secondes).

**Note sur SBB (résultat #11)** : dépend du carry laissé par la dernière instruction ALU exécutée juste avant (ADDS ici, qui laisse carry=0 car 100+50=150 tient dans 8 bits) — pas d'un carry plus ancien.

## Test 4 — Sauts conditionnels (JC et JN, cas positif et négatif)

**Objectif** : valider que JC/JN sautent bien quand le flag est à 1, et ne sautent pas quand il est à 0.

```vhdl
signal program_mem : mem_array := (
     0 => "1000000011001000", -- LDI R0,200
     1 => "1000010001100100", -- LDI R1,100
     2 => "0000010000100000", -- ADD R2,R0,R1      (carry=1)
     3 => "1011000000000110", -- JC t1_ok           (doit sauter)
     4 => "1000110010101010", -- LDI R3,170         (poison)
     5 => "1001000000000111", -- JMP t1_store
     6 => "1000110001010101", -- LDI R3,85          (t1_ok)
     7 => "1111110000000000", -- STR R3,0           (attendu: 85)
     8 => "1000000000001010", -- LDI R0,10
     9 => "1000010000000101", -- LDI R1,5
    10 => "0000010000100000", -- ADD R2,R0,R1      (carry=0)
    11 => "1011000000001110", -- JC t2_bad          (ne doit PAS sauter)
    12 => "1000110001010101", -- LDI R3,85          (chemin normal)
    13 => "1001000000001111", -- JMP t2_store
    14 => "1000110010101010", -- LDI R3,170         (poison)
    15 => "1111110000000001", -- STR R3,1           (attendu: 85)
    16 => "1000000000000101", -- LDI R0,5
    17 => "0011100000000000", -- NEG R0             (N=1)
    18 => "1100000000010101", -- JN t3_ok           (doit sauter)
    19 => "1000110010101010", -- LDI R3,170         (poison)
    20 => "1001000000010110", -- JMP t3_store
    21 => "1000110001010101", -- LDI R3,85          (t3_ok)
    22 => "1111110000000010", -- STR R3,2           (attendu: 85)
    23 => "1000000000000101", -- LDI R0,5
    24 => "0111100000000000", -- PASSA R0,R0        (N=0)
    25 => "1100000000011100", -- JN t4_bad          (ne doit PAS sauter)
    26 => "1000110001010101", -- LDI R3,85          (chemin normal)
    27 => "1001000000011101", -- JMP t4_store
    28 => "1000110010101010", -- LDI R3,170         (poison)
    29 => "1111110000000011", -- STR R3,3           (attendu: 85)
    30 => "1110000000000000", -- LOAD R0,0
    31 => "0111111000000000", -- PASSA R3,R0
    32 => "1110000000000001", -- LOAD R0,1
    33 => "0111111000000000", -- PASSA R3,R0
    34 => "1110000000000010", -- LOAD R0,2
    35 => "0111111000000000", -- PASSA R3,R0
    36 => "1110000000000011", -- LOAD R0,3
    37 => "0111111000000000", -- PASSA R3,R0
    38 => "1101000000000000", -- STP
    others => (others => '0')
);
```

**Où observer** : ~30 secondes pour les tests, puis relecture (`LOAD`+`PASSA`, 2s chacune) — `sw(7:5)="100"` dès le lancement, pause avec `btnU` à chaque valeur. Les 4 valeurs relues doivent toutes afficher **85**.

## Méthodologie générale de debug

Quand un résultat ne correspond pas à l'attendu :
1. Vérifier l'état du **carry avant l'instruction concernée** — mis à jour par *chaque* instruction ALU, pas seulement celle qui semble pertinente
2. Vérifier l'absence de résidus d'un test précédent en mémoire programme
3. Utiliser `sw(7:5)="001"` pour confirmer que le PC suit le chemin attendu