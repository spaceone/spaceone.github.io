#!/bin/sh

set -e
NAME="Florian-Best-LDAPCon2026-Tales-from-integrating-LDAP"

sed '/^## Univention Nubus$/,/^# Login required!$/c\
\
<!-- _transition: fade 1.5s -->\
<style scoped>\
section {\
	background-image: url(images/nubus-lego.png); \
    background-size: 100%; \
    background-repeat: no-repeat; \
    background-position: 100% calc(100% + 111px); \
\
}\
</style>\
\
---\
# Login required!
' $NAME.md > $NAME.tmp.md
make SLIDES="$NAME.tmp.md" docker-html
mv "$NAME.tmp.html" "$NAME.html"

make SLIDES="$NAME.md" docker-pdf
exiftool -Producer="Created by docs.freeiam.org" -Creator="Created by docs.freeiam.org" -overwrite_original $NAME.pdf
