# Music Compiler - Pianina Digitală

Acest proiect reprezintă un compilator care transformă partituri scrise într-un limbaj specific (DSL) în fișiere audio. Utilizând instrumentele de analiză lexicală și sintactică **Lex** și **Yacc**, aplicația parsează notele muzicale și generează o ieșire sonoră.

---

## Arhitectura Proiectului

Proiectul este structurat pe baza etapelor clasice de compilare:

* **Analiză Lexicală (`proiect.l`):** Fișierul **Lex** care identifică token-urile (notele muzicale, pauzele, durata acestora).
* **Analiză Sintactică (`proiect.y`):** Fișierul **Yacc** care definește gramatica limbajului muzical și regulile de compoziție.
* **Parser & Lexer (`lexer.cpp`, `parser.cpp`):** Componentele care procesează datele de intrare.
* **Fișiere Sursă Muzicale:** Fișiere text ce conțin partituri exemplificative:
    * `rapsodiaRomana.txt`
    * `seaOfThieves.txt`
    * `tiAmo.txt`
* **Ieșire Audio (`iesire.wav`):** Rezultatul final al compilării. Sunetul generat în urma procesării partiturii.
