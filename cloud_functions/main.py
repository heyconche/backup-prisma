import os
import requests
import pymysql
from google.cloud import secretmanager

# --- CONFIGURATION & ENVIRONMENT VARIABLES ---
# These are populated by Terraform in the Cloud Function deployment
PROJECT_ID = os.environ.get('GCP_PROJECT')
DB_USER = os.environ.get('DB_USER')
DB_PASS = os.environ.get('DB_PASS')
DB_NAME = os.environ.get('DB_NAME')
INSTANCE_CONNECTION_NAME = os.environ.get('CLOUD_SQL_CONNECTION_NAME')

def get_secret(secret_id):
    """
    Fetches the Refresh Token from Google Secret Manager.
    """
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{PROJECT_ID}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

def get_valid_token(refresh_token):
    """
    Exchanges the Refresh Token for a new Access Token via Commvault API.
    """
    url = "https://commvault.sauter.digital/webconsole/api/RenewToken"
    headers = {"Authtoken": refresh_token, "Accept": "application/json"}
    
    try:
        # Requesting a new session token using the long-lived refresh token
        res = requests.post(url, headers=headers, timeout=20)
        if res.status_code == 200:
            return res.json().get('token')
        print(f"Failed to renew token: {res.status_code} - {res.text}")
    except Exception as e:
        print(f"Error calling RenewToken API: {e}")
    return None

def ensure_schema_exists(conn):
    """
    Checks if the required table exists, creating it if necessary.
    Replaces the need for manual SQL execution or local-exec provisioners.
    """
    with conn.cursor() as cursor:
        # Using the schema defined in sql/schema.sql but handled by Python
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS daily_jobs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                job_id INT NOT NULL,
                client_name VARCHAR(255) NOT NULL,
                status VARCHAR(50) NOT NULL,
                collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY unique_job (job_id)
            )
        """)
    conn.commit()

def run_collector(event, context):
    """
    Main entry point for the Cloud Function (triggered by Cloud Scheduler).
    """
    # 1. Get Refresh Token from Secret Manager
    # Each client environment should have its own secret name
    refresh_token = get_secret(f"cv-refresh-token-{DB_NAME}")
    
    # 2. Get a fresh Access Token
    access_token = get_valid_token(refresh_token)
    if not access_token:
        return "Authentication failed", 401

    # 3. Connect to Cloud SQL via Unix Socket (Cloud SQL Auth Proxy)
    # This is the most secure way, as it doesn't require public IP whitelisting
    unix_socket = f'/cloudsql/{INSTANCE_CONNECTION_NAME}'
    
    try:
        db_conn = pymysql.connect(
            user=DB_USER,
            password=DB_PASS,
            unix_socket=unix_socket,
            db=DB_NAME
        )
        
        # 4. Ensure the database table is ready
        ensure_schema_exists(db_conn)
        
        # 5. Fetch Jobs from Commvault
        cv_url = "https://commvault.sauter.digital/webconsole/api/Job?completedJobLookBackDays=1"
        headers = {"Authtoken": access_token, "Accept": "application/json"}
        
        response = requests.get(cv_url, headers=headers, timeout=30)
        if response.status_code == 200:
            jobs = response.json().get('jobs', [])
            
            with db_conn.cursor() as cursor:
                for j in jobs:
                    summary = j.get('jobSummary', {})
                    # Insert data, ignoring duplicates based on job_id
                    sql = "INSERT IGNORE INTO daily_jobs (job_id, client_name, status) VALUES (%s, %s, %s)"
                    cursor.execute(sql, (summary.get('jobId'), summary.get('subclientName'), summary.get('status')))
            
            db_conn.commit()
            print(f"Successfully processed {len(jobs)} jobs for {DB_NAME}")
        
        db_conn.close()
        return "Success", 200

    except Exception as e:
        print(f"Critical error in collection: {e}")
        return str(e), 500