#!/usr/bin/ruby

require "pg"

@con = PG.connect :host => ARGV[0], :dbname => "postgres", :user => "postgres", :password => "qaninja"

def drop
  rs = @con.exec "DROP DATABASE IF EXISTS nflix;"
  puts rs
rescue PG::Error => e
  puts e.message
end

def create
  rs = @con.exec "CREATE DATABASE nflix" \
                 " WITH" \
                 " OWNER = postgres"
  puts rs
rescue PG::Error => e
  puts e.message
end

drop
create

@con.close if @con
