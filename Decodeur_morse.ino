#include <Wire.h>
#include <LiquidCrystal_I2C.h>

LiquidCrystal_I2C lcd(0x3F, 20, 4);

#define BTN_MORSE D2
#define BTN_MODE  D3
#define LED_PIN   D4

#define DOT_TIME   300
#define LETTER_GAP 1000

bool writingMode = false;

unsigned long pressStart = 0;
unsigned long lastRelease = 0;

char buffer[6];
int indexBuf = 0;

int textCol = 7; // position après "TEXTE : "

// Table Morse
const char* morseTable[] = {
  ".-","-...","-.-.","-..",".","..-.","--.","....","..",
  ".---","-.-",".-..","--","-.","---",".--.","--.-",
  ".-.","...","-","..-","...-",".--","-..-","-.--","--.."
};
const char alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

char decodeMorse(const char* code) {
  for (int i = 0; i < 26; i++) {
    if (strcmp(code, morseTable[i]) == 0)
      return alphabet[i];
  }
  return '?';
}

void afficherMode() {
  lcd.setCursor(0, 0);
  lcd.print("MODE : ");
  lcd.print(writingMode ? "ECRITURE ON " : "ECRITURE OFF");
}

void setup() {
  pinMode(BTN_MORSE, INPUT_PULLUP);
  pinMode(BTN_MODE, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);

  lcd.init();
  lcd.backlight();
  lcd.clear();

  afficherMode();

  lcd.setCursor(0,1);
  lcd.print("MORSE : ");

  lcd.setCursor(0,2);
  lcd.print("LETTRE : ");

  lcd.setCursor(0,3);
  lcd.print("TEXTE : ");
}

void loop() {
  /* ---------- Bouton MODE ---------- */
  static bool lastModeBtn = HIGH;
  bool modeBtn = digitalRead(BTN_MODE);

  if (modeBtn == LOW && lastModeBtn == HIGH) {
    writingMode = !writingMode;
    delay(200);

    lcd.clear();
    indexBuf = 0;
    textCol = 7;

    afficherMode();
    lcd.setCursor(0,1); lcd.print("MORSE : ");
    lcd.setCursor(0,2); lcd.print("LETTRE : ");
    lcd.setCursor(0,3); lcd.print("TEXTE : ");
  }
  lastModeBtn = modeBtn;

  if (!writingMode) return;

  /* ---------- Bouton MORSE ---------- */
  bool morseBtn = digitalRead(BTN_MORSE);

  if (morseBtn == LOW && pressStart == 0) {
    pressStart = millis();
    digitalWrite(LED_PIN, HIGH);
  }

  if (morseBtn == HIGH && pressStart > 0) {
    unsigned long duration = millis() - pressStart;
    digitalWrite(LED_PIN, LOW);
    pressStart = 0;
    lastRelease = millis();

    buffer[indexBuf++] = (duration < DOT_TIME) ? '.' : '-';
    buffer[indexBuf] = '\0';

    // Affichage du morse en temps réel
    lcd.setCursor(8,1);
    lcd.print("        ");
    lcd.setCursor(8,1);
    lcd.print(buffer);
  }

  /* ---------- Fin de lettre ---------- */
  if (indexBuf > 0 && (millis() - lastRelease) > LETTER_GAP) {
    char letter = decodeMorse(buffer);

    // Afficher lettre
    lcd.setCursor(9,2);
    lcd.print(letter);
    lcd.print(" ");

    // Ajouter au texte
    lcd.setCursor(textCol++, 3);
    lcd.print(letter);

    indexBuf = 0;

    lcd.setCursor(8,1);
    lcd.print("        "); // Effacer MORSE
  }
}
