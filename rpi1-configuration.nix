{...}: {
  imports = [
    ./_rp4.nix
    ./_server.nix
  ];

  networking.hostName = "rpi1";

  services.cron = {
    enable = true;
    mailto = "srackham@gmail.com";
    systemCronJobs = [
      # Run test job every 5 minutes
      # "*/5 * * * *      srackham    date >> /tmp/cron.log"

      # Email test
      # "*/5 * * * *      srackham    echo Test email from cron"

      # Daily logs summary
      "15 8 * * * srackham /home/srackham/bin/log-digest.sh"

      # cryptor portfolio valuation
      # TODO: Once in production on Intel server:
      #       * Put `-force` back in first cryptor.arm64 command.
      #       * Rename cryptor.arm64 to cryptor (amd64).
      "10 8 * * * srackham /home/srackham/bin/cryptor.arm64 valuate -currency nzd -confdir /home/srackham/bin/.cryptor && /home/srackham/bin/cryptor.arm64 valuate -currency nzd -aggregate -confdir /home/srackham/bin/.cryptor && logger -t cryptor-valuation -p user.info 'cryptor valuation completed successfully' || logger -t cryptor-valuation -p user.err 'cryptor valuation failed'"

      # rsnapshot backups
      "20 */4 * * * root /run/current-system/sw/bin/rsnapshot hourly"
      "0 11 * * * root /run/current-system/sw/bin/rsnapshot daily"
      "0 10 * * 2 root /run/current-system/sw/bin/rsnapshot weekly"
      "30 11 1 * * root /run/current-system/sw/bin/rsnapshot monthly"

      # Copy local rsnapshot backups to removeable usb drive
      "45 */8 * * * root mount /dev/disk/by-label/BACKUPS /media/backups && rsync -aH --delete /files/backups /media/backups >/dev/null && umount /media/backups && logger -t rsnapshot-copy -p user.info 'Backup rpi1:/backups to USB drive completed successfully' || logger -t rsnapshot-copy -p user.err 'Backup rpi1:/backups to USB drive failed'"

      # Copy all data (except backups) from nuc1:/files/ to rpi1:/files
      "45 7,11,15,20 * * * root rsync -aH --delete -e ssh --rsync-path='sudo rsync' --exclude '/aquota.*' --exclude '/backups/' nuc1:/files/ /files >/dev/null && logger -t data-backup -p user.info 'Backup nuc1:/files/ to rpi1 completed successfully' || logger -t data-backup -p user.err 'Backup nuc1:/files/ to rpi1 failed'"

      # Backup to Google Drive
      #"15 9 * * * root /home/srackham/bin/rclone-backup.sh >/dev/null && logger -t google-drive-backup -p user.info 'Backup from /files/ to Google Drive completed successfully' || logger -t google-drive-backup -p user.err 'Backup from /files/ to Google Drive failed'"
    ];
  };
}
