#/bin/sh
get=$(curl http://www.accuweather.com/ja/jp/asahikawa-shi/223986/weather-forecast/223986 2> /dev/null | grep -e 'span\ class="cond"' | sed -e 's//\\n/g' | head -n1 | sed -e 's/<[^>]*>//g' | sed -e 's/\ //')

IFS=' '
set -- $get

case $1 in
    *晴れ)   sign='☀ ';;
    *曇り)   sign='☁ ';;
    *雨)   sign='☂ ';;
    *雪)   sign='☃ ';;
esac

temp=$(echo $2 | sed -e 's/&deg;//g')

printf "$sign $temp"°C"" > $HOME/.weather
