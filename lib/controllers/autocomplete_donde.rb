# encoding: UTF-8

module Controllers
  module AutocompleteDonde
    extend ActiveSupport::Concern
    def autocomplete_donde
      locations = Location.find_for_autocompletion(params[:term], params[:c], params[:ifr], params[:forbidden_location_ids], source.mobile?)
      locations = if current_site.staff?
                    locations.map do |location|
                      {
                        search_value: location[:location][:full_name],
                        department_code: location[:location][:department_code],
                        name_and_synonyms: location[:location][:full_name]
                      }
                    end
                  else
                    locations.map{ |result| result[:location][:full_name] }
                  end

      respond_to do |format|
        format.json { render json: locations.to_json, callback: params[:callback] }
      end
    end
  end
end
