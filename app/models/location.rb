class Location < ActiveRecord::Base
  NB_RESULT_AUTOCOMPLETE = 10

  def self.find_for_autocompletion(term, categories = [], ignore_france = false, forbidden_location_ids = [], mobile = false)
    return if term.blank?
    normalized_name = mobile ? "#{term.normalize}%" : "%#{term.normalize}%"

    scope = Location.select('DISTINCT locations.*')
    scope = scope.joins('LEFT OUTER JOIN `synonyms` ON `synonyms`.`synonymable_id` = `locations`.`id` AND `synonyms`.`synonymable_type` = \'Location\'')
    scope = scope.where(['locations.normalized_name LIKE :normalized_name OR synonyms.normalized_name LIKE :normalized_name OR (locations.code = :name AND locations.category <> "city")', { normalized_name: normalized_name, name: term }]) unless term.blank?
    scope = scope.where("locations.id NOT IN(#{forbidden_location_ids.join(', ')})") if forbidden_location_ids && forbidden_location_ids.any?
    scope = scope.by_category(*categories) unless categories.blank?
    scope = scope.where('locations.id != ?', france.id) if ignore_france
    scope = scope.sort { |a, b| a.level_for_search <=> b.level_for_search }
    scope.first(NB_RESULT_AUTOCOMPLETE).map(&:to_autocomplete_attributes)
  end

  def to_autocomplete_attributes
    {
      location: {
        id: id,
        full_name: full_name,
        name: name,
        code_for_autocomplete: code_for_autocomplete,
        category: category,
        code: code,
        department_code: department? ? code : ''
      }
    }
  end
end
