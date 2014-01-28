module Workers
  class Indexer < BaseWorker

    class IndexError < StandardError
    end

    queue :index_queue
    retry_count 3

    def self.defer(object)
      if object.id?
        params = { id: object.id, type: object.class.name }
        perform_async(params)
      end
    end

    def perform(options)
      id, type = options['id'], options['type']
      klass = type.classify.constantize
      begin
        document = klass.find id
        document.update_index
      rescue ActiveRecord::RecordNotFound
        klass.index.remove type, id
      rescue ::RestClient::Exception, Errno::ECONNREFUSED => e
        raise IndexError, e, e.backtrace
      end
    end

  end
end
