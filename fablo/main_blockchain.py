import requests
import serial
import time
import json
import random
import string

def generate_random_string(length):
    characters = string.ascii_letters + string.digits + string.punctuation
    random_string = ''.join(random.choice(characters) for i in range(length))
    return random_string

# Contoh: Membuat string acak dengan panjang 10


# Ganti dengan URL API endpoint Anda
api_url = "http://localhost:3000/submit/storage-channel/storage-chaincode/CreateAsset"

# Buka koneksi serial ke Arduino
ser = serial.Serial('COM6', 9600)  # Ganti 'COM3' dengan port yang sesuai

def read_sensor_data():
    # Baca data dari Arduino
    data = ser.readline().decode().strip()
    return data

def upload_data(data):
    # Data yang akan diunggah ke API
    payload = [
        generate_random_string(10),
        "001",
        data[1],
        data[2],
        data[3]
    ]
        
    headers = {
        "X-API-Key": "Org1",
        'Content-Type': 'application/json'
    }

    try:
        # Kirim permintaan POST ke API endpoint
        response = requests.put(api_url, headers=headers, json=payload)

        # Periksa apakah permintaan berhasil (kode status 200)
        if response.status_code == 200:
            print("Data berhasil diunggah ke API")
            print("Pesan status:", response.text)
        else:
            print("Gagal mengunggah data ke API. Kode status:", response)
    except Exception as e:
        print("Terjadi kesalahan:", e)

def main():
    try:
        while True:
            # Baca data dari sensor Arduino
            sensor_data = read_sensor_data().split(',')
            
            # Tampilkan data di konsol
            print("Humidity:", sensor_data[0])
            print("Temperature (Celsius):", sensor_data[1])
            print("Temperature (Fahrenheit):", sensor_data[2])
            print("Sensor Value:", sensor_data[3])
            
            # Unggah data ke API
            upload_data(sensor_data)
            
            # Tunggu selama 1 detik sebelum membaca data lagi
            time.sleep(1)
    except KeyboardInterrupt:
        print("Program dihentikan oleh pengguna.")
    finally:
        # Tutup koneksi serial
        ser.close()

if __name__ == "__main__":
    main()
