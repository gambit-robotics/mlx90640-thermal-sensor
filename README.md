# MLX90640 Thermal Sensor Module for Viam

A Viam sensor and camera module for the [MLX90640 32x24 IR thermal sensor](https://www.melexis.com/en/product/MLX90640/Far-Infrared-Thermal-Sensor-Array). Returns temperature readings and generates thermal heatmap images via the Viam Sensor and Camera APIs.

## Models

- `gambit-robotics:sensor:mlx90640-ir-sensor` - Temperature sensor (768 pixel array)
- `gambit-robotics:camera:mlx90640-ir-camera` - Thermal heatmap camera

## Requirements

- Raspberry Pi or compatible SBC with I2C enabled
- MLX90640 IR thermal sensor connected via I2C (default address: 0x33)
- Python 3.11+

## Configuration

Add this module to your Viam robot configuration:

```json
{
  "modules": [
    {
      "type": "registry",
      "name": "gambit_mlx90640",
      "module_id": "gambit-robotics:mlx90640-thermal-sensor"
    }
  ],
  "components": [
    {
      "name": "thermal_sensor",
      "namespace": "rdk",
      "type": "sensor",
      "model": "gambit-robotics:sensor:mlx90640-ir-sensor",
      "attributes": {
        "refresh_rate_hz": 4
      }
    },
    {
      "name": "thermal_camera",
      "namespace": "rdk",
      "type": "camera",
      "model": "gambit-robotics:camera:mlx90640-ir-camera",
      "attributes": {
        "sensor": "thermal_sensor",
        "flipped": false
      },
      "depends_on": ["thermal_sensor"]
    }
  ]
}
```

### Sensor Attributes

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `refresh_rate_hz` | float | No | `4` | Sensor refresh rate. Valid: 0.5, 1, 2, 4, 8, 16, 32, 64 Hz |

### Camera Configuration

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `sensor` | string | **Yes** | - | Name of the configured MLX90640 sensor |
| `flipped` | bool | No | `false` | Flip the thermal image horizontally |

## Sensor Readings

The sensor returns temperature readings via `get_readings()`:

```python
{
    "min_temp_celsius": 22.5,
    "max_temp_celsius": 35.2,
    "min_temp_fahrenheit": 72.5,
    "max_temp_fahrenheit": 95.4,
    "all_temperatures_celsius": [...],      # 768 values (32x24 grid)
    "all_temperatures_fahrenheit": [...],   # 768 values (32x24 grid)
    "all_temperatures_fahrenheit_mirrored": [...]  # Horizontally mirrored
}
```

| Key | Type | Description |
|-----|------|-------------|
| `min_temp_celsius` | float | Minimum temperature in the frame (Celsius) |
| `max_temp_celsius` | float | Maximum temperature in the frame (Celsius) |
| `min_temp_fahrenheit` | float | Minimum temperature in the frame (Fahrenheit) |
| `max_temp_fahrenheit` | float | Maximum temperature in the frame (Fahrenheit) |
| `all_temperatures_celsius` | list[float] | All 768 temperature readings (32x24) in Celsius |
| `all_temperatures_fahrenheit` | list[float] | All 768 temperature readings (32x24) in Fahrenheit |
| `all_temperatures_fahrenheit_mirrored` | list[float] | Mirrored temperature array |

## Camera Output

The camera component generates a thermal heatmap image from the sensor data:
- Native resolution: 32x24 pixels
- Output resolution: 240x320 pixels (upscaled for visualization)
- Format: JPEG with false-color heatmap (blue=cold, red=hot)

**Note:** The upscaled image is for visualization only and not suitable for ML training. Use the sensor's raw temperature array for precise data.

## Hardware Setup

1. Enable I2C on your Raspberry Pi:
   ```bash
   # Option A: Edit config
   echo "dtparam=i2c_arm=on" | sudo tee -a /boot/firmware/config.txt
   sudo reboot

   # Option B: Use raspi-config
   sudo raspi-config  # Interface Options > I2C > Enable
   ```

2. Connect the MLX90640 to your Pi:
   - VIN to 3.3V
   - GND to GND
   - SDA to GPIO 2 (SDA)
   - SCL to GPIO 3 (SCL)

3. Verify the sensor is detected:
   ```bash
   sudo i2cdetect -y 1
   # Should show 33 (default I2C address for MLX90640)
   ```

## Troubleshooting

### Sensor not detected
- Verify I2C wiring: SDA to SDA (GPIO 2), SCL to SCL (GPIO 3)
- Check I2C is enabled: `sudo raspi-config` > Interface Options > I2C
- Confirm address with `i2cdetect -y 1` (should show 0x33)

### "Frame read failed: Too many retries"
This typically occurs during sensor initialization or due to I2C timing issues:
1. **Lower the refresh rate** - Try 2Hz instead of 4Hz, especially on Raspberry Pi 5
2. **Wait for calibration** - Allow 5-10 seconds after boot for the sensor to calibrate
3. **Check connections** - Ensure SCL/SDA are not shorted to power or ground

### Slow or inconsistent readings
- The MLX90640 requires time to stabilize after power-on
- Higher refresh rates may cause I2C bus contention on slower systems
- For reliable operation, start with 4Hz and adjust as needed

## Local Development

```bash
# Clone the repository
git clone https://github.com/gambit-robotics/mlx90640-thermal-sensor.git
cd mlx90640-thermal-sensor

# Create virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Testing on Hardware

```bash
# On Raspberry Pi with MLX90640 connected
./setup.sh
./exec.sh
```

## Building for Registry

```bash
# Build the module tarball
tar -czf module.tar.gz meta.json README.md LICENSE exec.sh setup.sh requirements.txt src

# Upload to Viam registry
viam module upload --version 1.0.0 --platform linux/arm64 module.tar.gz
```

## License

Apache 2.0
