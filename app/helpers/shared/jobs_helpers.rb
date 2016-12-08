# encoding: UTF-8
module Shared
  module JobsHelper
    def job_departement_codes(job)
      (job.locations || []).map do |location|
        if location.city?
          location.department
        elsif location.region?
          location.only_department_descendants
        else
          location
        end
      end.compact.flatten.map(&:code).uniq.join ', '
    end
  end
end