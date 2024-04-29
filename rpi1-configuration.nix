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
      "50 7 * * * root /home/srackham/bin/log-digest.sh"

      # rsnapshot backups
      "15 */4 * * * root /run/current-system/sw/bin/rsnapshot hourly"
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
