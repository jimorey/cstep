source "https://rubygems.org"

#path 'components' do
  gem 'sinatra'
  gem 'prawn', '~> 2.1'
  gem 'prawn-table'
  #gem 'rubygems'
  gem 'data_mapper'
  gem 'nokogiri'
  gem 'json'
  gem 'sinatra-flash', '~> 0.3.0'

  #gem 'sqlite3', '~>1.3.12' this is commented out as:
  #1. This gem is hard to install on windows as it is a C gem.
  #2. The goal is to change the DB to postgreSQL for heroku compatability anyway.
  #gem 'dm-sqlite-adapter'
  #the adapter which allows DataMapper to communicate to the with the SQLite3 DB.

  gem 'pg' #this is the gem for postgreSQL to replace SQLite3
  gem 'dm-postgres-adapter' #the adapter which allows DataMapper to communicate to the with the postgreSQL DB
  gem 'activerecord'
  gem 'sinatra-activerecord'

  gem 'net-ldap', '~> 0.15.0'
  #gem 'yaml'
  gem 'simple_xlsx_reader'
  gem 'tux'
