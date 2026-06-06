# Analýza nutričních dat (Květen 2026)

Tento projekt obsahuje SQL skripty pro analýzu mých osobních dat a nutričního jídelníčku (exportovaného z aplikace pro sledování stravy). Cílem bylo propojit teorii datové analýzy s reálnými daty z mého jídelníčku a sledovat konzistenci v plnění cílů.

## 🛠️ Použité technologie
* **Databáze:** PostgreSQL
* **Nástroj:** DBeaver

## 📊 Ukázka analýzy: Korelace pitného režimu a bílkovin
V rámci pokročilé analýzy jsem zkoumal vztah mezi hydratací (`vysledek_piti_l`) a průměrným příjmem bílkovin (`vysledek_bilkoviny_g`). Data byla filtrována na dominantní dny (více než 2 výskyty) a seřazena sestupně.

### Použitý SQL dotaz:
```sql
SELECT
    CASE
        WHEN vysledek_piti_l <= 2 THEN 'málo'
        WHEN vysledek_piti_l <= 3 THEN 'průměr'
        ELSE 'super'
    END AS hodnoceni_vody,
    COUNT(*) AS pocet_dni,
    ROUND(AVG(vysledek_bilkoviny_g), 1) AS prumerna_hodnota_bilkovin
FROM view_komplexni_data_kveten
GROUP BY hodnoceni_vody
HAVING COUNT(*) > 2
ORDER BY prumerna_hodnota_bilkovin DESC;

### Výsledný report:
| hodnoceni_vody | pocet_dni | prumerna_hodnota_bilkovin |
| :--- | :---: | :---: |
| super | 22 | 154.5 |
| průměr | 5 | 132.0 |

Poznámka: Hodnoty v tabulce jsou ilustrační pro ukázku funkčnosti kódu a reprezentují výstup nad mou lokální databází.
