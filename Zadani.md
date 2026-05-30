# Entry projekt - Seznam Flutter Vývojář

Toto jsou instrukce pro kandidáty na flutter vývojáře v Seznamu. Jde o velmi malý projekt určený pro otestování základních dovedností. Projekt je navržen tak, aby byl zpracovatelný pro úrovně od mediora po seniora, vypracujte jej dle vlastních schopností. Není očekáváno, že každý zvládne vše na 100%.

## Popis

Vytvořte repozitář na [GitHubu](https://github.com/) s Flutter aplikací pracující s [Studio Ghibli API](https://ghibliapi.vercel.app). Na tomto úkolu demonstrujte dobrou práci s Rest Api, Dartem a Flutterem. Primárně je třeba vypracovat **povinné zadání** a až poté doporučuji pracovat na bonusových bodech. Bonusové body nejsou povinné, ovšem mohou významně pomoci vaší šanci. Úkol lze pojmout jednoduše a vypracovat velmi rychle, zároveň je možné na něm prokázat porozumění architektuře a design patternům. Jak řešení, tak architekturu vyberte vhodně vůči projektu, ovšem zamyslete se i nad teoretickým rozšířením ("nestavíme elektrárnu, ale pořád hledáme kód, který má strukturu"). Tento úkol bude velmi pravděpodobně součástí dalšího kola výběrového řízení a proto důrazně doporučujeme vypracovat jej samostatně. Tento úkol se primárně zaměřuje a hodnotí kvalitu kódu, pochopení softwarových principů a Flutteru jako takového, ale za příjemný design a především za dobře uchopene UX získáte bonusové body.

## Povinné zadání

Vytvořte mobilní aplikaci fungující jako filmová galerie studia Ghibli. Použití již existujícího Dart klienta je zakázáno.

### Požadavky

- Obrazovka umožňující procházet jednotlivé filmy ve stylu filmové galerie (styl streamovacích služeb) `https://ghibliapi.vercel.app/films`
- Obrazovka s detailem filmu
- Možnost film označit jako oblíbený a přidat k němu své hodnocení (1-5 hvězd)
- Obrazovka umožňující procházet oblíbené filmy a filtrování mezi nimi podle hodnocení
- V detailu je povinné uživateli zobrazit v nějaké formě všechny parametry filmu a to včetně namapovaní všech `people`, `species`, `locations` a `vehicles`

### Poznámky a tipy

- Zamyslete se nad vhodným řešením stavu - pro tento úkol bychom rádi viděli demonstraci pouze z jednoho z následujících řešení a proto akceptujeme pouze ty: [Riverpod](https://pub.dev/packages/riverpod), [Signals](https://pub.dev/packages/signals), built-in nástroje flutteru
- Oblíbené a hodnocení musí být persistentně a musí být vidět vše, kde dává smysl (výpis, detail, oblibené).
- Pokud chcete použít animace tak doporučujeme knihovny: [Flutter Animate](https://pub.dev/packages/flutter_animate) a [Cue](https://pub.dev/packages/cue)
- Co se knihoven týka méně je více. Dobrý developer ví, že není třeba znovu vynalézt kolo, ale zároveň také fakt, že všechen kód, který přimo nespravujete je potenciální riziko.
- Dependency Injection preferujeme oproti service locatorum. Akceptovatelné je ale oboje i kombinace (očekávejte, že bude diskutováno).
- Zamyslete se nejen nad samotnou architekturou, ale rovněž i nad strukturou projektu (hloubka složek by něměla být nesmyslně vysoká). Kromě větší přehlednosti, tím uděláte i radost kontrolujícím, jelikož se v projektu rychleji zorientují :)

## Bonusové body

- Animace jakékoliv formy (implicitní, explicitní, [Rive](https://pub.dev/packages/rive), [Lottie](https://pub.dev/packages/lottie),...)
- Použití interceptorů (například logování komunikace)
- Github actions s jednoduchym flow. Doporučujeme customizované [very_good_workflows](https://github.com/VeryGoodOpenSource/very_good_workflows) od Very good ventures, ale úplně custom řešení je samozřejmě také akceptováno.
- Cokoliv dalšího, co vás napadne a chcete ukázat

## Výstup

Výstupem by měl být Github repozitář, obsahující kód a **README.MD s instrukcemi pro spuštění aplikace**. Nezapomeňte uvést všechny potřebné kroky (například v případě použití generování souborů). README by také měl obsahovat stručný popis všeho, co jste použili a to zejména všeho nad rámec zadání. Formalita ani rozsah Readme není relevantní, ale snažte se obsáhnout vše a pokud možno stručně (Aby se to lépe kontrolovalo). Veškeré postřehy a komentáře můžete rovněž uvést do README. Pokud jste některé kroky nesplňili nebo některé částí vědomě udělali neoptimálně, rovněž je uveďte do README pro kontext.
