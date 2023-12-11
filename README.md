
# PHP-FPM & Nginx Configuration Migration Script

This script is designed to automate the migration of PHP-FPM configurations from an older version of PHP to a newer one, specifically targeting PHP 8.2 to PHP 8.3. It also updates corresponding Nginx site configurations to reference the new PHP-FPM version's socket paths.

## Features

- Migrates PHP-FPM pool configurations from PHP 8.2 to PHP 8.3.
- Updates Nginx site configurations to point to the new PHP-FPM sockets.
- Backs up original PHP-FPM and Nginx configurations before making changes.
- Provides options to migrate all configurations or specific ones.
- Excludes the default `www.conf` from migration unless explicitly included.
- Restarts PHP-FPM and Nginx services to apply changes.

## Prerequisites

- The script is intended for use on Linux servers running PHP-FPM and Nginx.
- PHP 8.2 and PHP 8.3 should be installed on the system.
- Ensure you have sufficient permissions to modify PHP-FPM and Nginx configurations and restart their services (typically requires root or sudo privileges).

## Usage

1. **Make the Script Executable**:
   \`\`\`
   chmod +x migrate_php_fpm.sh
   \`\`\`

2. **Run the Script**:
   \`\`\`
   ./migrate_php_fpm.sh
   \`\`\`
   Follow the prompts to specify which PHP-FPM configurations to migrate.

3. **Options for Specifying Configurations**:
   - Enter specific configuration filenames separated by space for targeted migration.
   - Type \`all\` to migrate all configurations (excluding \`www.conf\` by default).
   - To include \`www.conf\` in the migration, list it explicitly along with other files.

## Backup

- The script creates backups of the original configuration files in \`/tmp/backup-PHP-Migration_<timestamp>/\`.
- Verify these backups before proceeding with any further changes.

## Testing

- Test the script in a non-production environment before deploying it on live servers.
- Ensure the script handles your specific server setup and configurations.

## Contributions

- Feedback and contributions are welcome. Please feel free to submit issues or pull requests to the repository.

## License

This script is released under the BSD license. For more details, see the LICENSE file in the repository.
