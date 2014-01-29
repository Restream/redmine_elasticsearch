class IssueSerializer < EventSerializer
  has_many :journals, serializer: EventSerializer
end
