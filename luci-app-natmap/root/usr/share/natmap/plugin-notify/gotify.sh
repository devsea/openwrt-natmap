#!/bin/bash

# Define the Gotify URL, title, message, and priority
title="natmap - ${GENERAL_NAT_NAME} 更新"
message="$1"
gotify_url="${NOTIFY_GOTIFY_URL}"
priority="${NOTIFY_GOTIFY_PRIORITY:-5}"
token="${NOTIFY_GOTIFY_TOKEN}"

# 获取最大重试次数和间隔时间
# 默认重试次数为1，休眠时间为1s
max_retries=$2
sleep_time=$3
retry_count=0

# # # 判断是否开启高级功能
# # if [ "${NOTIFY_ADVANCED_ENABLE}" == 1 ] && [ -n "$NOTIFY_ADVANCED_MAX_RETRIES" ] && [ -n "$NOTIFY_ADVANCED_SLEEP_TIME" ]; then
# #     # 获取最大重试次数
# #     max_retries=$((NOTIFY_ADVANCED_MAX_RETRIES == "0" ? 1 : NOTIFY_ADVANCED_MAX_RETRIES))
# #     # 获取休眠时间
# #     sleep_time=$((NOTIFY_ADVANCED_SLEEP_TIME == "0" ? 1 : NOTIFY_ADVANCED_SLEEP_TIME))
# # fi

# # 判断是否开启高级功能
# if [ "${NOTIFY_ADVANCED_ENABLE}" == 1 ]; then
#     # 获取最大重试次数
#     max_retries=$NOTIFY_ADVANCED_MAX_RETRIES
#     # 获取休眠时间
#     sleep_time=$NOTIFY_ADVANCED_SLEEP_TIME
# fi

while (true); do

    # Send the message using curl
    # curl -s -X POST -H "Content-Type: multipart/form-data" -F "token=$token" -F "title=$title" -F "message=$message" -F "priority=$priority" "$gotify_url/message"
    curl -s -X POST -H "Content-Type: multipart/form-data" -F "title=$title" -F "message=$message" -F "priority=$priority" "${gotify_url}/message?token=$token"
    status=$?
    if [ $status -eq 0 ]; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') : $GENERAL_NAT_NAME - $NOTIFY_MODE 发送成功" >>/var/log/natmap/natmap.log
        echo "$(date +'%Y-%m-%d %H:%M:%S') : $GENERAL_NAT_NAME - $NOTIFY_MODE 发送成功"
        break
    fi

    # 检测剩余重试次数
    let retry_count++
    if [ $retry_count -lt $max_retries ] || [ $max_retries -eq 0 ]; then
        echo "$NOTIFY_MODE 登录失败,休眠$sleep_time秒" >>/var/log/natmap/natmap.log
        sleep $sleep_time
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') : $GENERAL_NAT_NAME - $NOTIFY_MODE 达到最大重试次数，无法通知" >>/var/log/natmap/natmap.log
        echo "$(date +'%Y-%m-%d %H:%M:%S') : $GENERAL_NAT_NAME - $NOTIFY_MODE 达到最大重试次数，无法通知"
        break
    fi
done

# # Check if maximum retries reached
# if [ $retry_count -eq $max_retries ]; then
#     echo "$(date +'%Y-%m-%d %H:%M:%S') : $GENERAL_NAT_NAME - $NOTIFY_MODE 达到最大重试次数，无法通知" >>/var/log/natmap/natmap.log
#     echo "$(date +'%Y-%m-%d %H:%M:%S') : $GENERAL_NAT_NAME - $NOTIFY_MODE 达到最大重试次数，无法通知"
#     exit 1
# else
#     echo "$(date +'%Y-%m-%d %H:%M:%S') : $GENERAL_NAT_NAME - $NOTIFY_MODE 发送成功" >>/var/log/natmap/natmap.log
#     echo "$(date +'%Y-%m-%d %H:%M:%S') : $GENERAL_NAT_NAME - $NOTIFY_MODE 发送成功"
#     exit 0
# fi
