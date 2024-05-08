#!/bin/bash

# NATMap
outter_ip=$1
outter_port=$2
ip4p=$3

# 默认重试次数为1，休眠时间为3s
max_retries=1
sleep_time=3

# 判断是否开启高级功能
if [ "$LINK_ADVANCED_ENABLE" == 1 ] && [ -n "$LINK_ADVANCED_MAX_RETRIES" ] && [ -n "$LINK_ADVANCED_SLEEP_TIME" ]; then
  # 获取最大重试次数
  max_retries=$((LINK_ADVANCED_MAX_RETRIES == "0" ? 1 : LINK_ADVANCED_MAX_RETRIES))
  # 获取休眠时间
  sleep_time=$((LINK_ADVANCED_SLEEP_TIME == "0" ? 3 : LINK_ADVANCED_SLEEP_TIME))
fi

# 初始化参数
retry_count=0
dns_type="AAAA"
dns_record=""
dns_record_id=""

# 获取cloudflare dns记录的dns_record
for ((retry_count < max_retries; retry_count++; )); do
  dns_record=$(curl --request GET \
    --url https://api.cloudflare.com/client/v4/zones/$LINK_CLOUDFLARE_ZONE_ID/dns_record?name=$LINK_CLOUDFLARE_DDNS_DOMAIN \
    --header "Authorization: Bearer $LINK_CLOUDFLARE_TOKEN" \
    --header 'Content-Type: application/json' >/dev/null 2>/dev/null)
  dns_record_id=$(echo "$dns_record" | jq '.result[0].id' | sed 's/"//g')

  if [ -z "$dns_record_id" ]; then
    # echo "$GENERAL_NAT_NAME - $LINK_MODE 登录失败,休眠$sleep_time秒"
    sleep $sleep_time
  else
    echo "$GENERAL_NAT_NAME - $LINK_MODE 登录成功"
    break
  fi
done

# 更新cloudflare的dns记录
for ((retry_count < max_retries; retry_count++; )); do
  result=$(
    curl --request PUT \
      --url https://api.cloudflare.com/client/v4/zones/$LINK_CLOUDFLARE_ZONE_ID/dns_record/$dns_record_id \
      --header "Authorization: Bearer $LINK_CLOUDFLARE_TOKEN" \
      --header 'Content-Type: application/json' \
      --data "{\"type\":\"$dns_type\",\"name\":\"$LINK_CLOUDFLARE_DDNS_DOMAIN\",\"content\":\"$ip4p\",\"ttl\":60,\"proxied\":false}" >/dev/null 2>/dev/null
  )

  # 判断api是否调用成功,返回参数success是否为true
  if [ "$(echo "$result" | jq '.success' | sed 's/"//g')" == "true" ]; then
    echo "$GENERAL_NAT_NAME - $LINK_MODE 更新成功"
    break
  else
    # echo "$GENERAL_NAT_NAME - $LINK_MODE 修改失败,休眠$sleep_time秒"
    sleep $sleep_time
  fi
done

# Check if maximum retries reached
if [ $retry_count -eq $max_retries ]; then
  echo "$GENERAL_NAT_NAME - $LINK_MODE 达到最大重试次数，无法修改"
  exit 1
fi
