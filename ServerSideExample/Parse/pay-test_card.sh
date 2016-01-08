#/bin/sh

# TOKEN='adyenan0_1_1$jHXxnJKySugbGa1oBcJtWR5RTqzZptYRVg0Df1vJaicPUOYi6He/Vz8SIdfZgrtJuUZODkAOLlQ+aetiwTmqYrAHzIXTABfxWgQTo0VY8eDX4p9MlaOa/0nNjg7VKclvzhVtqMZX8eAJ9YDWSHDBOGQUUH4SoPxIudnEeTVZKbnvOyGmoXMeQMVV9Uv1f1+aXJ8+5Y0M0K8k2hQXUlJOn0Q/KUUt+0EbaVhFSdAqZjDSzfXzFz9uW0oVcevmFjizZIdxok4qnROFCjC9vSX478PN3xMALXtY2Azq5zmMjeXjfaH6tSmfhD1EkOoud+LV82+9nPGcbaVH+jvmdIlP9w==$KoNlcnnImD53fDJmxXhylzd1ehnSGxnEJTsPUs/LXOXwfFapPtqNUmFKuv7THPcBT7whvdL0bIY/lF+BVCbYwSFHVzzJRkW4LSIxSmQOTVEG8TzWLiVseuy0whELGja3ivQhfwJ6O5M8j/D8RbumHRY0wdULSqq1kNU2m3eUsldbMkn0cqq6FdhBTyw4nz4lL+zm8fqI5OjyaHsIIaGquBTc3JiKzRs='
TOKEN='adyenan0_1_1$PJpbDt7E7e8c+aW7LqR5gbldPYMyLhY5QbE3yeQrIiZH+h1S2oQ4jb/3jwABqtn+wVOTsZ/kyPVDgFYGdjkg6sy6/WIej3nlLs+0R3dPgt8xgGLxIXpHZuK9m/fvYFIxA63w1u7Sn8/YicTOXOyNDm4G6I9cn6aGB81kMPq3XZSEIyDNitXWhr7OHCVgdXRVCggq5kd64st35uzgKvtMiukqjVwaUjN6A6a/mGWf6K1RVMdujpdREwpVDOCNaDLc77up6bbCccxrPj4E/VcnMIcc2T8dcunEuScD40Ugh+ML86sykz/bkv5Eq7hMdRodyo+J8+YFFGqaodAx62C74Q==$iu8IY8JlzJWL7PpF4/pWBP5dDNZIRDEIGmNrTta9kaEjYHDav57El2C7sKgVAEri4zrmWHbGSoiB3mSZdAvydUnO6Lu60LqMFQQoI7An4+vYOXjyaYzkNi5aHxLNsFe7hyO+0I9YwsAni0RzODhhtrq7t77X/7zxIHFv/OUDjo+v87T00i2iP5dkPLSqzDOBUBi7GEi14oq4xjoClBg='

JSON="{\
  \"reference\":\"30 9039023f 029 2\",\
  \"paymentData\": \"${TOKEN}\",\
  \"currency\":\"EUR\",
  \"amount\":1.00\
}";

curl -v -L -X POST \
  -H "Content-Type: application/json" \
  -d "${JSON}" \
  https://merchant-pay.parseapp.com/payment
