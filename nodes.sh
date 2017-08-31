#!/usr/bin/env bash

# Variables which i cannot expose
# API_URL=
# REFRESH_TOKEN=
user="arunsanna"
keyname="reancloud"
environment="develop"
hostip=""
node_name="Node-1"
login_user="ec2-user"
login_method="ssh"
scan_status=0

#generating api
generate_api()
    {
        #API TOKEN via refresh token
        echo "generating API TOKEN"
        API_TOKEN=$(curl -s -k -X POST "$API_URL/login" -d "{\"token\": \"$REFRESH_TOKEN\"}" | jq .access_token | tr -d '"' )
    }

#adding keys
add_key()
    {
        #add ssh keys for authentication
        echo "adding private key for authentication"
        key_id=$(curl -s -X POST "$API_URL/owners/$user/keys" -H "Authorization: Bearer $API_TOKEN" -k "Content-Type: application/json" -d "{\"name\":\"$keyname\", \"private\":\"-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAsZiLaYB6a5wKhAYg1X8C956R9YID75Jg4Je+wzROdrnW1T5kmGk0qaFEbyOg\nyX4QVPacaWuaV/TGrqcKkNP7rNr4dPTZwHZGMNBhn6u9xUFH2bYJWqH0wUI2iNW/dv3CrYwAXjI0\neUlIMF7P+ciNtrkXL43SsntC494V3SQ+fEUSI1veH+1lXv/g71skOORw8NjJV4nR8Z/XDiFb3Moe\nkytWTX+0BuOEiul73Bg89V68ed5DP07HBf+8GMwITSve3LljrzAGPCffFFQkuyb6ZSvK3FV5Jk0H\nlUwEDyP0smfwMUYYXk07A4hhvKRoU8CQKnNobHM0dD990wD67+qfSwIDAQABAoIBACD560EOyyx6\nD/XN0YDzEZD7D60flC2C55wscQ58AunGvh5gdHtcZZvtxvBAFFX1o4CzPf3RLhqQ5+d8OtkDk6LY\nEfRdlqVHEOd1efsU/6rF4VqKk5gRpInSCqBD2EZ2/hQNf+/9sIKo2c+pe0KtO6snGSgKVIoxmw0G\nqtaiKTwXo+eSaU+2Z0hXCBerk6nR/Hac4xewfF+aBArGiIWwr/izaFZmN2hCQmPqwE+m3vGAiTnZ\ngU+DpQlqcLQasRDT/8q7Ic8Wpw3kJSQ2ccBoZP9lEgJqMnpsQn/jdJMPzor+QYCzhF4gObUm8A3z\ng15op6JOEXJv3Bfy6q48B9gbGyECgYEA4OA8fqtOBsI6cecr2uEz7kvjVVbIqvQNKqbA7+iiWiWr\ndTjCHPkNS3ULwYVKi6P3Z2fNAx4qrXwODlB7wnQqMWluJTHL22xK4tjnq+sYtRwBtFZgnnnRPCBg\nuAKKWkw/BGFoCBxWaCUkHNwex25jadxw0TARmVJrVVDQf1dX1dsCgYEAyi0XENEAlPpA2VwLnyT0\nmfDaZ9o5NaFmwWyaTzZgJ1tbjCMub9odGq7jAN4sU2v2nxeFij4cKD4TCoX/FlXGp9FvtgSLcL+u\neL4y5OzfmhczMEMuNBbaO1Qk8y2D1oxYqjLDInZVfnXIJg9hcCI5PQvwYL0/c6Dp1Y5lnuoSb1EC\ngYAz1Fr9EvyT4DZaRF6+PwOaG9GUvMDZbhCO0QpNAUBSKLaA+Qj8Zoai6qJAAzmwP6VpJuqAmnZZ\nr+sJb5FmuyFybAtf9T84HpiP+lBDNpdmPsNBzlrMi+Umx4ujPaqnr0Ui/FRe8jEUJeNR54YMjyvI\nnW8/N6YGwZFNg6fagcYT2wKBgQCH8jHkWOVvR6d7gO0/ofXn3ZC+7HozmcgioAhS41lcnY29eZqs\nE5omaxqxZrOflKVM7OAayRDd7n+XP+r69cqS5b2cQwoQUpPbFOncDXt9fcQp28KhvAwagMYnzp8s\nEUs9hsy3y6JJWqGvFgCLCjg62GBWbGrSMY2K0Cl85iBnQQKBgQC+r2+Qk6Zy54EUzxiKCiFW7xGU\nIQpSApynGoWJ0G+4s7tI4dstlfHV+eiWerRRIGHJ7W9Z0z2s4SeQFD1YSnEdBaenh8UVLlKiHdnO\nFIIApip0hGMXhJJ23GbABFqXYSLMe/IcSmP6o0K/Uflfq6pIC9f0TzFhwnJnLctWdYUhBw==\n-----END RSA PRIVATE KEY-----\"}" | jq .id | tr -d '"')
        echo "Key: $key_id"
    }


#add and env
add_env()
    {
        echo "adding the environment"
        env_id=$(curl -s -X POST "$API_URL/owners/$user/envs" -H "Content-Type: application/json" -H "Authorization: Bearer $API_TOKEN" -k -d "{\"name\":\"$environment\"}" | jq .id | tr -d '"')
        echo "Env ID: $env_id"
    }

