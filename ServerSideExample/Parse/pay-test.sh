#/bin/sh

TOKEN='{"version":"Adyen_Test","signature":"ZmFrZSBzaWduYXR1cmU=","header":{"ephemeralPublicKey":"MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEmxChCpjKzf9aXz26WT6ZTN2zE3iGXQjcZRYYAdQITDX2RkANbt7k9rahF1hzjjmeVTxcgCofH81zk2GNTZ3dtg==","publicKeyHash":"OrWgjRGkqEWjdkRdUrXfiLGD0he/zpEu512FJWrGYFo=","transactionId":"1234567890ABCDEF"},"data":"1dXE13kvzTVP6nWEN8D2phrPlfQcGr8W3yj2SHYYj/PycHWTjnpV7z/Er78brimAibT1fn3yB7yB20IGIXGLhCEYzLq503IDy+obVZZkDtJzU0Ai0bZkRE5uy7jOls/mJlyO/LOx6KES2wj5r71GTTEjvuALfj165CQAtv7eEA73qZyGfC5BDpNHivjd2IRr8A4dcDbNtNW/EUYTkD7uQmCWRroPEtcERyofwWZ/P4N/HIsyCaLH739ERSortTYx7j8MoPHdMZGKC3h3csJxvLh7kFr77VFKYTe1eimDfy+fsPLW6ZKozysNGBmhO7ngmXPOcyAf3Mwg6Wbk42MJoi8bCzywsjbUhEpdNgZmnCN57U1pbHoLP+hbQTIKbTbffXdZVzJ6Ekt4LDCzjBRF7yl/i1lBUcauH10soSMBVe+l1F03Tcd78sJW5L7uv9h4eOztzmvblk3dx4wmp92eCccXXcU+9OYvdvy4n+Lhx7xak+ul8L+m"}'
TOKEN_B64=`echo ${TOKEN} | base64`

JSON="{\
  \"reference\":\"Test_1_GBP\",\
  \"paymentData\": \"${TOKEN_B64}\",\
  \"currency\":\"GBP\",
  \"amount\":1.00\
}";

curl -v -L -X POST \
  -H "Content-Type: application/json" \
  -d "${JSON}" \
  https://merchant-pay.parseapp.com/payment
