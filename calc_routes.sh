#!/bin/bash
# Percorsi stradali reali (OSRM) — itinerario 24 giorni v3 (rotta ottimizzata, no giri dell'oca)
cd /Users/manuelemerli/viaggio-spagna
legs=(
"t|2.1734,41.3851;1.2590,41.1150;-0.3760,39.4750|3"
"c|-0.3760,39.4750;0.2050,38.7370|5"
"c|0.2050,38.7370;-0.7200,37.6000|6"
"c|-0.7200,37.6000;-2.1070,36.7600|6"
"r|-2.1070,36.7600;-2.1650,36.7320|7"
"r|-2.1070,36.7600;-1.9341,36.9406|8"
"c|-2.1070,36.7600;-2.4220,36.9870|9"
"c|-2.4220,36.9870;-3.1390,37.2990|9"
"c|-3.1390,37.2990;-3.5880,37.1760|9"
"c|-3.5880,37.1760;-3.3580,36.9610|11"
"c|-3.3580,36.9610;-3.8950,36.7890|12"
"c|-3.8950,36.7890;-4.4210,36.7210|12"
"c|-4.4210,36.7210;-4.8860,36.5100;-5.1670,36.7420|13"
"c|-5.1670,36.7420;-5.1810,36.8640;-4.7890,36.9320;-4.7790,37.8790|14"
"c|-4.7790,37.8790;-6.4860,37.1310|16"
"c|-6.4860,37.1310;-6.3530,36.7780;-6.1260,36.6850|17"
"c|-6.1260,36.6850;-5.6040,36.0130|18"
"r|-5.6040,36.0130;-5.7740,36.0890|19"
"c|-5.6040,36.0130;-6.0880,36.2770;-5.9650,36.2520;-6.2930,36.5290|20"
"c|-6.2930,36.5290;-6.0450,37.4440;-5.9900,37.3930|22"
)
echo -n "[" > routes.json
first=1
for l in "${legs[@]}"; do
  IFS='|' read -r flag coords day <<< "$l"
  resp=$(curl -s --max-time 20 "https://router.project-osrm.org/route/v1/driving/${coords}?overview=simplified&geometries=geojson")
  row=$(echo "$resp" | /usr/bin/python3 -c "
import sys, json
try:
    r = json.load(sys.stdin)['routes'][0]
    g = [[round(c[1],4), round(c[0],4)] for c in r['geometry']['coordinates']]
    print(json.dumps({'f':'$flag','d':$day,'km':round(r['distance']/1000),'min':round(r['duration']/60),'g':g}, separators=(',',':')))
except Exception as e:
    print('ERROR', e, file=sys.stderr); sys.exit(1)
")
  if [ -z "$row" ]; then echo "LEG FAILED: $coords" >&2; exit 1; fi
  if [ $first -eq 0 ]; then echo -n "," >> routes.json; fi
  first=0
  echo -n "$row" >> routes.json
  sleep 0.4
done
echo "]" >> routes.json
echo "OK: $(wc -c < routes.json) bytes"
