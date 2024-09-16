# frozen_string_literal: true

RSpec.shared_context Cloudflare::Zone do
  include_context Cloudflare::Account

  let(:job_id) { JOB_ID }
  let(:names) { NAMES.dup }
  let(:name) { ZONE_NAME.dup }

  let(:zones) { connection.zones }

  let(:zone) { @zone = zones.find_by_name(name) || zones.create(name, account) }

  after do
    @zone.delete if defined? @zone
  end
end
