_convert = function(text) {
    var i, line, lines, result, t, time, user, comment, file, out;

    result = "<ul class=\"ul-chat\">\n";
    lines = text.split("\n");
    i = 0;

    while (i < lines.length) {
        line = lines[i];
        if (line === "") {
            ++i;
            continue;
        };

        var skypeReg = new RegExp(/^\[([\d+\/?]+)\s([\d+:?]+)\]\s(.+?):\s(.*)$/);
        var skypeFileReg = new RegExp(/^\[([\d+\/?]+)\s([\d+:?]+)\]\s(.+?)\sファイル(.+?\.[A-Za-z]+).*$/);
        var minecraft1Reg = new RegExp(/^\[([\d+:?]+)\]\s<(.+?)>\s(.*)$/);
        var minecraft2Reg = new RegExp(/^\[([\d+:?]+)\]\s\[.+?\]\s\[.+?\]\s(.+?):\s(.*)$/);
        var minecraftWebReg = new RegExp(/^\[([\d+:?]+)\]\s\[WEB\]\s(.+?):\s(.*)$/);
        var minecraftSystemLogReg = new RegExp(/^\[([\d+:?]+)\]\s(.+?)\s(.+?\sthe\sGame\s.*)$/);

        if ( minecraft1Reg.test(line) ) {
            time = line.replace(minecraft1Reg, "$1");
            user = line.replace(minecraft1Reg, "$2");
            comment = line.replace(minecraft1Reg, "$3");

        } else if ( minecraft2Reg.test(line) ) {
            time = line.replace(minecraft2Reg, "$1");
            user = line.replace(minecraft2Reg, "$2");
            comment = line.replace(minecraft2Reg, "$3");

        } else if ( minecraftWebReg.test(line) ) {
            time = line.replace(minecraftWebReg, "$1");
            user = '[WEB] ' + line.replace(minecraftWebReg, "$2");
            comment = line.replace(minecraftWebReg, "$3");

        } else if ( minecraftSystemLogReg.test(line) ) {
            time = line.replace(minecraftSystemLogReg, "$1");
            user = line.replace(minecraftSystemLogReg, "$2");
            comment = line.replace(minecraftSystemLogReg, "$3");

        } else if ( skypeFileReg.test(line) ) {
            time = line.replace(skypeFileReg, "$2");
            user = line.replace(skypeFileReg, "$3");
            file = line.replace(skypeFileReg, "$4");
            comment = '\<code\>' + file + '\<\/code\>' + 'を送信しました';

        } else if ( skypeReg.test(line) ) {
            time = line.replace(skypeReg, "$2");
            user = line.replace(skypeReg, "$3");
            comment = line.replace(skypeReg, "$4");

        };

        if (i % 2 === 0) {
            var guuki = 'odd';
        } else {
            var guuki = 'even';
        };


        if ( minecraftSystemLogReg.test(line) ) {
            out = "\t" + '<li class="' + guuki + '">' + '<span class="label">' + user + ' ' + '</span>' + comment + '</li>';
        } else {
            out = "\t" + '<li class="' + guuki + '">' + '<span class="label">' + user + ': ' + '</span>' + comment + '</li>';
        };

        result += out + "\n";

        i++;
    };

    result += "</ul>"
    return result;
};

return _convert(clipText);
