{...}: {
  imports = [
    ./_rp4.nix
    ./_server.nix
  ];

  networking.hostName = "rpi1";

  services.cron = {
    enable = true;
    systemCronJobs = [
      # Run test job every 5 min.
      "*/5 * * * *      srackham    date >> /tmp/cron.log"
    ];
  };
}
