# Playing Around with Last.FM
[![CircleCI](https://circleci.com/gh/snood1205/playing_around_with_last_fm.svg?style=svg)](https://circleci.com/gh/snood1205/playing_around_with_last_fm)

This is a project to make a rails project to mess around with my last.fm data. You can pull from the last.fm API to update regularly. This is going to be experimenting with some cool ways to display the data.

## Getting Started
Assuming you already have ruby, postgres, and bundle installed just run the following commands to get everything all set-up (if you have trouble installing rails look into how to install nokogiri).
Steps:
1. Run `bin/setup` to set up the database and the `.env` file with your username and API key.  Note: The `.env` file is in `.gitignore` by default. (You can get a last.fm API key [here](https://www.last.fm/api/account/create)).
2. Run `bundle exec rails server` to start up the server.
