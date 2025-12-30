#!/usr/bin/env python3
"""MLX90640 IR Thermal Sensor and Camera Module."""

import asyncio
import logging

from viam.module.module import Module

# Import models to register them with the module
import sensor  # noqa: F401 - registers MlxSensor
import camera  # noqa: F401 - registers MlxCamera

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

if __name__ == "__main__":
    asyncio.run(Module.run_from_registry())
