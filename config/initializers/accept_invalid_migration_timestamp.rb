# 202302021080041_set_language_default.rb violates timestamp validation introduced with rails 7.2
Rails.application.config.active_record.validate_migration_timestamps = false
