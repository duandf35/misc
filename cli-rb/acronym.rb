#!/usr/bin/env ruby

require 'leveldb'

DEF_ACR_FILE = "#{ENV['HOME']}/.acronym".freeze

@db = LevelDB::DB.new(DEF_ACR_FILE)

def list
  @db.each do |k, v|
    v, = v.split(',')
    puts "#{k.ljust(20)} | #{v.rjust(50)}"
  end
end

def find(acronym)
  definition = @db.get(acronym) || @db.get(acronym.upcase)
  if definition
    puts "#{acronym}\n#{definition.split(',').join("\n")}"
  else
    puts "Unknown acronym: #{acronym}"
  end
end

def append(acronym, val)
  exist_val = @db.get(acronym)
  exist_val = if exist_val
                "#{exist_val},#{val}"
              else
                val
              end
  add(acronym, exist_val)
end

def add(acronym, definition)
  @db.put(acronym.strip, definition.strip)
end

def delete(acronym)
  @db.delete(acronym)
end

def help
  puts ['-h                 | help',
        '-a <acronym> <def> | add acronym',
        '-f <acronym>       | find acronym definition',
        '-d <acronym>       | delete acronym'].join("\n")
end

def main
  args = ARGV
  while args.any?
    opt = args.shift
    case opt
    when '-l'
      list
    when '-a'
      append(args.shift, args.shift) if args.size > 1
    when '-f'
      find(args.shift) if args.any?
    when '-d'
      delete(args.shift) if args.any?
    else
      help
    end
  end
end

main
