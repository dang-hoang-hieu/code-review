# encoding: utf-8
module Staff
  class AutocompleteSuggestions
    N_RESULTS = 10

    attr_reader :term, :occupation_scopes, :domain

    def self.for(term, occupation_scopes, domain)
      new(term, occupation_scopes, domain).search
    end

    def initialize(term, occupation_scopes, domain)
      @term, @occupation_scopes = term, occupation_scopes
      @domain = if domain.staffsante?
                  Domain::STAFFSANTE_AGGREGATE
                elsif domain.staffsocial?
                  Domain::STAFFSOCIAL_NAME
                else
                  Domain::PROMED_NAME
                end
    end

    def search
      return [] if term.normalize.nil?

      search_occupations + search_entities
    end

    def search_occupations
      normalized_term = term.normalize

      scope_conditions = []
      occupation_scopes.each do |occupation|
        scope_conditions << "occupations.lft BETWEEN #{occupation.lft} AND #{occupation.rgt}"
      end
      Occupation.select('occupations.*, synonyms.name AS synonyme_name')
        .joins("LEFT JOIN `synonyms` ON `synonyms`.`synonymable_id` = `occupations`.`id` AND `synonyms`.`synonymable_type` = 'Occupation'") # left join si mot pas synonyme
        .joins(:site)
        .where(category: [:profession, :specialty])
        .where(domains: { name: domain })
        .where('occupations.normalized_name LIKE :term OR synonyms.normalized_name LIKE :term', term: "%#{normalized_term}%")
        .group('occupations.id')
        .where(scope_conditions.join(' OR '))
        .limit(N_RESULTS).map do |result|
          {
            search_value: result.name,
            name_and_synonyms: [result.name, result.synonyme_name].join(' ')
          }
        end
    end

    def search_entities
      Entity.autocomplete_suggestions(term, false)
    end
  end
end
