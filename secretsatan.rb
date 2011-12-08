#!/usr/bin/env ruby

# configurables
players = {
  'Bee' => 'bee@some.domain',
  'Cee' => 'cee@some.domain',
  'Dee' => 'dee@some.domain',
  'Eee' => 'eee@some.domain',
  'Eff' => 'eff@some.domain',
  'Gee' => 'gee@some.domain'
}

$sender = 'secretsanta@your.domain'

$budget = 5

$message = <<EOF
%s,

Your Secret Santa pick is %s. The budget is £#{$budget}.

Ta

Secret Santa
EOF

###############################

require 'rubygems'
require 'pony'
require 'optparse'

# a Secret Santa participant
class Participant

  attr_reader :name, :email
  attr_accessor :recipient

  def initialize name, email
    @name = name
    @email = email
  end

# send this person the SS email
  def send_mail options

# usually we *don't* want to know who's got who, but maybe we do
    if options[:non_player] or options[:dry_run] then
      s = " to tell them to their recipient is #{@recipient.name}"
    end

    puts "Mailing #{@name}%s" % [s]

# send a mail. pony is ace
    if not options[:dry_run] then
      Pony.mail(
        :to => @email,
        :from => $sender,
        :subject => 'Secret Santa',
        :body => $message % [@name, @recipient.name],
        :charset => 'utf-8'
      )
    end
  end
end

# parse command-line options
options = {}
optparse = OptionParser.new do |opts|

# select this to see full output (i.e. who's got who)
  options[:non_player] = false
  opts.on('-n', '--non-player', "will tell you who's got who") do
    options[:non_player] = true
  end

# just a rehearsal
  options[:dry_run] = false
  opts.on('-t', '--dry-run', "don't actually send any mails") do
    options[:dry_run] = true
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

# parse options
begin optparse.parse!
rescue OptionParser::InvalidOption => e
  puts e
  exit 1
end

# real business starts here
#
# pack the players into an array
participants = Array.new
players.each do |k, v|
  participants << Participant.new(k, v)
end

# mix 'em up
participants.shuffle!

# run through the list
participants.length.times do |index|

# get the participant
  p = participants[index]

# configure the offset (so e.g. participant #1 will get #2 as their SS)
  i = index + 1

# this wraps us back around when we're about to fall off the end of the array
  if i >= participants.length then
    i = (participants.length - i).abs
  end

# now assign this participant a recipient
  p.recipient = participants[i]
end

# now shuffle again (so we can't extract any clues from the console output)
participants.shuffle!

# and send the mails
if options[:dry_run] then
  puts "DRY RUN! NOT REALLY SENDING ANYTHING!"
end
participants.each do |p|
  p.send_mail options
end
