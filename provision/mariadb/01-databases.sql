# See https://stackoverflow.com/questions/39204142/docker-compose-with-multiple-databases/39204865.
# create databases
CREATE DATABASE IF NOT EXISTS `my_wiki`;
CREATE DATABASE IF NOT EXISTS `eauth`;

GRANT ALL PRIVILEGES ON my_wiki.* TO 'wikiuser'@'%';
GRANT ALL PRIVILEGES ON eauth.* TO 'wikiuser'@'%';
