class AttachmentSerializer < ActiveModel::Serializer
  self.root = false

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

  def author
    object.author && object.author.to_s
  end

  def file
    Base64.encode64(File.read(object.diskfile)) if object.readable?
  end
end
