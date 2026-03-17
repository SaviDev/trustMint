$dirs = @("lib/app", "lib/background", "lib/domain/entities", "lib/domain/usecases", "lib/domain/policies", "lib/data/local/database", "lib/data/remote", "lib/data/sensors", "lib/data/context", "lib/data/notifications", "lib/features/auth", "lib/features/bandi", "lib/features/session", "lib/features/ema", "lib/features/earnings", "lib/features/settings")
foreach ($d in $dirs) { New-Item -ItemType Directory -Force $d }

$files = @(
  "lib/app/router.dart", "lib/app/theme.dart",
  "lib/background/background_entrypoint.dart", "lib/background/sensor_loop.dart", "lib/background/sync_handler.dart",
  "lib/domain/entities/bando.dart", "lib/domain/entities/session.dart", "lib/domain/entities/sensor_spec.dart", "lib/domain/entities/ema_config.dart", "lib/domain/entities/consent_profile.dart",
  "lib/domain/usecases/fetch_bandi.dart", "lib/domain/usecases/enroll_bando.dart", "lib/domain/usecases/start_session.dart", "lib/domain/usecases/stop_session.dart", "lib/domain/usecases/submit_ema.dart", "lib/domain/usecases/sync_session.dart", "lib/domain/usecases/withdraw_consent.dart",
  "lib/domain/policies/sampling_policy.dart", "lib/domain/policies/validation_policy.dart",
  "lib/data/local/database/app_database.dart", "lib/data/local/database/sensor_dao.dart", "lib/data/local/database/ema_dao.dart", "lib/data/local/database/session_dao.dart", "lib/data/local/secure_storage.dart",
  "lib/data/remote/api_client.dart", "lib/data/remote/bando_remote.dart", "lib/data/remote/data_upload_remote.dart",
  "lib/data/sensors/accelerometer_source.dart", "lib/data/sensors/gyroscope_source.dart", "lib/data/sensors/magnetometer_source.dart", "lib/data/sensors/barometer_source.dart",
  "lib/data/context/activity_source.dart", "lib/data/context/screen_state_source.dart", "lib/data/context/battery_source.dart",
  "lib/data/notifications/ema_notification_scheduler.dart",
  "lib/features/auth/registration_screen.dart",
  "lib/features/bandi/bandi_list_screen.dart", "lib/features/bandi/bando_detail_screen.dart",
  "lib/features/session/session_screen.dart", "lib/features/session/session_controller.dart",
  "lib/features/ema/ema_screen.dart", "lib/features/ema/ema_controller.dart",
  "lib/features/earnings/earnings_screen.dart",
  "lib/features/settings/settings_screen.dart", "lib/features/settings/privacy_screen.dart"
)
foreach ($f in $files) { New-Item -ItemType File -Force $f }
