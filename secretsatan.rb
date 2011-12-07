#!/usr/bin/env ruby

# configurables
players = {
  'Sam' => 'sam@cruft.co',
  'Foo' => 'foo@cruft.co',
  'Bar' => 'bar@cruft.co',
  'Why' => 'why@cruft.co',
  'Zed' => 'zed@cruft.co',
}

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

# a Secret Santa participant
class Participant

  attr_reader :name, :email
  attr_accessor :recipient

  def initialize name, email
    @name = name
    @email = email
  end

# send this person the SS email
  def send_mail non_player = false
    if non_player then
      s = " to tell them to buy for #{@recipient.name}"
    end
    puts "Mailing #{@name}%s" % [s]
#    Pony.mail(
#      :to => @email,
#      :from => 'secretsanta@heyre.be',
#      :subject => 'Secret Santa',
#      :body => $message % [@name, @recipient.name],
#      :charset => 'utf-8'
#    )
  end
end

participants = Array.new

players.each do |k, v|
  participants << Participant.new(k, v)
end

participants.shuffle!

participants.length.times do |index|
  p = participants[index]

  i = index + (participants.length / 2).to_i
  if i >= participants.length then
    i = (participants.length - i).abs
  end

  p.recipient = participants[i]
  p.send_mail ARGV[0]
end
