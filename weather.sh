#!/bin/sh
cityname='Monbetsu'
appid='153937e5a40ad0ee0fb19d31b18bc7ad'

unit=( '°C' 'm' )
LF=$(printf '\\\\012')

get=$(curl "http://api.openweathermap.org/data/2.5/weather?q=${cityname},jp&units=metric&lang=en&APPID=${appid}" 2>/dev/null | sed -e 's/,/'"$LF"'/g' -e 's/"//g' -e 's/{//g' -e 's/}//g' -e 's/\[//g' -e 's/\]//g')

location=$(echo $get | grep -e 'name:' | sed -e 's/name://')
temp=$(echo $get | grep -e 'main:temp:' | sed -e 's/main:temp://' | awk '{printf("%0.1f", $1)}')${unit[0]}
tempmax=$(echo $get | grep -e 'temp_max:' | sed -e 's/temp_max://' | awk '{printf("%0.1f", $1)}')${unit[0]}
tempmin=$(echo $get | grep -e 'temp_min:' | sed -e 's/temp_min://' | awk '{printf("%0.1f", $1)}')${unit[0]}
wind='⚐'$(echo $get | grep -e 'wind:speed:' | sed -e 's/wind:speed://')${unit[1]}

cond=$(echo $get | grep -e 'icon:' | sed -e 's/icon://')
case $cond in
    '01d'|'01n'|'02d'|'02n')
        sign='☀ ';;
    '03d'|'03n'|'04d'|'04n')
        sign='☁ ';;
    '09d'|'09n'|'10d'|'10n'|'11d'|'11n')
        sige='☂ ';;
    '13d'|'13n')
        sign='☃ ';;
    '50d'|'50n')
        sign='〰';;
    *)
        sign='?';;
esac

echo "$location\n$sign\n$temp\n$tempmax\n$tempmin\n${wind}" >$HOME/.weather
