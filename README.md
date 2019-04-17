Lucky7
==========

## Installation

Install MongoDB and MySQL on your system. Maybe use Vagrant (ask someone for a .box).

Install the necessary NodeJS packages for the project to run:

`sudo npm install`

Install Gulp globally:

`sudo npm install gulp -g`

Copy the config file and adjust your settings (ask around):

`cp config.json.sample config.json`

Copy the wallet files and adjust the daemon seetings for every wallet:

`cp config/wallets_config/btc.json.sample config/wallets_config/btc.json`

`cp config/wallets_config/btc.json.sample config/wallets_config/doge.json`

`cp config/wallets_config/btc.json.sample config/wallets_config/ltc.json`

Force compile all the assets:

`GULP_FORCE=true gulp digest_assets; gulp styles; gulp scripts; gulp coffee`

Create the app databases:

`mysql> create database satoshibet_dev;
`mysql> create database satoshibet_test;

Create the database schema:

`cake db:create_tables

Start the app (http://localhost:5000):

`node app.js`

Start the Casino API:

`node casino.js`

Start the Admin module  (http://localhost:6989):

`node admin.js`

## Tasks

To compile only the styles:

`GULP_FORCE=true gulp styles`

To compile only the frontend scripts:

`GULP_FORCE=true gulp scripts`

To compile only the backend `coffee` files:

`gulp coffee`

While working, please let Gulp compile all the assets for you in case of any changes:

`gulp` or `gulp watch`

## Tests

Hit the `npm test` command to run the entire suite.
