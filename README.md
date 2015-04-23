# Certificate Notary
[![Code Climate](https://codeclimate.com/github/stupidpupil/certificate_notary/badges/gpa.svg)](https://codeclimate.com/github/stupidpupil/certificate_notary)
[![Build Status](https://travis-ci.org/stupidpupil/certificate_notary.svg?branch=master)](https://travis-ci.org/stupidpupil/certificate_notary)

[Perspectives](http://perspectives-project.org/)-compatible SSL/TLS Certificate Notary

## Own server setup

```bash
# Install Postgres 9.2+ and Ruby 2.2+
git clone https://github.com/stupidpupil/certificate_notary.git
cd certificate_notary
bundle install --without testing
sudo -u postgres createuser mynotaryuser
sudo -u postgres createdb -O mynotaryuser certificate_notary_production
echo "NOTARY_PRIVATE_KEY=`rake generate_private_key`" >> .env
echo "RACK_ENV=production" >> .env
foreman start web
```

## Heroku setup
```bash
git clone https://github.com/stupidpupil/certificate_notary.git
cd certificate_notary
bundle install --without testing
heroku create
heroku config:add NOTARY_PRIVATE_KEY=`rake generate_private_key`
heroku addons:add heroku-postgresql:hobby-dev
git push heroku
```