#!/usr/bin/env bash

API_TOKEN=$(curl -s -X POST $API_URL/login -d "{\"userid\": \"\", \"password\": \"="}" -k)

#get compliace profiles
curl -s -X GET "$API_URL/user/compliance" -H "Authorization: Bearer $API_TOKEN" -k | jq .