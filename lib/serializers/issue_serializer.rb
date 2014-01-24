class IssueSerializer < ActiveModel::Serializer

  self.root = false

  attributes :id, :subject, :description

  #has_many :notes, serializer: JournalNotesSerializer
end
