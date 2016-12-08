require 'rails_helper'
require 'pry'

feature 'Show jobs in recruiter page' do
  MAX_JOB = 5
  context "there are more #{MAX_JOB} jobs" do
    before do
      @entity = create :entity_for_job_list
      (MAX_JOB + 1).times.each { create :online_job, entity: @entity }
    end
    it "should show only #{MAX_JOB} jobs" do
      visit staff_entity_seo_path(@entity)
      expect(page.all('table tr a').length).to eq MAX_JOB
    end
  end

  context "there are only #{MAX_JOB - 1} jobs" do
    before do
      @entity = create :entity_for_job_list
      (MAX_JOB - 1).times.each { create :online_job, entity: @entity }
    end
    it "should show only #{MAX_JOB - 1} jobs" do
      visit staff_entity_seo_path(@entity)
      expect(page.all('table tr a').length).to eq MAX_JOB - 1
    end
  end

  context 'there are no jobs' do
    before do
      @entity = create :entity_for_job_list
    end
    it 'should not render list block' do
      visit staff_entity_seo_path(@entity)
      expect(page).not_to have_text(I18n.t('staff.entities.show.latest_jobs_title'))
    end
  end

  context 'click on job offer link' do
    before do
      @entity = create :entity_for_job_list
      (MAX_JOB + 1).times.each { create :online_job, entity: @entity }
    end
    it 'should redirect to job offer page' do
      visit staff_entity_seo_path(@entity)
      first_url = job_seo_path @entity.online_job_offers_on(Domain.find_by_name('staffsante')).first
      page.all('table > tr')[0].find('a').click
      sleep 1
      expect(current_url).to eq first_url
    end
  end

  context 'click on job list the button' do
    before do
      @entity = create :entity_for_job_list
      (MAX_JOB + 1).times.each { create :online_job, entity: @entity }
    end
    it 'should redirect to first result page' do
      visit staff_entity_seo_path(@entity)
      expect(page.find('a.button--uppercase--no-spacing')['href']).to eq staff_job_search_seo_path(quoi: @entity.name, types_contrat: :job_offer)
    end
  end
end