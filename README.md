This is an example configuration to run your own email server.

It uses OpenSMTPD, an email server by the OpenBSD developers that is way easier to use than Postfix - you can get it to work with only 10 lines of configuration.

This is meant to be the simplest possible setup for recieving email only for yourself when you have SSH access, in which you case you don't even need to learn Dovecot (the IMAP server) or mbsync, and can download new emails with rsync.

This is tested on Debian 10 and should work anywhere with OpenSMTPD > 6.4 with minor modifications. In particular, if your server doesn't run a Debian-based distro, the service and user are called `smtpd` instead of `opensmtpd` and the config file is `/etc/smtpd/smtpd.conf` instead of `/etc/smtpd.conf`. On OpenBSD the filter executables go in `/usr/local/libexec/smtpd`, and on Arch on `/usr/lib/smtpd/opensmtpd`.

- Ensure that port 25 is open on your server, or you'll have to ask your VPS provider to open it. If you use zsh, you can open a TCP socket on your server with `zmodload zsh/net/tcp; ztcp -l 25`, and check that you can connect to it from your machine with `zmodload zsh/net/tcp; ztcp your_server.com 25`. Otherwise, you can use netcat.
- If you don't have it already, set up a website with Apache or Nginx, so you can get a free TLS certificate for it with Let's encrypt / certbot. It doesn't have to be the same domain as your email's sender domain.
- Set your server's hostname to the domain with TLS. On GNU/Linux, you do this with `hostnamectl set-hostname $domain`.
- From your VPS panel, set your server's IP address reverse DNS to the server's hostname. This is a must to get good deliverability.
- Read `dns.txt` to see how to set your DNS records.
- To prevent cron from spamming you with local emails, append `>/dev/null 2>&1` to each cron job line, or switch to systemd timers.
- OpenSMTPD is preinstalled on OpenBSD. If using latest Ubuntu or Arch, install it from their repositories. If using Debian 10, we'll enable the buster-backports repository to get a newer version of OpenSMTPD, since the configuration file changed in version 6.4 so it would be wasteful to learn the old syntax when it's already obsolete: `echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list && apt update && apt-get -t buster-backports --no-install-recommends install opensmtpd`
- You can choose from multiple software that do DKIM signing:<br>
    - DKIMproxy hasn't been updated in 10 years, but still works and is readily available in Debian's repository. Run `apt install dkimproxy`, and append
    RUN_DKIMPROXY_IN=0
    DKIM_HOSTNAME=sender_domain.xyz
    DOMAIN=sender_domain.xyz
    DKIMPROXY_OUT_MIN_SERVERS=1
to `/etc/default/dkimproxy` (and also `DKIMPROXY_OUT_PRIVKEY=/etc/dkim_private.key` if you generated your own key). That file is well commented if you want to know what those do. Then, assuming you used "mail" as the DKIM selector, `sed -i s/postfix/mail/ /etc/dkimproxy/dkimproxy_out.conf`. Note that the domain and keyfile path in `/etc/dkimproxy/dkimproxy_out.conf` have no effect. Finally, run `systemctl restart dkimproxy`.<br>
    - filter-dkimsign is the simplest since it doesn't require a configuration file, being ran as a service or extra runtime dependencies, but I had problems with it crashing when replying to emails with the same message ID domain as the sender (i.e. when replying to yourself on mailing lists and Sourcehut tickets), and it's not in Debian's repos.<br>
    - rspamd is more complex and checking reverse DNS has been enough for me to avoid spam, without having to check if valid emails end up in a spam directory. If you want to use rspamd for more advanced spam filtering anyway, you can use it for DKIM too, though the integration software opensmtpd-filter-rspamd is not in Debian 10's stable or backports repos.<br>
- Backup the original `/etc/smtpd.conf` if you want, then download this repo's `smtpd.conf` to `/etc/smtpd.conf`, read the comments and replace the example domains with yours.
- Ensure your configuration file doesn't have errors with `smtpd -n`.
- Restart OpenSMTPD. On GNU/Linux, you do this with `systemctl restart opensmtpd`.
- Send local mail with `sendmail foo@your_domain.xyz` and ensure that it gets saved to the configured maildir, if it doesn't check `/var/log/mail.err`.
- Try downloading that email to your computer with `rsync -r --remove-source-files root@server_hostname.com:~mail/smtpd/new ~mail/$USER/INBOX`.
- Test your DNS records on https://appmaildev.com/en/dkim
- Set up a cron job or systemd timer on your computer to download new emails with rsync. If you use the directory I mentioned above, your shell will notify when you have new email.

## More guides

- `man stmpd.conf`
- https://poolp.org/posts/2019-09-14/setting-up-a-mail-server-with-opensmtpd-dovecot-and-rspamd/
- https://prefetch.eu/blog/2020/email-server/
