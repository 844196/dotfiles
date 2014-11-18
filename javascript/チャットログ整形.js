var _regexp, _convert;

_regexp = function(chat) {
    var time, user, file, comment, out;
    var skypeReg = new RegExp(/^\[([\d+\/?]+)\s([\d+:?]+)\]\s(.+?):\s(.*)$/);
    var skypeFileReg = new RegExp(/^\[([\d+\/?]+)\s([\d+:?]+)\]\s(.+?)\sファイル(.+?\.[A-Za-z]+).*$/);
    var minecraft1Reg = new RegExp(/^\[([\d+:?]+)\]\s<(.+?)>\s(.*)$/);
    var minecraft2Reg = new RegExp(/^\[([\d+:?]+)\]\s\[.+?\]\s\[.+?\]\s(.+?):\s(.*)$/);
    var minecraftWebReg = new RegExp(/^\[([\d+:?]+)\]\s\[WEB\]\s(.+?):\s(.*)$/);
    var minecraftSystemLogReg = new RegExp(/^\[([\d+:?]+)\]\s(.+?)\s(.+?\sthe\sGame\s.*)$/);

    if ( minecraft1Reg.test(chat) ) {
        time = chat.replace(minecraft1Reg, "$1");
        user = chat.replace(minecraft1Reg, "$2");
        comment = chat.replace(minecraft1Reg, "$3");

    } else if ( minecraft2Reg.test(chat) ) {
        time = chat.replace(minecraft2Reg, "$1");
        user = chat.replace(minecraft2Reg, "$2");
        comment = chat.replace(minecraft2Reg, "$3");

    } else if ( minecraftWebReg.test(chat) ) {
        time = chat.replace(minecraftWebReg, "$1");
        user = '[WEB] ' + chat.replace(minecraftWebReg, "$2");
        comment = chat.replace(minecraftWebReg, "$3");

    } else if ( minecraftSystemLogReg.test(chat) ) {
        time = chat.replace(minecraftSystemLogReg, "$1");
        user = chat.replace(minecraftSystemLogReg, "$2");
        comment = chat.replace(minecraftSystemLogReg, "$3");

    } else if ( skypeFileReg.test(chat) ) {
        time = chat.replace(skypeFileReg, "$2");
        user = chat.replace(skypeFileReg, "$3");
        file = chat.replace(skypeFileReg, "$4");
        comment = file + 'を送信しました';

    } else if ( skypeReg.test(chat) ) {
        time = chat.replace(skypeReg, "$2");
        user = chat.replace(skypeReg, "$3");
        comment = chat.replace(skypeReg, "$4");

    };

    if ( minecraftSystemLogReg.test(chat) ) {
        out = '[' + time + '] ' + user + ' ' + comment + '  ';
    } else {
        out = '[' + time + '] ' + user + ': ' + comment + '  ';
    };

    return out;
};

_convert = function(text) {
    var i, line, lines, result;

    result = '';
    lines = text.split("\n");
    i = 0;

    while (i < lines.length) {
        line = lines[i];
        if (line === '') {
            ++i;
            continue;
        };

        t = _regexp(line);
        result += t + "\n";

        i++;
    };
    return result;
};

return _convert(clipText);
