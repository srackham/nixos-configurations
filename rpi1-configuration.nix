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
    ];
  };
}
