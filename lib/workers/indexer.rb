module Workers
  class Indexer < BaseWorker

    class IndexError < StandardError
    end

    queue :index_queue
    retry_count 3

    def self.defer(object_or_class)
      if object_or_class.is_a? Class
        params = { type: object_or_class.name }
        perform_async(params)
      elsif object.id?
        params = { id: object_or_class.id, type: object_or_class.class.name }
        perform_async(params)
      end
    end

    def perform(options)
      id, type = options['id'], options['type']
      id.nil? ? update_class_index(type) : update_instance_index(type, id)
    end

    def update_class_index(type)
      klass = type.classify.constantize
      klass.update_index
    rescue ::RestClient::Exception, Errno::ECONNREFUSED => e
      raise IndexError, e, e.backtrace
    end

    def update_instance_index(type, id)
      klass = type.classify.constantize
      document = klass.find id
      document.update_index
    rescue ActiveRecord::RecordNotFound
      klass.index.remove type, id
    rescue ::RestClient::Exception, Errno::ECONNREFUSED => e
      raise IndexError, e, e.backtrace
    end
  end
end
