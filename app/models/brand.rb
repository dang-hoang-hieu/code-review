class Brand < ActiveRecord::Base
  has_many :domains
  has_many :occupation_brands
  has_many :occupations, through: :occupation_brands

  has_many :product_brands
  has_many :products, through: :brands

  def staff?
    code == 'staff'
  end

  def promed?
    code == 'promed'
  end

  def null_brand?
    false
  end

  def autocomplete_suggestions(term, occupation_scopes, domain)
    if staff? || null_brand?
      Staff::AutocompleteSuggestions.for(term, occupation_scopes, domain)
    elsif promed?
      Promed::AutocompleteSuggestions.for(term)
    end
  end
end
