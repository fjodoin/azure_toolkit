import sys
import jwt
import requests
import json  # Import the json module


def process_data(data):
    # Process the data here
    print(json.dumps(data, indent=4))

def recursive_call(url, headers):
    response = requests.get(url=url, headers=headers)
    data = json.loads(response.content)
    process_data(data)

    for item in data:
        if '@odata.context' in item:
            pass
            # print(data['@odata.context'])
            # recursive_call(item['@odata.context'], headers)

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} access_token")
        sys.exit()
    else:
        access_token = sys.argv[1]
        try:
            decoded_token = jwt.decode(access_token, options={"verify_signature": False, "verify_aud": False})  # Decode token
        except Exception as e:
            print(f"[-] An error has occurred: {str(e)}")
            sys.exit()
        print(f"[+]---------------[+]\nTargeting:\t{decoded_token['aud']}\nAs:\t\t{decoded_token['unique_name']}\nScope:\t\t{decoded_token['scp']}\n[+]---------------[+]")

        base_url = "https://graph.microsoft.com/"
        version = "v1.0/"
        endpoint = "users/{id}"  # <--- this may depend on the 'scp' of the access_token
        url = base_url + version + endpoint

        # Properly format the headers as a JSON string
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0 OS/10.0.19045",
            "Authorization": f"Bearer {access_token}"  # Use the access_token directly
        }

        recursive_call(url, headers)

if __name__ == "__main__":
    main()
