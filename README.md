# [`rand:waveshare-thermal` module](<https://github.com/randhid/waveshare-thermal>)

This [module](https://docs.viam.com/registry/#modular-resources) implements the [`rdk:components:sensor` and the `rdk:components:camera` APIs] in <rand:waveshare-thermal:mlx90641-ir-sensor> and  <rand:waveshare-thermal:mlx90641-ir-camera> models.
With this module, you can use Waveshare's thermal cameras to detect temperatures and display an image of the associated heatmap that the IR lens senses from its environment.

*Note*: The associated heatmap from the camera has been resized from its 24x32 pixel array to make it easier to see. However, this resized image would be unsuitable for algorithms that require precise temperatures. Please configure a<rand:waveshare-thermal:mlx90641-ir-sensor> and use the sensor's [`GetReadings`](https://docs.viam.com/appendix/apis/components/sensor/#getreadings) method to extract accurate data from this device.

## Requirements

This module installs only on Raspberry Pi boards with Python >= 3.8, as RPi.GPIO is required for the current release.

The module should attempt to install `uv` to run, but if this Python package needs to be installed manually, you can install it with the following commands:
```bash
# On Linux.
$ curl -LsSf https://astral.sh/uv/install.sh | sh

```

```bash
# With pip.
$ pip install uv

```

## Configure your <rand:waveshare-thermal:mlx90641-ir-sensor> <rdk:component:sensor>

Navigate to the [**CONFIGURE** tab](https://docs.viam.com/configure/) of your [machine](https://docs.viam.com/fleet/machines/) in [the Viam app](https://app.viam.com/).
[Add `sensor`/ `waveshare-thermal:mlx90641-ir-sensor` to your machine](https://docs.viam.com/configure/#components).

### Sensor Attributes
No configuration attributes are required for the sensor, but you can set the refresh rate:
```json
{
  "refresh_rate_hz": 2
}
```
The following attributes are available for `rand:waveshare-thermal:mlx90641-ir-sensor` <rdk:component:sensor>s:

| Name    | Type   | Required?    | Description |
| ------- | ------ | ------------ | ----------- |
| `refresh_rate_hz` | float | Optional | How often the sensor should refresh and report its readings. Default: 4 hz|

## Configure your <rand:waveshare-thermal:mlx90641-ir-camera> <rdk:component:camera>

Navigate to the [**CONFIGURE** tab](https://docs.viam.com/configure/) of your [machine](https://docs.viam.com/fleet/machines/) in [the Viam app](https://app.viam.com/).
[Add `camera`/ `waveshare-thermal:mlx90641-ir-camera` to your machine](https://docs.viam.com/configure/#components).


### Camera Attributes

On the new component panel, copy and paste the following attribute template into your JSON configuration:
```json
{
  "sensor": "<sensor-name>",
  "flipped": true
}
```

| Name    | Type   | Required?    | Description |
| ------- | ------ | ------------ | ----------- |
| `sensor` | string | **Required** | Name of the configured  <rand:waveshare-thermal:mlx90641-ir-sensor> on your machine.|
| `flipped` | bool | Optional | Whether to flip the thermal camera's image.|

### Example configuration

```json
{
  "components": [
    {
      "name": "sensor-1",
      "namespace": "rdk",
      "type": "sensor",
      "model": "rand:waveshare-thermal:mlx90641-ir-sensor",
      "attributes": {}
    },
    {
      "name": "camera-1",
      "namespace": "rdk",
      "type": "camera",
      "model": "rand:waveshare-thermal:mlx90641-ir-camera",
      "attributes": {
        "sensor": "sensor-1"
      },
      "depends_on": [
        "sensor-1"
      ]
    }
  ],
  "modules": [
    {
      "type": "registry",
      "name": "rand_waveshare-thermal",
      "module_id": "rand:waveshare-thermal",
      "version": "0.0.4"
    }
  ]
}
```

### Next steps
You can write code using this module using the [sensor](https://docs.viam.com/appendix/apis/components/sensor/) or [camera](https://www.google.com/search?q=viam+camera+api) Viam APIs. 

## Troubleshooting

Make sure that the I2C wires are connected to the [correct pins](https://pinout.xyz/ ): Connect the device's SDA to the SDA pin on the board and its SCL to the SCL pin on the Raspberry Pi.

When the device boots up, it follows a calibration sequence and will not show readings or an image immediately. Allow 5-10 seconds for the device to extract its calibration parameters and apply them, and then it will start measuring and reporting data. 


"Frame read failed: Too many retries"

**Description:** This error typically occurs with IR camera modules and similar specialized cameras.
It happens when the camera module is still initializing or calibrating itself, but `viam-server` is already attempting to read frames from it.
This can also be caused by I2C communication issues between the board and the camera module, particularly on Raspberry Pi 5 systems.

**Solution:** Try one of the following approaches:

1. **Reduce the refresh rate for I2C cameras**:
   For I2C-based cameras (like some IR modules), try setting the refresh rate to a lower value (for example, 2Hz instead of 4Hz).
   This can help with I2C bus timing issues, especially on Raspberry Pi 5 systems.

1. **Check physical connections**:

   - Ensure the camera module is properly connected.
   - For I2C cameras, verify that the SCK (clock) pin is properly connected and not shorted to ground or power.
     If the pin has been shorted, this can permanently damage the hardware.

If these steps don't resolve the issue, check your machine logs for additional error messages that might provide more specific information about the problem.
