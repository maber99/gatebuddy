# Dichte-Abschaetzung: gleichzeitig anwesende Passagiere airside und noetige App-Nutzung
airports = {"ZRH": 32_593_966, "MUC": 43_400_000}
op_hours = 18           # Annahme: Betriebsstunden pro Tag mit relevantem Verkehr
dwell_opts = [0.75, 1.0, 1.5]  # Annahme: freie Zeit airside in Stunden
target_visible = [5, 10, 20]   # gewuenschte gleichzeitig sichtbare, offene Nutzer
for ap, pax in airports.items():
    dep_day = pax/2/365        # grob: Haelfte der gezaehlten Passagiere sind Abfluege
    print(f"\n{ap}: {pax:,} Pax/Jahr -> ca. {dep_day:,.0f} Abfluege/Tag")
    for d in dwell_opts:
        conc = dep_day*d/op_hours
        line = f"  Verweildauer {d:.2f} h -> Ø {conc:,.0f} gleichzeitig airside"
        for t in target_visible:
            line += f" | {t} sichtbar = {t/conc*100:.2f}% aller Anwesenden"
        print(line)
    # Wie viele aktive Trip-Sessions/Jahr bei 0.5% bzw 1% aktiver Nutzung je Abflug
    for share in (0.005, 0.01):
        sessions = pax/2*share
        print(f"  {share*100:.1f}% der Abfluege mit aktiver Nutzung = {sessions:,.0f} Trip-Sessions/Jahr"
              f" = ca. {sessions/8:,.0f} Nutzer bei 8 Abfluegen/Jahr/Nutzer")
