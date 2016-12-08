class Entity < ActiveRecord::Base
  AUTOCOMPLETE_RESULT_LIMIT = 10

  has_many :subentities, class_name: 'Entity',
    foreign_key: 'group_id',
    dependent: :nullify,

  scope :has_at_least_one_online_job, -> { joins(:jobs).where("jobs.state = 'online'") }

  def self.autocomplete_suggestions(term, only_groups = false)
    sql_term = '%' + term + '%'
    scope = select('DISTINCT entities.*').has_at_least_one_online_job.where( 'entities.name LIKE ?', sql_term )
    scope = scope.joins(:subentities) if only_groups
    scope.limit(AUTOCOMPLETE_RESULT_LIMIT).map do |result|
      {
        search_value: result.name,
        name_and_synonyms: result.name
      }
    end
  end
end
