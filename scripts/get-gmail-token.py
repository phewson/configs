import os
from google_auth_oauthlib.flow import InstalledAppFlow

# The scope for full Gmail access (IMAP/SMTP)
SCOPES = ['https://mail.google.com/']

def main():
    # You will need the 'client_secret.json' you downloaded from Google Console
    flow = InstalledAppFlow.from_client_secrets_file('client_secret.json', SCOPES)
    
    # This opens a browser window for you to log in
    # 'prompt=consent' ensures you get a Refresh Token
    creds = flow.run_local_server(port=0, prompt='consent', access_type='offline')
    
    print(f"\nYour Refresh Token: {creds.refresh_token}")
    print(f"Your Client ID: {creds.client_id}")
    print(f"Your Client Secret: {creds.client_secret}")

if __name__ == '__main__':
    main()
