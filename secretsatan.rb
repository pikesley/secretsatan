#!/usr/bin/env ruby

# configurables
players = {
  'bee' => 'bee@some.domain',
  'cee' => 'cee@some.domain',
  'dee' => 'dee@some.domain',
  'eee' => 'eee@some.domain',
  'eff' => 'eff@some.domain',
  'gee' => 'gee@some.domain'
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
# non_player = true means that the recipient will be printed along with the
# name of each player (we probably don't want this)
  def send_mail non_player = false
    if non_player then
      s = " to tell them to their recipient is #{@recipient.name}"
    end
    puts "Mailing #{@name}%s" % [s]

# send a mail. pony is ace
    Pony.mail(
      :to => @email,
      :from => $sender,
      :subject => 'Secret Santa',
      :body => $message % [@name, @recipient.name],
      :charset => 'utf-8'
    )
  end
end

# parse command-line options
options = {}
optparse = OptionParser.new do |opts|

# we only have one option: select this to see full output (i.e. who's got who)
  options[:non_player] = false
  opts.on('-n', '--non-player', "will tell you who's got who") do
    options[:non_player] = true
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
participants.each do |p|
  p.send_mail options[:non_player]
end
