#!/bin/bash

file_path="data.txt"
line_number=1


current_timestamp=$(date +%s)

utc_plus_8_timestamp=$((current_timestamp + 8 * 3600))  # 8小时 * 3600秒/小时

current_datetime=$(date -d "@$utc_plus_8_timestamp" "+%Y-%m-%d %H:%M:%S")

# 定义输出文件路径
stdout_log="stdout_$current_datetime.log"
stderr_log="stderr_$current_datetime.log"
url_path=''
url_err=''

while IFS= read -r line; do
    IFS="|" read -ra elements <<< "$line"
    url=''
    room_id=''
    on_live=1
    plat=''
    # 循环输出每个元素和它的索引
    for index in "${!elements[@]}"; do
        echo "Element $index: ${elements[index]}"

        
        if [ "$index" = 0 ]; then
            plat=${elements[index]}
        fi
        
        if [ "$index" = 1 ]; then
           room_id=${elements[index]}
        fi

        if [ "$index" = 2 ]; then
            on_live=${elements[index]}
        fi
    done

echo "$plat-$room_id-$on_live"

    if [ "$on_live" = 0 ]; then
    python3 "../real-url/$plat.py" << EOF >"$stdout_log" 2>"$stderr_log"
$room_id
EOF
        if [ -s "$stderr_log" ]; then
            echo "err"
            # cat "$stderr_log"
            # rm -f "$stdout_log"
        else
            url=$(sed 's/"//g' "$stdout_log" | grep -Eo 'https?://.+' | head -n 1)
            echo "$url"
            # nohup ffmpeg -i "$url" -c copy\
            #  "$current_datetime-$room_id.mp4" > "./logs/$room_id-stdout.txt" 2> "./logs/$room_id-stderr.txt"\
            #  && sed -i "${line_number}s/.*/$plat|$room_id|1/" &
        fi

    fi


((line_number++))
done < "$file_path"
