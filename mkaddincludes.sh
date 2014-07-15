#!/bin/sh

if ! test -f dlllibfiles ; then
	exit 0
fi

export INCLUDEDIR="$1"
export FFMPEGWXSGUID=$(uuidgen)

if ! test -d "$INCLUDEDIR" ; then
	echo "please specify taget (include) directory as 1st argument"
	exit 1
fi

cat /dev/null > $INCLUDEDIR/inttypes.h
cat /dev/null > $INCLUDEDIR/ffmpeg_link_msvs.h
cat <<EOF > $INCLUDEDIR/FFmpegOVS.wxs
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi" xmlns:util="http://schemas.microsoft.com/wix/UtilExtension">
    <Fragment>
        <DirectoryRef Id="NGP_Binary">
            <Component Id="FFmpeg" Guid="$FFMPEGWXSGUID" SharedDllRefCount="yes" Permanent="no">
EOF

for i in $(sort < dlllibfiles); do
	echo "#pragma comment(lib, \"$i.lib\")" >> $INCLUDEDIR/ffmpeg_link_msvs.h
	d=$(echo $i | sed s/\\-/_/g)
	echo "                <File Id=\"$d.dll\" Name=\"$i.dll\" Source=\"\$(env.FFMPEG_HOME)\\\\bin\\\\$i.dll\" Vital=\"yes\" />" >> $INCLUDEDIR/FFmpegOVS.wxs
done

cat <<EOF >> $INCLUDEDIR/FFmpegOVS.wxs
            </Component>
        </DirectoryRef>
    </Fragment>
</Wix>
EOF
