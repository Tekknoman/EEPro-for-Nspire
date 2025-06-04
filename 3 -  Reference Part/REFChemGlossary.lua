-- Use a widget-enabled screen for widget handling
RefChemGlossary = WScreen()

RefChemGlossary.search = sInput()
RefChemGlossary.search.placeholder = "Search"
-- ensure typed text shows in black
RefChemGlossary.search.textcolor = {0,0,0}
-- widen the box so entered text is visible
RefChemGlossary.search.ww = -10
RefChemGlossary.list = sList()
RefChemGlossary.filtered = {}

-- slightly lower placement so text doesn't collide with title
RefChemGlossary:appendWidget(RefChemGlossary.search, 5, 25)
RefChemGlossary:appendWidget(RefChemGlossary.list, 5, 50)
RefChemGlossary.list:setSize(-10, -40)

local function wrapText(text, width)
    local lines = {}
    platform.withGC(function(gc)
        local current = ""
        for word in text:gmatch("%S+") do
            local candidate = current=="" and word or (current .. " " .. word)
            if gc:getStringWidth(candidate) > width then
                if current ~= "" then table.insert(lines, current) end
                current = word
            else
                current = candidate
            end
        end
        if current ~= "" then table.insert(lines, current) end
    end)
    return lines
end

function RefChemGlossary.updateList()
    local q = string.lower(RefChemGlossary.search.value or "")
    local items = {}
    RefChemGlossary.filtered = {}
    for _,e in ipairs(RefChemGlossary.entries) do
        local text = string.lower(e.term .. " " .. e.def .. " " .. e.topic)
        if q=="" or string.find(text, q, 1, true) then
            table.insert(items, e.term .. " ["..e.topic.."]")
            table.insert(RefChemGlossary.filtered, e)
        end
    end
    RefChemGlossary.list.items = items
    RefChemGlossary.list.sel = 1
    RefChemGlossary.list.top = 0
end

function RefChemGlossary.search:charIn(ch)
    sInput.charIn(self, ch)
    RefChemGlossary.updateList()
end

function RefChemGlossary.search:backspaceKey()
    sInput.backspaceKey(self)
    RefChemGlossary.updateList()
end

function RefChemGlossary.search:clearKey()
    sInput.clearKey(self)
    RefChemGlossary.updateList()
end

function RefChemGlossary.list:action(idx)
    local e = RefChemGlossary.filtered[idx]
    if not e then return end
    local d = Dialog(e.term, 30, 20, 300, 180)
    local ok = sButton("OK")
    d:appendWidget(ok, -10, -5)
    local lines = wrapText(e.def, d.w - 20)
    for i,line in ipairs(lines) do
        d:appendWidget(sLabel(line), 10, 25 + (i-1)*14)
    end
    function d:postPaint(gc)
        nativeBar(gc, self, self.h-40)
    end
    function ok:action()
        remove_screen(d)
    end
    function d:escapeKey()
        remove_screen(d)
    end
    push_screen_direct(d)
end

function RefChemGlossary:pushed()
    platform.window:setFocus(true)
    RefChemGlossary.search:giveFocus()
    RefChemGlossary.updateList()
end

-- ensure returning from a definition restores focus to the search box
function RefChemGlossary:screenGetFocus()
    platform.window:setFocus(true)
    RefChemGlossary.search:giveFocus()
end

function RefChemGlossary:paint(gc)
    gc:setColorRGB(255,255,255)
    gc:fillRect(self.x, self.y, self.w, self.h)
    gc:setColorRGB(0,0,0)
    gc:setFont("sansserif","b",12)
    gc:drawString("Chemistry Glossary", self.x+5, 0, "top")
end

function RefChemGlossary:escapeKey()
    only_screen_back(Ref)
end

