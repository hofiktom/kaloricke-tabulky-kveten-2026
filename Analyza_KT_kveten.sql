--SPOJENÍ 5 TABULEK
--Vygeneroval jsem si 5 analýz z Kalorických tabulek za měsíc květen (od 4.5., kdy vedu pravidelnou statistiku)
SELECT 
	kk."Datum",
	kk."Vysledek_kcal",
    kk."Cil_kcal",
    prk."Vysledek_piti",
    prk."Cil_piti",
    bk."Vysledek_bilkoviny",
    bk."Cil_bilkoviny",
    sk."Vysledek_sacharidy",
    sk."Cil_sacharidy",
    tk."Vysledek_tuky",
    tk."Cil_tuky"
FROM kalorie_kveten AS kk
JOIN pitny_rezim_kveten AS prk ON prk."Datum" = kk."Datum"
JOIN bilkoviny_kveten AS bk ON bk."Datum" = kk."Datum"
JOIN sacharidy_kveten AS sk ON sk."Datum" = kk."Datum"
JOIN tuky_kveten AS tk ON tk."Datum" = kk."Datum";
--spojení všech 5 tabulek, datum jen z první tabulky

--VYČIŠTĚNÍ NOVÉ TABULKY
CREATE OR REPLACE VIEW view_komplexni_data_kveten AS
SELECT 
    kk."Datum",
    REPLACE(kk."Vysledek_kcal", ' kcal', '')::numeric AS vysledek_kcal,
    REPLACE(kk."Cil_kcal", ' kcal', '')::numeric AS cil_kcal,
    REPLACE(prk."Vysledek_piti", ' l', '')::numeric AS vysledek_piti_l,
    REPLACE(prk."Cil_piti", ' l', '')::numeric AS cil_piti_l,
    REPLACE(bk."Vysledek_bilkoviny", ' g', '')::numeric AS vysledek_bilkoviny_g,
    REPLACE(bk."Cil_bilkoviny", ' g', '')::numeric AS cil_bilkoviny_g,
    REPLACE(sk."Vysledek_sacharidy", ' g', '')::numeric AS vysledek_sacharidy_g,
    REPLACE(sk."Cil_sacharidy", ' g', '')::numeric AS cil_sacharidy_g,
    REPLACE(tk."Vysledek_tuky", ' g', '')::numeric AS vysledek_tuky_g,
    REPLACE(tk."Cil_tuky", ' g', '')::numeric AS cil_tuky_g
FROM kalorie_kveten AS kk
JOIN pitny_rezim_kveten AS prk ON prk."Datum" = kk."Datum"
JOIN bilkoviny_kveten AS bk ON bk."Datum" = kk."Datum"
JOIN sacharidy_kveten AS sk ON sk."Datum" = kk."Datum"
JOIN tuky_kveten AS tk ON tk."Datum" = kk."Datum";

--Zobrazení vyčištěné tabulky
SELECT *
FROM view_komplexni_data_kveten;
--tabulka exportována

--ÚKOLY

--Najdi 5 dní, kdy jsi za celý měsíc snědl nejvíce kalorií, seřaď sestupně.
SELECT *
FROM view_komplexni_data_kveten
ORDER BY vysledek_kcal desc
LIMIT 5;

--Zobraz všechny dny, kdy se ti podařilo vypít více než 3 litry vody. Seřaď sestupně.
SELECT *
FROM view_komplexni_data_kveten
WHERE vysledek_piti_l > 3
ORDER BY vysledek_piti_l desc;

-- Najdi dny, kdy jsi překročil cíl v kaloriích (vysledek_kcal > cil_kcal)
-- ale zároveň jsi vypil méně než 2 litry vody (vysledek_piti_l < 2).
SELECT *
FROM view_komplexni_data_kveten
WHERE vysledek_kcal > cil_kcal
AND vysledek_piti_l < 2;

--Zjisti, jaký byl tvůj průměrný denní příjem bílkovin za celý květen.
SELECT
	avg(vysledek_bilkoviny_g) AS prumerny_prijem_bilkovin
FROM view_komplexni_data_kveten;
--přidat AS k pojmenování buňky

--Zjisti v jednom dotazu, kolik litrů vody to bylo v ten nejméně hydratovaný den (minimum)
--a kolik v ten nejvíce hydratovaný den (maximum).
SELECT
	min(vysledek_piti_l) AS nejmene_piti,
	max(vysledek_piti_l) AS nejvice_piti
FROM view_komplexni_data_kveten

--Spočítej, kolik dní (řádků) v měsíci máš v této tabulce celkem zaznamenáno.
SELECT
	count (*) AS pocet_dni
FROM view_komplexni_data_kveten

--Napiš dotaz, který vytáhne následující statistiky (každou jako samostatný sloupec s názvem):
--Celkový počet zaznamenaných dní v měsíci.
--Celkový počet kalorií, které jsi za celý měsíc snědl (suma).
--Průměrný denní příjem kalorií.
--Nejvyšší (maximální) příjem bílkovin v jednom dni (abys viděl svůj proteinový rekord).
--Průměrný denní příjem sacharidů.
--Nejnižší (minimální) množství vody, které jsi za den vypil.

