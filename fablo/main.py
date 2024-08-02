import serial
import time

# Buka koneksi serial ke Arduino
ser = serial.Serial('COM6', 9600)  # Ganti 'COM3' dengan port yang sesuai

def read_sensor_data():
    # Baca data dari Arduino
    data = ser.readline().decode().strip()
    return data

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
            
            # Tunggu selama 1 detik sebelum membaca data lagi
            time.sleep(1)
    except KeyboardInterrupt:
        print("Program dihentikan oleh pengguna.")
    finally:
        # Tutup koneksi serial
        ser.close()

if __name__ == "__main__":
    main()
