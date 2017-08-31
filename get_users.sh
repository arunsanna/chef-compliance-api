#!/usr/bin/
API_TOKEN=$(curl -s -X POST $API_URL/login -d "{\"userid\": \"\", \"password\": \"\"}" -k)
#echo $API_TOKEN
#echo $API_URL
curl -s -X GET "$API_URL/users" -H "Authorization: Bearer $API_TOKEN" -k | jq .