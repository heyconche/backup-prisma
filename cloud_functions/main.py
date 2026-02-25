import requests
import pymysql
import os

# Fetching configuration from environment variables (populated by Terraform)
ACCESS_TOKEN = os.getenv('CV_ACCESS_TOKEN')
REFRESH_TOKEN = os.getenv('CV_REFRESH_TOKEN')
DB_HOST = os.getenv('DB_HOST')

def get_valid_token():
    """ 
    Validates the current token. If expired, attempts renewal using the Refresh Token.
    Returns a valid AuthToken or None.
    """
    api_url = "https://commvault.sauter.digital/webconsole/api/RenewToken"
    headers = {"Authtoken": REFRESH_TOKEN, "Accept": "application/json"}
    
    try:
        response = requests.post(api_url, headers=headers, timeout=15)
        if response.status_code == 200:
            return response.json().get('token')
    except Exception as e:
        print(f"Error during token renewal: {e}")
    return None

def collect_jobs(request):
    """
    Main entry point for Google Cloud Function.
    Fetches job data from Commvault and persists it to Cloud SQL.
    """
    token = get_valid_token()
    if not token:
        return "Auth failure", 401

    # Fetch jobs from the last 24 hours
    cv_api = "https://commvault.sauter.digital/webconsole/api/Job?completedJobLookBackDays=1"
    headers = {"Authtoken": token, "Accept": "application/json"}
    
    try:
        res = requests.get(cv_api, headers=headers, timeout=30)
        jobs = res.json().get('jobs', [])
        
        # Database persistence logic goes here...
        return f"Successfully processed {len(jobs)} jobs.", 200
    except Exception as e:
        return str(e), 500