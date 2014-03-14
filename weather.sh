#/bin/sh
cityname='Monbetsu'
unit="°C"

get=$(curl http://api.openweathermap.org/data/2.5/weather?q=$cityname,jp\&units=metric\&lang=en 2>/dev/null | jq '.name, .weather[].icon, .main.temp, .main.temp_max, .main.temp_min, .wind.speed')

IFS='\
    '
set -- $get

location=$(echo $1 | sed -e 's/"//g')
cond=$(echo $2 | sed -e 's/"//g')
wind="⚐"$6"m"

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

echo "$location\n$sign\n$3$unit\n$4$unit\n$5$unit\n$wind">$HOME/.weather
