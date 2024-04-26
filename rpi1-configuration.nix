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

      # Copy all data from nuc1:/files/ to rpi1:/files
      "35 */4 * * *      root    rsync -avH --delete -e ssh --rsync-path='sudo rsync' --exclude '/aquota.*' nuc1:/files/ /files >/dev/null && logger -t data-backup -p user.info 'Backup nuc1:/files/ to rpi1 completed successfully' || logger -t data-backup -p user.err 'Backup nuc1:/files/ to rpi1 failed'"
    ];
  };
}
