# Backup and restore strategy
According to https://www.mediawiki.org/wiki/Manual:Backing_up_a_wiki, there are
3 methods of doing MediaWiki backup:
- XML dump: unfortunately it doesn't export the data accounting tables. It is
  described as a last resort when the other methods don't work. It is also
  slow: it takes 10 min to restore a 400+ 25 MB page data from aqua.inblock.io.
  Doesn't support incremental backup.
- Logical backup using mysqldump: fast to backup/restore, but might have
  character encoding problem. But we tested that it worked with unicode
  characters. Need to find more corner cases. Does not support incremental
  backup.
- Physical backup: simplest and fastest, with no character encoding problem.
  But requires the DB to be offline when doing the backup and restore. Support
  incremental backup.

We found a promising container https://github.com/databacker/mysql-backup that
is well-maintained, and also the maintainer is responsive, but it only does
mysql backup. Whereas in our case, we need to back up LocalSettings.php,
data_accounting_config.json, and images.

We ended up choosing https://github.com/samwilson/MediaWiki_Backup (physical
backup) because it implemented setting the MediaWiki as read-only while the
backup process is happening. We made a fork of this at
https://github.com/rht/Mediawiki_Backup and can't vendor it because its license
is CC-BY-SA.
