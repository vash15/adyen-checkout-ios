#/bin/sh

TOKEN='8714279602311541'

curl -v -L -X GET \
  -H "Content-Type: application/json" \
  https://test.adyen.com/hpp/cse/${TOKEN}/json.shtml