#adding node
add_node()
    {
        echo "adding the node"
        node_id=$(curl -s -X POST "$API_URL/owners/$user/nodes" -H "Content-Type: application/json" -H "Authorization: Bearer $API_TOKEN" -k -d "[{\"hostname\": \"$hostip\",\"name\": \"$node_name\",\"environment\": \"$environment\",\"loginUser\": \"$login_user\",\"loginMethod\": \"$login_method\",\"loginKey\": \"$user\/$keyname\"}]" | tr -d '[]"')
        echo "Node ID: $node_id"
    }

#checking connectivity
#check if it gets family and if family is redhat then its working
scan()
    {
        family=$(curl -s -X GET "$API_URL/owners/$user/envs/$environment/nodes/$node_id/connectivity" -H "Authorization: Bearer $API_TOKEN" -k | jq .family | tr -d '"')
            if [ $family == "redhat" ]
            then
                echo "passed the connectivity check"
                #get the profiles
                profile_id=$(curl -s -X GET "$API_URL/user/compliance" -H "Authorization: Bearer $API_TOKEN" -k | jq '.base."linux".id'| tr -d '"') #jq -r
                owner=$(curl -s -X GET "$API_URL/user/compliance" -H "Authorization: Bearer $API_TOKEN" -k | jq '.base."linux".owner'| tr -d '"')
                #perform scan and store the result
                scan_id=$(curl -s -X POST "$API_URL/owners/$user/scans" -H "Content-Type: application/json" -H "Authorization: Bearer $API_TOKEN" -k -d "{\"compliance\":[{\"owner\":\"$owner\",\"profile\":\"$profile_id\"}],\"environments\":[{\"id\":\"$env_id\",\"nodes\":[\"$node_id\"]}]}" | jq .id | tr -d '"')
                echo $scan_id
                # pull the scan results
                # if the scan is complete then progress=1 else you should wait
                until [ $scan_status -eq 1 ]; do
                    echo "scan not finished will check after 10 sec"
                    sleep 10
                    scan_status=$(curl -s -X GET "$API_URL/owners/$user/scans/$scan_id" -H "Authorization: Bearer $API_TOKEN" -k | jq .progress)
                done
                curl -s -X GET "$API_URL/owners/$user/scans/$scan_id" -H "Authorization: Bearer $API_TOKEN" -k | jq . > scan_result.json
                curl -s -X GET "$API_URL/owners/$user/scans/$scan_id/rules" -H "Authorization: Bearer $API_TOKEN" -k | jq . > scan_rules.json
                curl -s -X GET "$API_URL/owners/$user/envs/$environment/nodes/$node_id/compliance" -H "Authorization: Bearer $API_TOKEN" -k | jq . > node_compliance.json
            else
                echo "failed connectivity check"
            fi
    }
generate_api
add_key
add_env
add_node
scan

#get_scans()
#    {
#        #get all scans
#        scan_status=$(curl -s -X GET "$API_URL/owners/$user/scans/dc058c37-395f-41c7-4630-5bf219951330 -H "Authorization: Bearer $API_TOKEN" -k | jq .progress)
#        if [ $scan_status -eq 1 ]
#        then
#            echo "scan completed"
#        fi
#    }

#if [ $scan_status -eq 1 ]
#then
#curl -s -X GET "$API_URL/owners/$user/scans/$scan_id" -H "Authorization: Bearer $API_TOKEN" -k | jq . > scan.json
#else
#sleep 60
#fi

#get_scans
#curl -s -X GET "$API_URL/owners/$user/scans/12b051a0-234b-45f2-4a9e-1262a225e231" -H "Authorization: Bearer $API_TOKEN" -k | jq .

# pull the scan results
#curl -s -X GET "$API_URL/owners/$user/scans" -H "Authorization: Bearer $API_TOKEN" -k | jq .

#curl -s -X GET "$API_URL/owners/$user/scans/5621feff-912d-4b5d-5257-ed7b65b23140" -H "Authorization: Bearer $API_TOKEN" -k | jq .

#get an env id
#env_id=$(curl -s -X GET "$API_URL/owners/$user/envs/Development" -H "Content-Type: application/json" -H "Authorization: Bearer $API_TOKEN" -k | jq .id | tr -d '"')
#add a node to env

#instance_id="9400a148-eb09-4430-4a26-f30f3fbfec69"



#update teh job details in the json and then push it into RADAR

#get the name into variable
#node_id=$(curl -s -X GET "$API_URL/owners/$user/envs/$env_1/nodes" -H "Authorization: Bearer $API_TOKEN" -k | jq .[].id | tr -d '"')



#checking compliance
#curl -s -X GET "$API_URL/owners/$user/envs/$env_1/nodes/$node_id/compliance" -H "Authorization: Bearer $API_TOKEN" -k | jq .[]



#get keys
#curl -s -X GET "$API_URL/owners/$user/keys" -H "Authorization: Bearer $API_TOKEN" -k | jq .

#api token using user credentails
#API_TOKEN=$(curl -s -X POST $API_URL/login -d "{\"userid\": \"arunsanna\", \"password\": \"password\"}" -k)
#echo $API_TOKEN