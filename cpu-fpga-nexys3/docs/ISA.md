# Jeu d'instructions (ISA) — CPU 8 bits FPGA

## Vue d'ensemble

- Largeur des données : 8 bits
- Largeur des instructions : 16 bits
- Registres généraux : 4 (R0–R3), adressables sur 2 bits
- Mémoire programme : 64 mots de 16 bits
- Mémoire de données : 64 octets
- Architecture : monocycle (une instruction = un cycle d'exécution, cadencé par un signal `tick`)
- Registre de flags : 4 bits, persistant (V, C, N, Z), mis à jour à chaque instruction ALU

## Format d'instruction

Bit 15 (CLASS) distingue deux familles d'instructions :
- `0` = instruction ALU (registre-registre)
- `1` = instruction spéciale

### CLASS = 0 — Instructions ALU

| Bits | 15 | 14:11 | 10:9 | 8:7 | 6:5 | 4:0 |
|------|-----|-------|------|-----|-----|-----|
| Champ | 0 | ALU_OP | RD | RS1 | RS2 | réservé |

### CLASS = 1 — Instructions spéciales

| Bits | 15 | 14:12 | 11:10 | 9:0 |
|------|-----|-------|-------|-----|
| Champ | 1 | SUBOP | RD | IMM/ADDR |

## Table des instructions ALU (ALU_OP, 4 bits)

| Code | Mnémonique | Description |
|------|------------|--------------|
| 0000 | ADD | RD = RS1 + RS2, non signé |
| 0001 | ADDS | RD = RS1 + RS2, signé (affichage) |
| 0010 | ADC | RD = RS1 + RS2 + retenue |
| 0011 | INC | RD = RS1 + 1 |
| 0100 | SUB | RD = RS1 - RS2, non signé |
| 0101 | SBB | RD = RS1 - RS2 - retenue, signé |
| 0110 | DEC | RD = RS1 - 1 |
| 0111 | NEG | RD = complément à 2 de RS1 |
| 1000 | AND | RD = RS1 AND RS2 |
| 1001 | OR | RD = RS1 OR RS2 |
| 1010 | XOR | RD = RS1 XOR RS2 |
| 1011 | NOT | RD = NOT RS1 |
| 1100 | SHL | RD = RS1 décalé à gauche |
| 1101 | SHR | RD = RS1 décalé à droite |
| 1110 | ROL | RD = RS1 tourné via carry |
| 1111 | PASSA | RD = RS1 (recopie directe) |

## Table des instructions spéciales (SUBOP, 3 bits)

| Code | Mnémonique | Champs utilisés | Description |
|------|------------|-------------------|--------------|
| 000 | LDI Rd, imm | RD, IMM(7:0) | Charge une valeur immédiate (0–255) dans Rd |
| 001 | JMP addr | ADDR(5:0) | Saut inconditionnel |
| 010 | JZ addr | ADDR(5:0) | Saute si flag Z=1 |
| 011 | JC addr | ADDR(5:0) | Saute si flag C=1 |
| 100 | JN addr | ADDR(5:0) | Saute si flag N=1 |
| 101 | STP | — | Arrête l'exécution (gèle le PC) |
| 110 | LOAD Rd, addr | RD, ADDR(5:0) | Charge DataMemory[addr] dans Rd |
| 111 | STR Rs, addr | RD(=Rs), ADDR(5:0) | Écrit Rs dans DataMemory[addr] |

**Note d'implémentation** : pour LOAD/STR/JMP/JZ/JC/JN, seuls les 6 bits de poids faible du champ IMM/ADDR (10 bits) sont utilisés comme adresse (mémoire programme et mémoire de données faisant chacune 64 cases). Pour LDI, seuls les 8 bits de poids faible sont utilisés comme valeur immédiate.

## Registre de flags

| Bit | Nom | Signification |
|-----|-----|----------------|
| 3 | V | Overflow (dépassement signé) |
| 2 | C | Carry / Borrow |
| 1 | N | Negative (bit de signe du résultat) |
| 0 | Z | Zero (résultat nul) |

Le registre de flags est mis à jour uniquement par les instructions ALU (CLASS=0), une fois par instruction (au `tick`). Le bit C est automatiquement réinjecté comme retenue d'entrée pour l'instruction ALU suivante (mécanisme utilisé par ADC/SBB pour chaîner des calculs sur plus de 8 bits).

## Exemples d'encodage

| Assembleur | Binaire | Hex |
|------------|---------|-----|
| `LDI R0, 5` | `1000000000000101` | `8005` |
| `ADD R2, R0, R1` | `0000010000100000` | `0420` |
| `JZ 5` | `1010000000000101` | `A005` |
| `STR R0, 10` | `1111000000001010` | `F00A` |
| `STP` | `1101000000000000` | `D000` |

## Limitations connues de cette ISA

- Pas de multiplication ni division
- Une seule rotation (ROL via carry), pas de ROR/RCL/RCR
- Tous les 8 slots SUBOP sont occupés (aucun code libre pour de futures instructions spéciales sans redéfinir le format)
- Pas d'adressage indirect (les adresses mémoire sont toujours des valeurs immédiates dans l'instruction, jamais issues d'un registre)