SELECT
	count (*) AS pocet_dni,
	sum (vysledek_kcal) AS celkovy_pocet_kcal,
	ROUND (avg (vysledek_kcal),2) AS prumerny_pocet_kcal,
	max (vysledek_bilkoviny_g) AS nejvyssi_pocet_bilkovin,
	ROUND (avg (vysledek_sacharidy_g),2) AS prumerny_pocet_sacharidu,
	min (vysledek_piti_l) AS nejnizsi_prijem_piti
FROM view_komplexni_data_kveten;
--k průměrům jsem přidal ještě příkaz round, aby se číslo zaokrouhlilo na dvě des.místa

--Když jsi vypil 3 litry a více, chceme v novém sloupci vidět text 'Splněno'.
--Ve všech ostatních případech (když to bylo méně než 3) tam chceme mít text 'Nesplněno'.

SELECT
	"Datum",
	vysledek_piti_l,
CASE
	WHEN vysledek_piti_l >=3 THEN 'Dostatek'
	else 'Nedostatek'
END AS status_pitneho_rezimu
FROM view_komplexni_data_kveten;

--Denní příjem bílkovin - rozdělit odhadem na nízký, optimální, vysoký
SELECT
	"Datum",
	vysledek_bilkoviny_g,
CASE
	WHEN vysledek_bilkoviny_g <120 THEN 'nízký'
	WHEN vysledek_bilkoviny_g <180 THEN 'optimální'
	else 'vysoký'
END AS status_prijmu_bilkovin
FROM view_komplexni_data_kveten
ORDER BY "Datum"::DATE ASC;
--order by - seřazení od první dne měsíce (v tomto případě začátku vyplňování)

-- Spočítej, kolik dní jsi byl v jaké kategorii
SELECT
    CASE
        WHEN vysledek_bilkoviny_g < 120 THEN 'nízký'
        WHEN vysledek_bilkoviny_g < 180 THEN 'optimální'
        ELSE 'vysoký'
    END AS status_prijmu_bilkovin,
    COUNT(*) AS pocet_dni
FROM view_komplexni_data_kveten
GROUP BY status_prijmu_bilkovin;

--K předchozí tabulce přidej nový sloupec
--který spočítá průměrný příjem kalorií vysledek_kcal pro každou z těch tří skupin
--zaokrouhlí ho na celé číslo
SELECT
    CASE
        WHEN vysledek_bilkoviny_g < 120 THEN 'nízký'
        WHEN vysledek_bilkoviny_g < 180 THEN 'optimální'
        ELSE 'vysoký'
    END AS status_prijmu_bilkovin,
    COUNT(*) AS pocet_dni,
    ROUND (avg(vysledek_kcal)) AS prumerna_hodnota_kcal
FROM view_komplexni_data_kveten
GROUP BY status_prijmu_bilkovin;

--Uprav svůj stávající dotaz tak, aby ti vrátil pouze ty skupiny
--které jsi v květnu měl více než 2krát.
SELECT
    CASE
        WHEN vysledek_bilkoviny_g < 120 THEN 'nízký'
        WHEN vysledek_bilkoviny_g < 180 THEN 'optimální'
        ELSE 'vysoký'
    END AS status_prijmu_bilkovin,
    COUNT(*) AS pocet_dni,
    ROUND (avg(vysledek_kcal)) AS prumerna_hodnota_kcal
FROM view_komplexni_data_kveten
GROUP BY status_prijmu_bilkovin
HAVING
	count(*) >2;

--přehled o svém pitném režimu (vysledek_piti_l) za květen.
--Rozdělí dny do tří skupin podle pití:
--Menší nebo rovno 2 litrům -> 'Málo'
--Mezi 2 a 3 litry (včetně) -> 'Průměr'
--Více než 3 litry -> 'Super'
--Tento sloupec pojmenuj hodnoceni_vody.
--Spočítá počet dní v každé skupině (sloupec pocet_dni).
--Spočítá průměrný příjem bílkovin (vysledek_bilkoviny_g) pro každou skupinu a zaokrouhlí ho na 1 desetinné místo (sloupec prumerny_protein).
--Vrátí pouze ty skupiny, které mají počet dní větší než 1.
--Celý výsledek seřadí podle průměrného proteinu od nejvyššího po nejnižší.
SELECT
	CASE
		WHEN vysledek_piti_l <=2 THEN 'málo'
		WHEN vysledek_piti_l <=3 THEN 'průměr'
		ELSE 'super'
	END AS hodnoceni_vody,
	count (*) AS pocet_dni,
	ROUND (avg (vysledek_bilkoviny_g),1) AS prumerna_hodnota_bilkovin
FROM view_komplexni_data_kveten
GROUP BY hodnoceni_vody
HAVING
	count (*) >2
ORDER BY prumerna_hodnota_bilkovin desc;