# encoding: UTF-8

module Controllers
  module AutocompleteQue
    extend ActiveSupport::Concern

    def autocomplete_que
      term = params[:term] || ''

      if current_affiliate
        occupation_scopes = current_affiliate.occupation_scopes
        brand = current_affiliate.brand
      else
        occupation_scopes = []
        brand = params[:brand_id] ? Brand.find(params[:brand_id]) : Brand.null_brand
      end

      results = brand.autocomplete_suggestions(term, occupation_scopes, current_site)

      respond_to do |format|
        format.json { render json: results.to_json, callback: params[:callback] }
      end
    end
  end
end
