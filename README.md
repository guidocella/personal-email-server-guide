This is an example configuration to run your own email server.

It uses OpenSMTPD, an email server by the OpenBSD developers that is way easier to use than Postfix - you can get it to work with only 10 lines of configuration.

This is meant to be the simplest possible setup for recieving email only for yourself when you have SSH access, in which you case you don't even need to learn Dovecot (the IMAP server) or mbsync, and can download new emails with rsync.

This is tested on Debian and should work on other systems with minor modifications. In particular, if your server doesn't run a Debian-based distro, the service and user are called `smtpd` instead of `opensmtpd` and the config file is `/etc/smtpd/smtpd.conf` instead of `/etc/smtpd.conf`.

Ensure that port 25 is open on your server, or you'll have to ask your VPS provider to open it. If you use zsh, you can open a TCP socket on your server with `zmodload zsh/net/tcp; ztcp -l 25`, and check that you can connect to it from your machine with `zmodload zsh/net/tcp; ztcp your_server.com 25`. Otherwise, you can use netcat.

If you don't have it already, set up a website with Apache or Nginx, so you can get a free TLS certificate for it with Let's encrypt / certbot. It doesn't have to be the same domain as your email's sender domain.

Set your server's hostname to the domain with TLS. On GNU/Linux, you do this with `hostnamectl set-hostname $domain`.

From your VPS panel, set your server's IP address reverse DNS to the server's hostname. This is a must to get good deliverability.

Read `dns.txt` to see how to set your DNS records.

To prevent cron from spamming you with local emails, append `>/dev/null 2>&1` to each cron job line, or switch to systemd timers.

Install opensmtpd from your package manager, unless you're using OpenBSD where it is preinstalled.

Give the `opensmtpd` user permission to read Let's encrypt's certificates, for example with:

```
groupadd tls-cert -U opensmtpd
chmod o+x /etc/letsencrypt/{live,archive}
chgrp -R tls-cert /etc/letsencrypt/{live,archive}/<server_hostname.com>
chmod g+r /etc/letsencrypt/archive/<server_hostname.com>/privkey*
```

You can find more details at https://www.unrealircd.org/docs/Setting_up_certbot_for_use_with_UnrealIRCd#Tweaking_permissions_on_the_key_file

You can do DKIM signing with filter-dkimsign or rspamd:

- filter-dkimsign is simpler since it doesn't require a configuration file, being ran as a service or extra dependencies. Just install it (`opensmtpd-filter-dkimsign` on Debian) and later follow the example in `smtpd.conf`.
- rspamd is a spam filtering daemon that can also do DKIM signing. If checking reverse DNS is enough for you to avoid spam, filter-dkimsign is easier to use. Otherwise to do DKIM signing with rspamd install it and the OpenSMTPD integration software `opensmtpd-filter-rspamd`, then create a `/etc/rspamd/local.d/dkim_signing.conf` file with
```
allow_username_mismatch = true;

domain {
    <sender_domain.xyz> {
        path = "/etc/dkim_private.key";
        selector = "mail";
    }
}
```
Then finally run `systemctl restart rspamd`.

Backup the original `/etc/smtpd.conf` if you want, then download this repo's `smtpd.conf` to `/etc/smtpd.conf`, read the comments and replace the example domains with yours.

Ensure your configuration file doesn't have errors with `smtpd -n`.

Restart OpenSMTPD. On GNU/Linux, you do this with `systemctl restart opensmtpd`.

Send local mail with `sendmail foo@<your_domain.xyz>` and ensure that it gets saved to the configured maildir, if it doesn't check `/var/log/mail.err`.

Try downloading that email to your computer with `rsync -rtz --remove-source-files root@<server_hostname.com>:~mail/smtpd/new ~mail/$USER/INBOX`.

Test your DNS records on https://appmaildev.com/en/dkim

Set up a cron job or systemd timer on your computer to download new emails with rsync. If you use the directory I mentioned above, your shell will notify when you have new email.

On Debian 12 OpenSMTPD 6.8 can't receive emails from most domains because it is incompatible with OpenSSL 3. This is fixed by installing OpenSMTPD 7.3 from unstable with apt pinning: http://jaqque.sbih.org/kplug/apt-pinning.html

## More guides

- `man stmpd.conf`
- https://poolp.org/posts/2019-09-14/setting-up-a-mail-server-with-opensmtpd-dovecot-and-rspamd/
- https://prefetch.eu/blog/2020/email-server/
