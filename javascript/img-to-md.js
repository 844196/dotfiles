_convert = function(text) {
    var url, img, alt, result;

    url = text.match(/https?:\/\/[a-zA-Z0-9\-_\.:@!~*'\(¥);\/?&=\+$,%#]+/);
    img = text.match(/https?:\/\/[a-zA-Z0-9\-_\.:@!~*'\(¥);\/?&=\+$,%#]+(jpg|jpeg|gif|png|bmp)/g);
    if ( text.match(/alt=".*?"/) ) {
        var a = text.match(/alt="(.*?)"/);
        alt = a[1];
    } else {
        alt = '';
    };

    result = '[![' + alt + '](' + img + ')](' + url + ')'

    return result;
};

return _convert(clipText);
