
require 'drb/drb'
require './lib/spam'

DRb.start_service('druby://localhost:50010', Spam.new)
Kernel.loop do
  sleep 1
end

exit
