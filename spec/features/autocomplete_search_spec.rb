require 'rails_helper'
require 'pry'

feature 'Autocomplete search in homepage and search page', js: true do
  NB_RESULT_AUTOCOMPLETE = 10
  TRIGGER_ESC_EVENT = "jQuery(document).trigger(jQuery.Event('keyup', {keyCode: 27}));".freeze
  context 'search occupations' do
    it 'should return only real occupations' do
      visit staff_root_path
      fill_in 'job_search_que', with: 'infir'
      wait_for_ajax
      result = page.all('.selectize-dropdown-content > .option').map(&:text)

      expect(result.length).to eq NB_RESULT_AUTOCOMPLETE
      expect(result.first).to eq 'Infirmier'
      expect(result.second).to eq 'Infirmier de santé au travail'
    end

    it 'should be able to search custom keywords without selecting from autocomplete' do
      visit staff_root_path
      fill_in 'job_search_que', with: 'infir'
      page.evaluate_script(TRIGGER_ESC_EVENT)
      page.all('.search__form__button').first.click

      expect(current_url =~ /infir/).not_to be nil
    end

    it 'should be listed only real occupations' do
      visit staff_root_path
      fill_in 'job_search_que', with: 'Infirmier diplomé d\'état'
      wait_for_ajax
      result = page.all('.selectize-dropdown-content > .option').map(&:text)

      expect(result).to include('Infirmier')
      expect(result).to include('Cadre Infirmier')
    end

    it 'should be listed with company names' do
      visit staff_root_path
      fill_in 'job_search_que', with: 'korian'
      wait_for_ajax
      result = page.all('.selectize-dropdown-content > .option').map(&:text)

      expect(result.first).to eq 'Groupe Korian'
    end

    it 'should be able to select value from autocomplete' do
      visit staff_root_path
      fill_in 'job_search_que', with: 'infir'
      wait_for_ajax

      page.all('.selectize-dropdown-content > .option')[0].click
      expect(page.all('.selectize-input > .item')[0].text).to eq 'Infirmier'

      page.all('.search__form__button').first.click
      expect(current_url =~ /Infirmier/).not_to be nil
    end

    it 'should be listed of locations by code' do
      visit staff_root_path
      fill_in 'job_search_donde', with: '59'
      wait_for_ajax
      result = page.all('.selectize-dropdown-content > .option').map(&:text)

      expect(result.first).to eq 'Nord'
      expect(result.length).to eq NB_RESULT_AUTOCOMPLETE
    end

    it 'should be listed of locations by name' do
      visit staff_root_path
      fill_in 'job_search_donde', with: 'paris'
      wait_for_ajax
      result = page.all('.selectize-dropdown-content > .option').map(&:text)

      expect(result.first).to eq 'Paris'
    end
  end
end
