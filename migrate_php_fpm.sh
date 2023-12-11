#!/bin/bash
# https://github.com/knofte/php-migration

# Variables
php_old_version="8.2"
php_new_version="8.3"
php_fpm_old_dir="/etc/php/${php_old_version}/fpm/pool.d/"
php_fpm_new_dir="/etc/php/${php_new_version}/fpm/pool.d/"
nginx_sites_dir="/etc/nginx/sites-available/"
backup_dir="/tmp/backup-PHP-Migration_$(date +%Y%m%d%H%M%S)/"
exclude_www=true

# Create backup directory
mkdir -p "${backup_dir}"

# Function to process PHP-FPM file
process_fpm_file() {
    local fpm_file=$1
    echo "Processing PHP-FPM file ${fpm_file}..."

    # Backup the PHP-FPM file
    cp "${php_fpm_old_dir}${fpm_file}" "${backup_dir}"

    # Update and move the PHP-FPM file
    sed "s/php${php_old_version}-fpm/php${php_new_version}-fpm/g" "${php_fpm_old_dir}${fpm_file}" > "${php_fpm_new_dir}${fpm_file}"
    rm -f "${php_fpm_old_dir}${fpm_file}"

    # Update Nginx config for this FPM pool
    update_nginx_config "${fpm_file}"

    echo "PHP-FPM file ${fpm_file} processed."
}

# Function to update Nginx config based on PHP-FPM socket
update_nginx_config() {
    local fpm_file=$1
    local current_socket_path=$(grep -Po "listen\s*=\s*\K[^;]*php${php_new_version}-fpm[^;]*\.sock" "${php_fpm_new_dir}${fpm_file}")
    local old_socket_path=$(echo "$current_socket_path" | sed "s/php${php_new_version}-fpm/php${php_old_version}-fpm/g")

    # Ensure old_socket_path is not empty
    if [ -z "$old_socket_path" ]; then
        echo "No socket path found in ${fpm_file}, skipping Nginx config update."
        return
    fi

    # local new_socket_path=$(echo "$old_socket_path" | sed "s/php${php_old_version}-fpm/php${php_new_version}-fpm/g")
    
    # Find Nginx configs that reference the old socket
    grep -lRZ "$old_socket_path" "$nginx_sites_dir" | while IFS= read -rd '' nginx_config; do
    	echo "Updating Nginx config ${nginx_config} for ${fpm_file}..."

	cp "${nginx_config}" "${backup_dir}"
	sed -i "s|$old_socket_path|$current_socket_path|g" "${nginx_config}"

	echo "Nginx config ${nginx_config} updated for ${fpm_file}."
    done
}

# Main script
echo "PHP FPM and Nginx Configuration Migration from PHP ${php_old_version} to PHP ${php_new_version}"

# Read user input
read -p "Enter PHP-FPM configuration filenames separated by space (or type 'all' to process all files): " input

# Process based on user input
if [ "$input" == "all" ]; then
    for file in "${php_fpm_old_dir}"*; do
        filename=$(basename "$file")
        if [ "$filename" == "www.conf" ] && [ "$exclude_www" == true ]; then
            echo "Skipping www.conf..."
            continue
        fi
        process_fpm_file "$filename"
    done
else
    for filename in $input; do
        if [ -f "${php_fpm_old_dir}${filename}" ]; then
            process_fpm_file "$filename"
        else
            echo "File ${filename} not found."
        fi
    done
fi

# Restart PHP-FPM services
echo "Restarting PHP-FPM services..."
systemctl restart php${php_old_version}-fpm
systemctl restart php${php_new_version}-fpm
echo "Old PHP-FPM service restarted."

# Restart Nginx service
echo "Restarting Nginx..."
systemctl restart nginx
echo "Nginx restarted."

echo "Migration completed."
