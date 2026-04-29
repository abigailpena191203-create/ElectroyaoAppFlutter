import urllib.request
import json

url = "https://ebayhfmrzbwtgscwvgxm.supabase.co/rest/v1/t_dispositivos?select=*&limit=1"
headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImViYXloZm1yemJ3dGdzY3d2Z3htIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4NTMyNDAsImV4cCI6MjA5MTQyOTI0MH0.O3WiUmrzgdMGBZEtAMEHgorWsrdLoFZCMeVQP1-wcUQ",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImViYXloZm1yemJ3dGdzY3d2Z3htIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4NTMyNDAsImV4cCI6MjA5MTQyOTI0MH0.O3WiUmrzgdMGBZEtAMEHgorWsrdLoFZCMeVQP1-wcUQ"
}

req = urllib.request.Request(url, headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        print(json.dumps(data, indent=2))
except Exception as e:
    print(f"Error: {e}")