RefChemGlossary.entries = {
    {term="Aggregatzustand", topic="Allgemein", def="Von Druck und Temperatur abhängige Art und Weise, wie die kleinsten Teilchen eines Stoffes angeordnet sind. Die klassischen Aggregatzustände sind fest, flüssig und gasförmig."},
    {term="Aktivierungsenergie", topic="Chemische Reaktionen", def="Energie, die es braucht, um eine chemische Reaktion auszulösen."},
    {term="Aldehyd", topic="Organische Chemie", def="Organische Verbindung, deren Moleküle am Ende einer Kohlenstoffkette eine Carbonylgruppe (-C=O) enthalten. Die Bezeichnungen der Aldehyde enden auf -al."},
    {term="alkalische Lösung", topic="Gemische", def="(auch basische Lösung oder Lauge) Eine wässrige Lösung, die mehr Hydroxidionen (OH–) als Oxoniumionen (H3O+) enthält."},
    {term="Alkane", topic="Organische Chemie", def="Kohlenwasserstoffe, bei denen alle Kohlenstoffatome über Einfachbindungen aneinandergebunden sind. Die Bezeichnungen der Alkane enden auf -an."},
    {term="Alkene", topic="Organische Chemie", def="Kohlenwasserstoffe, bei denen mindestens 2 Kohlenstoffatome mit einer Doppelbindung aneinandergebunden sind. Die Bezeichnungen der Alkene enden auf -en."},
    {term="Alkine", topic="Organische Chemie", def="Kohlenwasserstoffe, bei denen mindestens 2 Kohlenstoffatome mit einer Dreifachbindung aneinandergebunden sind. Die Bezeichnungen der Alkine enden auf -in."},
    {term="Alkohol", topic="Organische Chemie", def="Organische Verbindung, deren Moleküle eine oder mehrere Hydroxylgruppen (-OH) enthalten. Die Bezeichnungen der Alkohole enden auf -ol."},
    {term="Alkylgruppe (= Alkylrest)", topic="Organische Chemie", def="Allgemeine Bezeichnung für eine Kohlenwasserstoffkette als Teil (als Seitenkette) eines grösseren Moleküls."},
    {term="Amin", topic="Organische Chemie", def="Organische Verbindung, deren Moleküle eine Aminogruppe (-NH2) enthalten."},
    {term="Aminogruppe", topic="Organische Chemie", def="Funktionelle Gruppe der Amine (-NH2)."},
    {term="Analyse", topic="Chemische Reaktionen", def="Chemische Reaktion, bei der ein Stoff in kleinere Bausteine, meistens in Elemente, zerlegt wird."},
    {term="Anion", topic="Periodensystem", def="Ein negativ geladenes Ion. In einem elektrisch geladenen Feld, zum Beispiel bei einer Elektrolyse, bewegt es sich zur (positiv geladenen) Anode."},
    {term="Anode", topic="Allgemein", def="In der Chemie ist die Anode die Elektrode (der elektrischer Leiter), an der eine Oxidation stattfindet."},
    {term="Aromaten/aromatische Verbindungen", topic="Organische Chemie", def="Stoffklasse der organischen Verbindungen. Die Aromaten enthalten Kohlenstoffringe, die dem Aufbau des Benzens (C6H6) entsprechen. Der Name stammt vom typischen, intensiven Geruch."},
    {term="Atom", topic="Allgemein", def="Kleinste Einheit der Elemente. Durch chemische Vorgänge können Atome nicht mehr weiter geteilt werden (was der Bezeichnung «Atom» = «nicht teilbar» entspricht)."},
    {term="Atomkern", topic="Allgemein", def="Aus Protonen und meistens auch Neutronen aufgebauter Teil des Atoms. Er hat einen Durchmesser von etwa 10–15 m und enthält praktisch die gesamte Masse des Atoms."},
    {term="Atomrumpf", topic="Allgemein", def="Ein Atom ohne die Elektronen der äussersten Schale."},
    {term="aufrahmen", topic="Gemische", def="Vorgang, bei dem sich die Phase mit der geringeren Dichte durch die Schwer- oder Zentrifugalkraft von der Phase mit der höheren Dichte trennt."},
    {term="Autoprotolyse", topic="Chemische Reaktionen", def="Säure-Base-Reaktion zwischen zwei Wassermolekülen, so dass ein Oxoniumion und ein Hydroxidion entstehen. 2 H2O  →  H3O+ + OH–"},
    {term="Base", topic="Allgemein", def="Ein Stoff aus Teilchen, die mindestens ein nichtbindendes Elektronenpaar besitzen und damit ein Proton anlagern können."},
    {term="basische Lösung", topic="Gemische", def="(Auch alkalische Lösung oder Lauge) Eine wässrige Lösung, die mehr Hydroxidionen (OH–) als Oxoniumionen (H3O+) enthält."},
    {term="bindendes Elektronenpaar", topic="Allgemein", def="Elektronenpaar, das alleine (Einfachbindung), mit einem weiteren (Doppelbindung) oder zwei weiteren Paaren (Dreifachbindung) zwei Atome miteinander verbindet. Die bindenden Elektronenpaare zählen zur äussersten Schale beider Atome und ermöglichen dadurch einen edelgasähnlichen Zustand."},
    {term="Carbonsäure", topic="Organische Chemie", def="Organische Verbindung, deren Moleküle eine oder mehrere Carboxylgruppen (-COOH) enthalten. Carbonsäuren können als Säure wirken."},
    {term="Carbonylgruppe", topic="Organische Chemie", def="Funktionelle Gruppe der Aldehyde und Ketone (-C=O)."},
    {term="Carboxylgruppe (Carboxygruppe)", topic="Organische Chemie", def="Funktionelle Gruppe der Carbonsäuren (-COOH)."},
    {term="Cycloalkane", topic="Organische Chemie", def="Ringförmige Kohlenwasserstoffe (ohne Mehrfachbindungen zwischen Kohlenstoffatomen)."},
    {term="Destillation/destillieren", topic="Gemische", def="Trennverfahren, mit dem Stoffe aufgrund unterschiedlicher Siedetemperatur voneinander getrennt werden."},
    {term="Dichte", topic="Gemische", def="Masse pro Volumen"},
    {term="Dipol", topic="Bindungen", def="Elektrisch neutrale Teilchen, die aufgrund ungleichmässiger Elektronenverteilung einen positiven und einen negativen Pol besitzen."},
    {term="Dipol-Dipol-Wechselwirkung", topic="Bindungen", def="Anziehungskraft zwischen Molekülen, die einen positiven und negativen Pol besitzen."},
    {term="(elektrolytische) Dissoziation", topic="Allgemein", def="Zerfall einer Verbindung in einem Lösungsmittel in Anionen (negativ geladene Ionen) und Kationen (positiv geladene Ionen)."},
    {term="Edelgas", topic="Periodensystem", def="Ein Element der 8. Hauptgruppe des Periodensystems. Edelgase haben eine vollständig mit Elektronen besetzte äusserste Schale (Valenzschale)."},
    {term="edelgasähnlicher Zustand", topic="Allgemein", def="Ein Atom erreicht einen edelgasähnlichen Zustand, wenn in der äussersten Schale gleich viele Elektronen sind, wie beim Edelgas der selben Periode."},
    {term="Edukt", topic="Allgemein", def="Ausgangsstoff für eine chemische Reaktion."},
    {term="elektrische Ladung", topic="Bindungen", def="Eine physikalische Grösse, welche die elektromagnetische Wechselwirkung (Anziehung oder Abstossung) bestimmt."},
    {term="Elektrode", topic="Allgemein", def="Als Elektrode bezeichnet man den Teil eines Stromkreises, an dem der elektrische Strom in ein anderes Medium übergeht. In der Elektrochemie sind die Elektroden leitende Feststoffe (Metalle oder Graphit), die in direktem Kontakt mit einem Elektrolyten stehen."},
    {term="Elektrolyse", topic="Chemische Reaktionen", def="Eine chemische Reaktion, bei der mit elektrischem Strom eine Verbindung in kleinere Moleküle oder Elemente getrennt wird."},
    {term="Elektrolyt", topic="Allgemein", def="Der Elektrolyt ist ein Stoff (oft eine Flüssigkeit), der frei bewegliche Anionen und Kationen enthält und dadurch elektrischen Strom leitet."},
    {term="Elektron", topic="Bindungen", def="Elementarteilchen, das die Hülle der Atome bildet. Die Elektronen sind negativ geladen. Die Chemie beruht im Wesentlichen auf den Eigenschaften und Wechselwirkungen der Elektronen in der Atomhülle."},
    {term="Elektronegativität", topic="Bindungen", def="Mass für die Fähigkeit eines Atoms, in einer Bindung Elektronen zu sich zu ziehen."},
    {term="Elektronengas", topic="Bindungen", def="Modellvorstellung für die frei beweglichen Elektronen zwischen den Atomrümpfen bei einem Metallgitter."},
    {term="Elektronenkonfiguration", topic="Bindungen", def="Verteilung der Elektronen auf die verschiedenen Schalen (oder Aufenthaltsräume) eines Atoms."},
    {term="Elektronenpaarbindung", topic="Bindungen", def="Verbindung zwischen Nichtmetallatomen durch gemeinsame (bindende) Elektronenpaare. Es gibt Einfach-, Doppel- und Dreifachbindungen."},
    {term="Element/Elementarstoff", topic="Periodensystem", def="Ein (reiner) Stoff aus Atomen mit der gleichen Protonenzahl. Mit der allgemeineren Bezeichnung «Element» kann auch ein einzelnes Atom gemeint sein."},
    {term="Elementarladung", topic="Bindungen", def="Die kleinste (mit einem Teilchen verschiebbare) Ladungsmenge. Ein Elektron trägt eine negative Elementarladung, ein Proton eine positive Elementarladung."},
    {term="Emulsion", topic="Gemische", def="Fachbegriff für ein Gemisch aus zwei (oder mehr) flüssigen Phasen."},
    {term="endotherme Reaktion", topic="Chemische Reaktionen", def="Eine chemische Reaktion, die Energie braucht bzw. der Energie zugeführt werden muss."},
    {term="erstarren", topic="Chemische Reaktionen", def="Bezeichnung für den Übergang vom flüssigen in den festen Aggregatszustand."},
    {term="Ester", topic="Organische Chemie", def="Organische Verbindung, deren Moleküle eine Estergruppe (R1-COO-R2) enthalten (R1 und R2 stehen für Alkylgruppen). Ester können als Produkt der Reaktion von einer Säure mit einem Alkohol angesehen werden (Säure + Alkohol  →  Ester + Wasser)."},
    {term="exotherme Reaktion", topic="Chemische Reaktionen", def="Eine chemische Reaktion, bei der Energie frei wird."},
    {term="Extraktion/extrahieren", topic="Gemische", def="Verfahren, bei dem mit einen passenden Lösungsmittel Stoffe aufgrund unterschiedlicher Löslichkeit voneinander getrennt werden."},
    {term="Filtration/filtrieren", topic="Gemische", def="Verfahren, mit dem Teilchen unterschiedlicher Grösse voneinander getrennt werden."},
    {term="freies Elektronenpaar", topic="Bindungen", def="Elektronenpaar in der äussersten Schale eines Atoms, das nicht an einer Bindung beteiligt ist."},
    {term="funktionelle Gruppe", topic="Allgemein", def="Atomgruppen und Mehrfachbindungen in den Molekülen organischer Stoffe. Die funktionellen Gruppen führen zu typischen Eigenschaften («Funktionen»)."},
    {term="Gemisch/Gemenge", topic="Gemische", def="Ein fester Stoff aus sichtbar unterschiedlichen Bestandteilen (evtl. mit einem Lichtmikroskop unterscheidbar)."},
    {term="gesättigte Kohlenwasserstoffe", topic="Organische Chemie", def="(=Alkane) Kohlenwasserstoffe, bei denen alle Kohlenstoffatome über Einfachbindungen aneinandergebunden sind."},
    {term="Gruppe (im Periodensystem)", topic="Periodensystem", def="Eine Spalte im Periodensystem. Die Elemente einer Gruppe haben gleich viele Elektronen auf der äussersten Schale und ähnliche Eigenschaften."},
    {term="Halbmetall", topic="Periodensystem", def="Elemente, die im Periodensystem zwischen den Metallen und Nichtmetallen stehen. Verschiedene Definitionen führen dazu, dass nicht immer die gleichen Elemente zu den Halbmetallen gezählt werden."},
    {term="Halogene", topic="Periodensystem", def="Name der 7. Hauptgruppe des Periodensystems (die Elemente Fluor, Chlor, Brom, Iod, Astat)."},
    {term="heterogen", topic="Allgemein", def="uneinheitlich, aus ungleichem zusammengesetzt"},
    {term="homogen", topic="Allgemein", def="einheitlich oder gleichmässig beschaffen"},
    {term="(Elektronen-) Hülle", topic="Allgemein", def="Äusserer, von Elektronen gebildeter Teil eines Atoms."},
    {term="Hydrid", topic="Allgemein", def="Verbindung eines Elements mit Wasserstoff."},
    {term="Hydroxylgruppe (Hydroxygruppe)", topic="Organische Chemie", def="Funktionelle Gruppe der Alkohole (-OH)."},
    {term="Indikator", topic="Allgemein", def="Säure-Base-Indikatoren sind Farbstoffe, die bei unterschiedlichen pH-Werten unterschiedliche Farben zeigen."},
    {term="Ion", topic="Allgemein", def="Ein elektrisch geladenes Teilchen (wobei das Elektron als Elementarteilchen nicht als Ion bezeichnet wird)."},
    {term="Ionenbindung", topic="Bindungen", def="Chemische Bindung, die auf der Anziehungskraft beruht, die positiv und negativ geladene Ionen aufeinander ausüben."},
    {term="Ionengitter", topic="Bindungen", def="Regelmässige räumliche Anordnung von positiv und negativ geladenen Ionen bei einem homogenen Stoff im festen Zustand."},
    {term="isomer", topic="Allgemein", def="Isomere Moleküle bestehen aus den gleichen Atomen (haben die gleiche Summenformel), die Atome sind aber anders angeordnet (unterschiedliche Lewisformel). Wörtlich bedeutet isomer «aus den gleichen Teilen»."},
    {term="Isotop", topic="Periodensystem", def="Begriff, der eigentlich nur in der Mehrzahl oder als Adjektiv Sinn macht, denn er bezeichnet zwei Atome mit der gleichen Protonenzahl, aber unterschiedlich vielen Neutronen."},
    {term="Katalysator", topic="Allgemein", def="Ein Katalysator ist ein Stoff, der eine chemische Reaktion beschleunigt oder bei tieferer Temperatur ablaufen lässt. Nach der Reaktion liegt der Katalysator unverändert vor."},
    {term="Kathode", topic="Allgemein", def="In der Chemie ist die Kathode die Elektrode, an der eine Reduktion stattfindet."},
    {term="Kation", topic="Periodensystem", def="Ein positiv geladenes Ion."},
    {term="Kernladungszahl", topic="Periodensystem", def="Auch Ordnungszahl oder Protonenzahl im Kern eines Atoms."},
    {term="Keton", topic="Organische Chemie", def="Organische Verbindung, deren Moleküle ein Kohlenstoffatom enthalten, an das ein Sauerstoffatom mit einer Doppelbindung (eine Carbonylgruppe) und zwei weitere Kohlenstoffatome gebunden sind."},
    {term="Kohlenwasserstoffe", topic="Organische Chemie", def="Chemische Verbindungen, die nur aus Kohlenstoff- und Wasserstoffatomen aufgebaut sind."},
    {term="kondensieren", topic="Allgemein", def="Bezeichnung für den Übergang vom gasförmigen in den flüssigen Aggregatszustand."},
    {term="korrespondierende Base", topic="Chemische Reaktionen", def="(auch konjugierte Base) Jede Säure wird durch die Abgabe eines Protons zu einer Base. Wenn ein Säureteilchen ein Proton abgibt, entsteht daraus die zu dieser Säure korrespondierende Base."},
    {term="korrespondierende Säure", topic="Chemische Reaktionen", def="(auch konjugierte Säure) Jede Base wird durch die Aufnahme eines Protons zu einer Säure. Wenn ein Baseteilchen ein Proton aufnimmt, entsteht daraus die zu dieser Base korrespondierende Säure."},
    {term="Lauge", topic="Gemische", def="Eine alkalische (=basische) Lösung."},
    {term="Legierung", topic="Gemische", def="Homogenes metallartiges Gemisch, bei dem mindestens ein Bestandteil ein Metall ist."},
    {term="Lewisformel", topic="Allgemein", def="Chemische Formel, mit der die Struktur eines Moleküls dargestellt wird."},
    {term="Logarithmus", topic="Allgemein", def="Exponent zu einer festgelegten Basis, um eine gegebene Zahl zu erhalten. Bsp. 100 = 102    →   log10(100) = 2"},
    {term="Lösung", topic="Gemische", def="Ein homogenes, in der Regel flüssiges Gemisch."},
    {term="Masse", topic="Allgemein", def="Eine der physikalischen Basisgrössen. Wird in Kilogramm gemessen. (Die Relativitätstheorie macht es schwierig, eine allgemeine Definition des Begriffs «Masse» zu formulieren.)"},
    {term="Massenzahl", topic="Allgemein", def="Summe aus Protonen- und Neutronenzahl"},
    {term="Metall", topic="Periodensystem", def="Stoffe, die gut elektrischen Strom und Wärme leiten, verformbar sind und oft einen typischen Spiegelglanz haben. Die Mehrheit der Elemente gehört zu den Metallen."},
    {term="Modell", topic="Allgemein", def="Ein (vereinfachtes) Bild oder eine (vereinfachte) Vorstellung der Wirklichkeit."},
    {term="Mol", topic="Allgemein", def="Das Mol ist die Masseinheit der Stoffmenge. Sie dient der Mengenangabe bei chemischen Reaktionen. 1 mol = 6.022 140 76 · 1023 Stk. ≈ 6.02 · 1023 Stk."},
    {term="molare Masse", topic="Allgemein", def="Angabe in g/mol, die für die Elemente im Periodensystem direkt abgelesen werden kann."},
    {term="Molekül", topic="Allgemein", def="Elektrisch neutrale Teilchen aus zwei oder mehr aneinandergebundenen Atomen. Da ein Molekül aus einer bestimmten, zählbaren Anzahl Atomen besteht, wird es mit einer Summenformel beschrieben."},
    {term="Molekül-Ion", topic="Gemische", def="Bausteine der Salze aus negativ oder positiv geladenen Molekülen"},
    {term="Nebel", topic="Gemische", def="Heterogenes Gemisch von Flüssigkeitströpfchen in einer gasförmigen Phase."},
    {term="Neutralisation", topic="Chemische Reaktionen", def="Eine saure und eine basische Lösung werden zusammengegeben, so dass durch eine chemische Reaktion Wasser und ein Salz entstehen."},
    {term="Neutron", topic="Allgemein", def="Ein Baustein der Atome. Es ist elektrisch neutral und neben den Protonen in den allermeisten Atomkernen zu finden."},
    {term="nichtbindendes Elektronenpaar", topic="Bindungen", def="Ein Elektronenpaar auf der äussersten Schale eines Atoms, das keine Bindung zu einem anderen Atom herstellt."},
    {term="Nichtmetall", topic="Periodensystem", def="Elemente, denen die typischen metallischen Eigenschaften fehlen."},
    {term="Nitrid", topic="Allgemein", def="Verbindung eines Elements mit Stickstoff."},
    {term="Nuklid", topic="Periodensystem", def="Atom mit einer bestimmten (angegebenen) Protonen- und Neutronenzahl."},
    {term="Ordnungszahl", topic="Periodensystem", def="Anzahl der Protonen im Kern eines Atoms."},
    {term="organische Chemie", topic="Organische Chemie", def="Chemie der Kohlenstoffverbindungen (mit ein paar wenigen Ausnahmen)."},
    {term="Oxid", topic="Allgemein", def="Verbindung eines Elements mit Sauerstoff."},
    {term="Oxidation", topic="Chemische Reaktionen", def="Abgabe von Elektronen."},
    {term="Oxidationsmittel", topic="Chemische Reaktionen", def="Atome, Ionen oder Verbindungen, die eine Oxidation ermöglichen und dabei selbst reduziert werden, also Elektronen aufnehmen."},
    {term="Periode (im Periodensystem)", topic="Periodensystem", def="Zeile im Periodensystem mit den Elementen, die gleich viele Schalen in der Elektronenhülle haben."},
    {term="Periodensystem", topic="Periodensystem", def="Tabellarische Zusammenstellung aller chemischen Elemente, so dass Elemente mit ähnlichen Eigenschaften untereinanderstehen. Ordnet man die Elemente nach der Anzahl Protonen im Kern, so wiederholen sich viele Eigenschaften periodisch."},
    {term="Phase", topic="Allgemein", def="Der optisch einheitliche Teil eines Stoffes oder Stoffgemisches."},
    {term="pH-Wert", topic="Allgemein", def="Negativer Zehnerlogarithmus der Oxoniumionenkonzentration in Wasser oder einer wässrigen Lösung."},
    {term="polare Bindung", topic="Bindungen", def="Eine Elektronenpaarbindung zwischen zwei Atomen mit unterschiedlicher Elektronegativität."},
    {term="Polymer", topic="Organische Chemie", def="Als Polymer bezeichnet man grosse Moleküle, die durch Verbindung vieler (gleicher) Atomgruppen entstehen. Wörtlich bedeutet polymer «aus vielen Teilen». Typische Beispiele sind Kunststoffe wie Polyethen (Polyethylen) oder Cellulose (ein Polysaccharid oder Vielfachzucker)."},
    {term="Produkt", topic="Allgemein", def="Stoff, der bei einer chemischen Reaktion entsteht bzw. entstanden ist."},
    {term="Protolyse", topic="Chemische Reaktionen", def="Fachbegriff für eine Reaktion, bei der Protonen übertragen werden (Säure-Base-Reaktion)."},
    {term="Proton", topic="Allgemein", def="Ein Baustein der Atome. Es ist positiv geladen und bildet mit den Neutronen den Kern der Atome."},
    {term="Radioaktivität/radioaktiver Zerfall", topic="Allgemein", def="Die Eigenschaft instabiler Atomkerne, ionisierende Strahlung auszusenden (Strahlen mit genügend Energie, um Elektronen aus einer Atomhülle zu entfernen)."},
    {term="Rauch", topic="Gemische", def="Heterogenes Gemisch mit einer festen und einer gasförmigen Phase."},
    {term="(chemische) Reaktion", topic="Chemische Reaktionen", def="Ein Vorgang, bei dem Atome anders aneinandergebunden werden und dadurch neue Stoffe entstehen."},
    {term="Reaktionsgeschwindigkeit", topic="Chemische Reaktionen", def="Anzahl Teilchen, die pro Zeiteinheit reagieren."},
    {term="Reaktionsgleichung", topic="Chemische Reaktionen", def="Beschreibung einer chemischen Reaktion"},
    {term="Redoxreaktion", topic="Chemische Reaktionen", def="Eine chemische Reaktion, bei der Elektronen übertragen werden."},
    {term="Reduktionsmittel", topic="Chemische Reaktionen", def="Atome, Ionen oder Verbindungen, die eine Reduktion ermöglichen und dabei selbst oxidiert werden, also Elektronen abgeben."},
    {term="Reinstoff/reiner Stoff", topic="Allgemein", def="Ein Stoff, der nur aus einer chemischen Verbindung oder einem Element aufgebaut ist. In der Praxis enthalten allerdings alle Stoffe «Verunreinigungen»."},
    {term="resublimieren", topic="Chemische Reaktionen", def="Bezeichnung für den direkten Übergang vom gasförmigen in den festen Aggregatszustand."},
    {term="RGT-Regel", topic="Chemische Reaktionen", def="Reaktionsgeschwindigkeits-Temperaturregel; Faustregel, die sagt, dass eine chemische Reaktion etwa doppelt so schnell abläuft, wenn die Temperatur 10° höher ist."},
    {term="Salz", topic="Allgemein", def="Verbindung, die aus Ionen aufgebaut ist."},
    {term="saure Lösung", topic="Gemische", def="Eine wässrige Lösung, die mehr Oxoniumionen (H3O+) als Hydroxidionen (OH–) enthält."},
    {term="Säure", topic="Allgemein", def="Ein Stoff aus Teilchen, die Protonen abgeben können."},
    {term="Säure-Base-Paar", topic="Allgemein", def="Schreibweise für einen Stoff, der an einer Säure-Base-Reaktion beteiligt ist. Einmal wird ein Teilchen des Stoffes als Säure (mit dem Proton, das übertragen wird), einmal als Base (ohne Proton) geschrieben."},
    {term="Säure-Base-Reihe", topic="Allgemein", def="Eine nach Säurestärke geordnete Liste von Säure-Base-Paaren. Je stärker eine Säure, desto schwächer ist die korrespondierende Base und umgekehrt."},
    {term="Säurestärke (Stärke einer Säure)", topic="Allgemein", def="Ein Mass dafür, wie einfach eine Säure Protonen abgibt. Damit die Stärke von Säuren verglichen werden kann, wird in der Regel gemessen, wie viele Säureteilchen mit Wassermolekülen reagieren."},
    {term="(Elektronen-) Schale", topic="Allgemein", def="Eine Schale ist im Schalenmodell der Atomphysik ein Aufenthaltsbereich von Elektronen, die ähnlich stark an den Atomkern gebunden sind."},
    {term="Schaum", topic="Gemische", def="Heterogenes Gemisch, bei dem Gasblasen von flüssigen oder seltener festen Wänden umschlossen sind."},
    {term="schmelzen", topic="Chemische Reaktionen", def="Bezeichnung für den Übergang vom festen in den flüssigen Aggregatszustand."},
    {term="Schmelzpunkt", topic="Allgemein", def="Temperatur, bei der ein Stoff vom festen in den flüssigen Zustand übergeht (meistens haben nur grosse Druckunterschiede einen Einfluss auf den Schmelzpunkt)."},
    {term="Sedimentation/sedimentieren", topic="Gemische", def="Vorgang, bei dem Phasen mit unterschiedlicher Dichte voneinander getrennt werden. Meistens sinken fest Teilchen in einem Gas oder einer Flüssigkeit durch die Schwerkraft nach unten."},
    {term="Siedepunkt", topic="Allgemein", def="Wertepaar aus Temperatur und Druck, bei dem ein reiner Stoff vom flüssigen in den gasförmigen Aggregatzustand übergeht."},
    {term="Stoffmenge", topic="Allgemein", def="Die Stoffmenge ist eine Basisgrösse im internationalen Einheitensystem (SI). Über die Einheit «Mol» gibt sie indirekt an, aus wie vielen Teilchen eine Stoffportion besteht."},
    {term="Stoffmengenkonzentration", topic="Allgemein", def="Angabe zur Zusammensetzung einer Lösung. Sie gibt die Stoffmenge pro Volumen der Lösung an."},
    {term="Strukturformel", topic="Allgemein", def="Allgemein eine chemische Formel, mit der die Struktur eines Moleküls dargestellt wird. Meistens ist eine Lewis-Formel gemeint."},
    {term="sublimieren", topic="Chemische Reaktionen", def="Bezeichnung für den direkten Übergang vom festen in den gasförmigen Aggregatszustand."},
    {term="Sulfid", topic="Allgemein", def="Verbindung eines Elements mit Schwefel."},
    {term="Summenformel", topic="Allgemein", def="Chemische Formel die angibt, aus welchen Atomen ein Molekül aufgebaut ist."},
    {term="Suspension", topic="Gemische", def="Heterogenes Gemisch mit einer festen und einer flüssigen Phase."},
    {term="Synthese", topic="Chemische Reaktionen", def="Chemische Reaktion zum Aufbau eines Stoffes."},
    {term="Trivialname", topic="Allgemein", def="Im Gegensatz zu systematischen Namen beruhen Trivialnamen nicht (oder nur teilweise) auf Regeln und dem Aufbau der Stoffe aus den Atomen."},
    {term="ungesättigte Kohlenwasserstoffe", topic="Organische Chemie", def="Kohlenwasserstoffe, bei denen Kohlenstoffatome über Doppel- oder Dreifachbindungen aneinandergebunden sind (Alkene und Alkine)"},
    {term="Valenzelektronen", topic="Allgemein", def="Bezeichnung für die Elektronen auf der äussersten Schale eines Atoms."},
    {term="van der Waals-Kräfte", topic="Bindungen", def="Anziehungskraft zwischen Molekülen oder Edelgasatomen aufgrund kurzzeitiger asymmetrischer Verteilung der Elektronen."},
    {term="Verbindung", topic="Allgemein", def="Reine Stoffe, in denen mehrere Elemente in einem konstanten Verhältnis «aneinander­gebunden» sind."},
    {term="verdampfen/verdunsten", topic="Chemische Reaktionen", def="Bezeichnung für den Übergang vom flüssigen in den gasförmigen Aggregatszustand."},
    {term="Verhältnisformel", topic="Bindungen", def="Chemische Formel, die für eine Verbindung das Verhältnis der Atome zueinander angibt. Da es bei Salzen keine kleinsten Stoffeinheiten (wie Moleküle) gibt, werden Salze über das konstante Verhältnis der Ionen beschrieben, aus denen sie aufgebaut sind."},
    {term="Wasserstoffbrücke", topic="Bindungen", def="Eine besonders starke Dipol-Dipol-Wechselwirkung, die zwischen Sauerstoff-, Stickstoff- oder Fluoratomen und den daran gebundenen Wasserstoffatomen auftritt."},
    {term="Zerfallsreihe/Zerfallskette", topic="Allgemein", def="Abfolge der Produkte (Nuklide), die durch radioaktiven Zerfall entstehen."},
    -- einfache Übersicht organischer Moleküle
    {term="CH4", topic="Organische Chemie", def="Methan, Schmelzpunkt –184°C, Siedepunkt –164°C, gasförmig bei 20 °C."},
    {term="C2H6", topic="Organische Chemie", def="Ethan, Schmelzpunkt –172°C, Siedepunkt –89°C, gasförmig bei 20 °C."},
    {term="C3H8", topic="Organische Chemie", def="Propan, Schmelzpunkt –190°C, Siedepunkt –42°C, gasförmig bei 20 °C."},
    {term="C4H10", topic="Organische Chemie", def="Butan, Schmelzpunkt –135°C, Siedepunkt –0,5°C, gasförmig bei 20 °C."},
    {term="C5H12", topic="Organische Chemie", def="Pentan, Schmelzpunkt –129°C, Siedepunkt 36°C, flüssig bei 20 °C."},
    {term="C6H14", topic="Organische Chemie", def="Hexan, Schmelzpunkt –94°C, Siedepunkt 69°C, flüssig bei 20 °C."},
    {term="C7H16", topic="Organische Chemie", def="Heptan, Schmelzpunkt –90°C, Siedepunkt 98°C, flüssig bei 20 °C."},
    {term="C8H18", topic="Organische Chemie", def="Octan, Schmelzpunkt –59°C, Siedepunkt 126°C, flüssig bei 20 °C."},
    {term="C9H20", topic="Organische Chemie", def="Nonan, Schmelzpunkt –54°C, Siedepunkt 151°C, flüssig bei 20 °C."},
    {term="C10H22", topic="Organische Chemie", def="Decan, Schmelzpunkt –30°C, Siedepunkt 174°C, flüssig bei 20 °C."},
    {term="C11H24", topic="Organische Chemie", def="Undecan, Schmelzpunkt –26°C, Siedepunkt 196°C, flüssig bei 20 °C."},
    {term="C12H26", topic="Organische Chemie", def="Dodecan, Schmelzpunkt –10°C, Siedepunkt 216°C, flüssig bei 20 °C."},
    {term="C13H28", topic="Organische Chemie", def="Tridecan, Schmelzpunkt –6°C, Siedepunkt 230°C, flüssig bei 20 °C."},
    {term="C14H30", topic="Organische Chemie", def="Tetradecan, Schmelzpunkt 5.5°C, Siedepunkt 251°C, flüssig bei 20 °C."},
    {term="C15H32", topic="Organische Chemie", def="Pentadecan, Schmelzpunkt 10°C, Siedepunkt 268°C, flüssig bei 20 °C."},
    {term="C16H34", topic="Organische Chemie", def="Hexadecan, Schmelzpunkt 18°C, Siedepunkt 280°C, flüssig bei 20 °C."},
    {term="C17H36", topic="Organische Chemie", def="Heptadecan, Schmelzpunkt 22°C, Siedepunkt 303°C, fest bei 20 °C."},
}

-- populate the list once entries are loaded so the
-- glossary isn't empty when first opened
RefChemGlossary.updateList()
