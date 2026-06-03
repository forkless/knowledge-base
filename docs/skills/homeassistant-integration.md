# Home Assistant Integration Development

## Structure

```
custom_components/my_integration/
├── manifest.json          # Version, domain, requirements, codeowners
├── __init__.py            # Setup platform + services
├── config_flow.py         # UI configuration (optional config flow)
├── const.py               # Domain constants, defaults
├── sensor.py              # Sensor platform
├── binary_sensor.py       # Binary sensor platform
├── switch.py              # Switch platform
├── number.py              # Number platform
├── select.py              # Select platform
├── diagnostics.py         # Diagnostics data dump
├── strings.json           # Localized strings for config flow
└── translations/          # Per-locale translations (en.json, etc.)
```

## manifest.json

```json
{
  "domain": "my_integration",
  "name": "My Integration",
  "version": "1.0.0",
  "requirements": ["httpx>=0.27"],
  "dependencies": [],
  "codeowners": ["@your-github-handle"],
  "config_flow": true,
  "iot_class": "local_polling",
  "documentation": "https://github.com/...",
  "issue_tracker": "https://github.com/...",
  "integration_type": "hub"
}
```

`iot_class` options: `assumed_state`, `cloud_polling`, `cloud_push`, `local_polling`, `local_push` (most common: `local_polling` for REST APIs)

## Config Flow

- Derive from `ConfigFlow` with `VERSION = 1`
- `async_step_user()` for the initial form
- `async_step_reauth()` for credential refresh
- Validate connection in `async_step_user()` before saving
- Use `data_schema` with `voluptuous`:

```python
import voluptuous as vol
DATA_SCHEMA = vol.Schema({
    vol.Required("host"): str,
    vol.Optional("port", default=8080): vol.Coerce(int),
    vol.Required("api_key"): str,
})
```

## Coordinator Pattern

For polling integrations, use `DataUpdateCoordinator`:

```python
class MyCoordinator(DataUpdateCoordinator):
    def __init__(self, hass, api):
        super().__init__(
            hass,
            logger,
            name="My Sensor",
            update_interval=timedelta(seconds=30),
        )

    async def _async_update_data(self):
        return await self.api.fetch_data()
```

## Entity Best Practices

- Derive from `CoordinatorEntity` for coordinator-based entities
- Override `_attr_*` properties or implement property methods:
  - `native_value` (sensor), `is_on` (binary_sensor/switch)
  - `native_unit_of_measurement`, `device_class`, `state_class`
  - `unique_id`, `name`, `has_entity_name = True`
- Use `EntityDescription` for consistent entity definitions

```python
from homeassistant.components.sensor import SensorEntityDescription

SENSORS = [
    SensorEntityDescription(
        key="temperature",
        name="Temperature",
        native_unit_of_measurement=UnitOfTemperature.CELSIUS,
        device_class=SensorDeviceClass.TEMPERATURE,
        state_class=SensorStateClass.MEASUREMENT,
    ),
]
```

## Services

Register services in `async_setup_entry`:

```python
async def async_setup_entry(hass, entry):
    async def handle_sync(call):
        await hass.data[DOMAIN][entry.entry_id].sync()

    hass.services.async_register(DOMAIN, "sync", handle_sync)
    return True
```

## Errors

- Raise `HomeAssistantError` for user-facing errors
- Raise `ConfigEntryNotReady` for transient setup failures (HA will retry)
- Raise `CannotConnect` / `InvalidAuth` in config flow validation

## Testing

- `pytest` + `pytest-asyncio` + `pytest-homeassistant-custom-component`
- Test in `tests/` mirroring `custom_components/` structure
- Mock `httpx` / `aiohttp` for API calls, test coordinator logic directly
- Test config flow with `pytest-homeassistant-custom-component` fixtures

## HACS

- Add `hacs.json` at repo root:

```json
{
  "name": "My Integration",
  "content_in_root": false,
  "render_readme": true,
  "domains": ["my_integration"],
  "iot_class": "local_polling"
}
```

- Tag releases with semantic versioning. HACS reads tags for updates.
