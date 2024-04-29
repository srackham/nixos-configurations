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
      # Run test job every 5 min.
      # "*/5 * * * *      srackham    date >> /tmp/cron.log"

      # Email test.
      # "*/5 * * * *      srackham    echo Test email from cron"

      # 4 hourly rsnapshot.
      "15 */4 * * * root /run/current-system/sw/bin/rsnapshot hourly"

      # Copy local rsnapshot backups to removeable usb drive
      "45 */8 * * * root mount /dev/disk/by-label/BACKUPS /media/backups && rsync -aH --delete /files/backups /media/backups >/dev/null && umount /media/backups && logger -t data-backup -p user.info 'Backup rpi1:/backups to USB drive completed successfully' || logger -t data-backup -p user.err 'Backup rpi1:/backups to USB drive failed'"

      # Copy all data (except backups) from nuc1:/files/ to rpi1:/files
      "45 7,11,15,20 * * * root rsync -aH --delete -e ssh --rsync-path='sudo rsync' --exclude '/aquota.*' --exclude '/backups/' nuc1:/files/ /files >/dev/null && logger -t data-backup -p user.info 'Backup nuc1:/files/ to rpi1 completed successfully' || logger -t data-backup -p user.err 'Backup nuc1:/files/ to rpi1 failed'"
    ];
  };
}
