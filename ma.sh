#!/bin/bash

process_file_p() {
    file="$1"
    patch -p1 --verbose -t -N < "$file"
}

process_file_u() {
    file="$1"
    outName="$2"
    filename=$(basename "$file")

    if [ -z "$outName" ]; then
        outName="${filename%.*}"
    fi

    if [[ $filename == *"framework-res"* ]]; then
        mkdir "$outName"
        java -jar ./tools/apktool.jar if -p "$outName" "$file"
    else
        java -jar ./tools/apktool.jar d -api 34 -b -p res -o "$outName" "$file"

        if [[ $filename == *"framework"* ]]; then
            unzip -q "$file" "res/*" -d "$outName/unknown"
            sed -i \
                '/^doNotCompress/i \
                res\/android.mime.types: 8\n\
                res\/debian.mime.types: 8\n\
                res\/vendor.mime.types: 8' \
                "$outName/apktool.yml"
        fi
    fi

}

process_file_c() {
    file="$1"
    outName="$2"

    directory="$file/dist/"
    file_path=$(find "$directory" -maxdepth 1 -type f)
    filename=$(basename "$file_path")
    file_extension="${filename##*.}"

    if [[ "${file: -1}" == "/" ]]; then
    file="${file%?}"
    fi

    java -jar   ./tools/apktool.jar b -c -p res --use-aapt2 "$file"
    mkdir -p ./build



    if [ -z "$outName" ]; then
        file_path=$(find "$file"/dist/ -maxdepth 1 -type f)
        outName=$(basename "$file_path")
    fi
    if [[ "$file_extension" == "jar" ]]; then
        zipalign -f -v -p 4 "$file"/dist/* ./build/"$outName"
    elif [[ "$file_extension" == "apk" ]]; then
        ./tools/signapk ./tools/aosp_platform.x509.pem ./tools/aosp_platform.pk8 "$file"/dist/* ./build/"$outName"
    fi
}

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <argument> <file> [optional_second_argument]"
    exit 1
fi

argument="$1"
file="$2"
outName="$3"

case "$argument" in
    -p)
        process_file_p "$file"
        ;;
    -u)
        process_file_u "$file" "$outName"
        ;;
    -c)
        process_file_c "$file" "$outName"
        ;;
    *)
        echo "Invalid argument. Valid arguments are '-p', '-u', and '-c'"
        exit 1
        ;;
esac


