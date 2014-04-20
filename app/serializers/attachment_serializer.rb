class AttachmentSerializer < ActiveModel::Serializer
  self.root = false

  MAX_SIZE = 1.megabyte

  SUPPORTED_MIME_PATTERNS = %w{
    application\/json
    application\/msword
    application\/pdf
    application\/vnd.ms-excel
    application\/vnd.ms-powerpoint
    application\/vnd.ms-publisher
    application\/vnd.oasis.opendocument.spreadsheet
    application\/vnd.oasis.opendocument.text
    application\/vnd.openxmlformats-officedocument
    application\/vnd.openxmlformats-officedocument
    application\/vnd.openxmlformats-officedocument
    application\/x-javascript
    application\/x-ruby
    application\/x-sh
    application\/x-shellscript
    application\/x-yaml
    application\/xml
    message\/rfc822
    text\/
  }

  attributes :created_on,
             :filename,
             :description,
             :author,
             :filesize,
             :digest,
             :downloads,
             :author_id,
             :content_type,
             :file

  class << self
    def supported?(object)
      content_type_supported?(object.content_type) &&
          object.filesize > 0 &&
          object.filesize < MAX_SIZE &&
          object.readable?
    end

    def content_type_supported?(content_type)
      SUPPORTED_MIME_PATTERNS.any? { |pattern| content_type =~ Regexp.new(pattern, true) }
    end
  end

  def author
    object.author && object.author.to_s
  end

  def file
    Base64.encode64(File.read(object.diskfile))
  end
end
