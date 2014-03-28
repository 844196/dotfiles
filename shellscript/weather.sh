#!/bin/sh

unit=( '°C' 'm' )

weather=(`curl "http://api.openweathermap.org/data/2.5/weather?q=${LOCATION},jp&units=metric&lang=en" 2>/dev/null | jq -r '.weather[].icon, .main.temp, .wind.speed'`)

case ${weather[0]} in
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
temp=`echo ${weather[1]} | awk '{printf("%d",$1+0.5)}'`${unit[0]}
wind='⚐'`echo ${weather[2]} | awk '{printf("%d",$1+0.5)}'`${unit[1]}

echo "${sign}\n${temp}\n${wind}">${TMP}/weather
