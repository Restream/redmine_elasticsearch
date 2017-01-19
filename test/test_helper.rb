require File.expand_path(File.dirname(__FILE__) + '../../../../test/test_helper')

# Perform all operations without Resque while testing
require 'workers/indexer'
module Workers
  class Indexer
    class << self
      def perform_async(options)
        perform(options)
      end
    end
  end
end
