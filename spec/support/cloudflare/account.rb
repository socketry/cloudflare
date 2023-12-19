# frozen_string_literal: true

RSpec.shared_context Cloudflare::Account do
  include_context Cloudflare::RSpec::Connection

  let(:account) do
    if ACCOUNT_ID
      connection.accounts.find_by_id(ACCOUNT_ID)
    else
      connection.accounts.first
    end
  end
end
