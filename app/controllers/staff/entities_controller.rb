# encoding: UTF-8
module Staff
  class EntitiesController < BaseController
    before_filter :find_entity, :redirect_if_hidden, only: :show
    caches_action :sitemap, expires_in: 1.day

    def show
      @all_jobs = @entity.online_job_offers_on current_site
      if @entity.accepts_unsolicited_applications?
        @unsolicited_application = @entity.unsolicited_applications.build

        if candidate_signed_in?
          @unsolicited_application.candidate = current_candidate
        else
          candidate = @unsolicited_application.build_candidate
          candidate.build_profile
        end
      end
      respond_to do |format|
        format.html do
          create_hit
          @latest_jobs = @all_jobs.limit(Job::NB_RECENT_PER_ENTITY)
        end
      end
    end

    private
    def find_entity
      @entity  = Entity.find params[:id]
      seo_path = staff_entity_seo_path(@entity)

      redirect_to seo_path, status: :moved_permanently if request.path.index(seo_path) != 0
    end

    def create_hit
      @entity.hits.create({occured_at: Time.now, candidate_id: current_candidate.try(:id) })
    end

    def redirect_if_hidden
      redirect_to staff_root_path if @entity.unseen? && !@entity.has_online_jobs? && !@entity.can_publish_jobs?
    end
  end
end