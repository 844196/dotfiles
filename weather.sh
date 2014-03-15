#!/bin/sh
cityname='Monbetsu'

unit='°C'
LF=$(printf '\\\\012')

get=$(curl "http://api.openweathermap.org/data/2.5/weather?q=$cityname,jp&units=metric&lang=en" 2>/dev/null | sed -e 's/,/'"$LF"'/g' -e 's/"//g' -e 's/{//g' -e 's/}//g' -e 's/\[//g' -e 's/\]//g')

location=`echo $get | grep -e 'name:' | sed -e 's/name://'`
temp=`echo $get | grep -e 'main:temp:' | sed -e 's/main:temp://'`
tempmax=`echo $get | grep -e 'temp_max:' | sed -e 's/temp_max://'`
tempmin=`echo $get | grep -e 'temp_min:' | sed -e 's/temp_min://'`
wind=`echo $get | grep -e 'wind:speed:' | sed -e 's/wind:speed://'`

cond=`echo $get | grep -e 'icon:' | sed -e 's/icon://'`
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

echo "$location\n$sign\n$temp$unit\n$tempmax$unit\n$tempmin$unit\n⚐${wind}m" >$HOME/.weather
