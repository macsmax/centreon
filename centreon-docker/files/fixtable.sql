ALTER TABLE centreon_storage.metrics
CHANGE warn_threshold_mode warn_threshold_mode TINYINT(1),
CHANGE crit_threshold_mode crit_threshold_mode TINYINT(1);
