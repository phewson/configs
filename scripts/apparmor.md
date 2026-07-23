AppArmor on Debian Trixie

I've always quite liked the idea of `AppArmor`. My understanding has never gone much beyond "the operating system is trying to protect me from myself and from compromised software", and I'm generally happy for the people who maintain distributions and security frameworks to worry about those details on my behalf. The only reason I've been forced to learn more about it is that an admittedly quirky email setup (`mu4e` + `msmtp` + `OAuth` token refresh scripts) stopped working after a Debian Trixie upgrade. Debugging that meant diving into `AppArmor` much more quickly than I had intended.


## What is AppArmor?

AppArmor is a Linux security system that restricts what individual programs are allowed to do. Instead of trusting every application you run, `AppArmor` applies a profile to each application and says things like:

- these files may be read;
- these files may be written;
- these programs may be executed;
- these network connections may be opened.

This follows the principle of least privilege: if an application is compromised, the attacker is limited to the actions permitted by its `AppArmor` profile.

## Why is AppArmor important?

Most programs do not need unrestricted access to your system.

For example, an SMTP client such as `msmtp` really only needs to:

- read its configuration;
- connect to a mail server;
- write its logs.

If msmtp were compromised by a bug or malicious input, AppArmor can prevent it from:

- reading SSH keys;
- executing arbitrary programs;
- modifying unrelated files;
- accessing sensitive data elsewhere in a home directory.

In other words, AppArmor reduces the impact of a successful attack.

Why are these commands a bad long-term solution?

```bash
sudo touch /etc/apparmor.d/local/usr.bin.msmtp
sudo aa-disable /etc/apparmor.d/usr.bin.msmtp
```

These commands effectively disable AppArmor protection for `msmtp`.

After doing so:

- `msmtp` is no longer confined by its profile;
- any program launched through `passwordeval` can execute freely;
- a future vulnerability in `msmtp` would run with the permissions of the user rather than the much more restrictive permissions intended by the AppArmor profile.

The machine is not suddenly insecure, but a layer of defence that Debian's maintainers deliberately enabled has been removed.

The ideal solution is not to disable AppArmor but to teach AppArmor that the OAuth helper script is legitimate.

```bash
/home/phewson/configs/scripts/get-gmail-refresh-token.sh
```

as well as possibly some of the utilities it uses:

```bash
/usr/bin/gpg
/usr/bin/curl
/usr/bin/jq
```

Technical footnote: The problem was not that AppArmor blocked msmtp itself. msmtp continued to function normally. The failure occurred because `msmtp` runs `passwordeval` commands inside a special AppArmor helper profile (`msmtp//helpers`). Debian Trixie's profile permits only a small set of approved helper programs, and the custom OAuth refresh script was not on that whitelist. As a result, AppArmor denied execution of the script before it could obtain a Gmail access token.
