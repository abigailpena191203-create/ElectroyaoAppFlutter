import urllib.request
import json

url = "https://ebayhfmrzbwtgscwvgxm.supabase.co/rest/v1/t_dispositivos?nombre_area=eq.Cerradura%20Electr%C3%B3nica"
headers = {
    "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImViYXloZm1yemJ3dGdzY3d2Z3htIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4NTMyNDAsImV4cCI6MjA5MTQyOTI0MH0.O3WiUmrzgdMGBZEtAMEHgorWsrdLoFZCMeVQP1-wcUQ",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImViYXloZm1yemJ3dGdzY3d2Z3htIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4NTMyNDAsImV4cCI6MjA5MTQyOTI0MH0.O3WiUmrzgdMGBZEtAMEHgorWsrdLoFZCMeVQP1-wcUQ",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

# Hacemos un toggle simulado cambiando el estado a Activo
data = json.dumps({"estado": "Activo"}).encode("utf-8")

req = urllib.request.Request(url, data=data, headers=headers, method="PATCH")
try:
    with urllib.request.urlopen(req) as response:
        resp_data = json.loads(response.read().decode())
        print("UPDATE FORZADO DESDE PYTHON EXITOSO:")
        print(json.dumps(resp_data, indent=2))
except Exception as e:
    print(f"Error forzando escritura: {e}")
