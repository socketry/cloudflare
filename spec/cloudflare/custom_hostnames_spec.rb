
RSpec.xdescribe Cloudflare::CustomHostnames, order: :defined, timeout: 30 do
	include_context Cloudflare::Zone

	let(:domain) { "www#{ENV['TRAVIS_JOB_ID'] || rand(1..5)}.ourtest.com" }

	let(:record) { @record = zone.custom_hostnames.create(domain) }

	let(:custom_origin) do
		id = rand(1...100)
		id += (job_id * 100) if job_id.positive?
		subdomain = "origin-#{id}"
		@dns_record = zone.dns_records.create("A", subdomain, "1.2.3.4") # This needs to exist or the calls will fail
		"#{subdomain}.#{zone.name}"
	end

	after do
		if defined? @record
			expect(@record.delete).to be_success
		end

		if defined? @dns_record
			expect(@dns_record.delete).to be_success
		end
	end

	it 'can create a custom hostname record' do
		expect(record).to be_kind_of Cloudflare::CustomHostname
		expect(record.custom_metadata).to be_nil
		expect(record.hostname).to eq domain
		expect(record.custom_origin).to be_nil
		expect(record.ssl.method).to eq 'http'
		expect(record.ssl.type).to eq 'dv'
	end

	it 'can create a custom hostname record with a custom origin' do
		begin
			@record = zone.custom_hostnames.create(domain, origin: custom_origin)

			expect(@record).to be_kind_of Cloudflare::CustomHostname
			expect(@record.custom_metadata).to be_nil
			expect(@record.hostname).to eq domain
			expect(@record.custom_origin).to eq custom_origin
			expect(@record.ssl.method).to eq 'http'
			expect(@record.ssl.type).to eq 'dv'
		rescue Cloudflare::RequestError => e
			if e.message.include?('custom origin server has not been granted')
				skip(e.message) # This currently doesn't work but might start eventually: https://github.com/socketry/async-rspec/issues/7
			else
				raise
			end
		end
	end

	it 'can create a custom hostname record with different ssl options' do
		@record = zone.custom_hostnames.create(domain, ssl: { method: 'cname' })

		expect(@record).to be_kind_of Cloudflare::CustomHostname
		expect(@record.custom_metadata).to be_nil
		expect(@record.hostname).to eq domain
		expect(@record.custom_origin).to be_nil
		expect(@record.ssl.method).to eq 'cname'
		expect(@record.ssl.type).to eq 'dv'
	end

	it 'can create a custom hostname record with additional metadata' do
		metadata = { a: rand(1..10) }

		begin
			@record = zone.custom_hostnames.create(domain, metadata: metadata)

			expect(@record).to be_kind_of Cloudflare::CustomHostname
			expect(@record.custom_metadata).to eq metadata
			expect(@record.hostname).to eq domain
			expect(@record.custom_origin).to be_nil
			expect(@record.ssl.method).to eq 'http'
			expect(@record.ssl.type).to eq 'dv'
		rescue Cloudflare::RequestError => e
			if e.message.include?('No custom metadata access has been allocated for this zone')
				skip(e.message) # This currently doesn't work but might start eventually: https://github.com/socketry/async-rspec/issues/7
			else
				raise
			end
		end
	end

	it 'can look up an existing custom hostname by the hostname or id' do
		expect(zone.custom_hostnames.find_by_hostname(record.hostname).id).to eq record.id
		expect(zone.custom_hostnames.find_by_id(record.id).id).to eq record.id
	end

	context 'with existing record' do

		it 'returns the hostname when calling #to_s' do
			expect(record.to_s).to eq domain
		end

		it 'can update metadata' do
			metadata = { c: rand(1..10) }

			expect(record.custom_metadata).to be_nil

			begin
				record.update_settings(metadata: metadata)

				# Make sure the existing object is updated
				expect(record.custom_metadata).to eq metadata

				# Verify that the server has the changes
				found_record = zone.custom_hostnames.find_by_id(record.id)

				expect(found_record.custom_metadata).to eq metadata
				expect(found_record.hostname).to eq domain
				expect(found_record.custom_origin).to be_nil
			rescue Cloudflare::RequestError => e
				if e.message.include?('No custom metadata access has been allocated for this zone')
					skip(e.message) # This currently doesn't work but might start eventually: https://github.com/socketry/async-rspec/issues/7
				else
					raise
				end
			end
		end

		it 'can update the custom origin' do
			expect(record.custom_origin).to be_nil

			begin
				record.update_settings(origin: custom_origin)

				# Make sure the existing object is updated
				expect(record.custom_origin).to eq custom_origin

				# Verify that the server has the changes
				found_record = zone.custom_hostnames.find_by_id(record.id)

				expect(found_record.custom_metadata).to be_nil
				expect(found_record.hostname).to eq domain
				expect(found_record.custom_origin).to eq custom_origin
			rescue Cloudflare::RequestError => e
				if e.message.include?('custom origin server has not been granted')
					skip(e.message) # This currently doesn't work but might start eventually: https://github.com/socketry/async-rspec/issues/7
				else
					raise
				end
			end
		end

		it 'can update ssl information' do
				expect(record.ssl.method).to eq 'http'

				record.update_settings(ssl: { method: 'cname', type: 'dv' })

				# Make sure the existing object is updated
				expect(record.ssl.method).to eq 'cname'

				# Verify that the server has the changes
				found_record = zone.custom_hostnames.find_by_id(record.id)

				expect(found_record.custom_metadata).to be_nil
				expect(found_record.hostname).to eq domain
				expect(found_record.custom_origin).to be_nil
				expect(found_record.ssl.method).to eq 'cname'
		end

		context 'has an ssl section' do

			it 'wraps it in an SSLAttributes object' do
				expect(record.ssl).to be_kind_of Cloudflare::CustomHostname::SSLAttribute
			end

			it 'has some helpers for commonly used keys' do
				# Make sure our values exist before we check to make sure that they are returned correctly
				expect(record.value[:ssl].values_at(:method, :http_body, :http_url).compact).not_to be_empty
				expect(record.ssl.method).to be record.value[:ssl][:method]
				expect(record.ssl.http_body).to be record.value[:ssl][:http_body]
				expect(record.ssl.http_url).to be record.value[:ssl][:http_url]
			end

		end

		describe '#ssl_active?' do

			it 'returns the result of calling ssl.active?' do
				expected_value = double
				expect(record.ssl).to receive(:active?).and_return(expected_value)
				expect(record).not_to receive(:send_patch)
				expect(record.ssl_active?).to be expected_value
			end

			it 'returns the result of calling ssl.active? without triggering an update if force_update is true and the ssl is not in the pending_validation state' do
				expected_value = double
				expect(record.ssl).to receive(:active?).and_return(expected_value)
				expect(record.ssl.method).not_to be_nil
				expect(record.ssl.type).not_to be_nil
				expect(record.ssl.pending_validation?).to be false
				expect(record).not_to receive(:send_patch).with(ssl: { method: record.ssl.method, type: record.ssl.type })
				expect(record.ssl_active?(true)).to be expected_value
			end

			it 'returns the result of calling ssl.active? after triggering an update if force_update is true and the ssl is in the pending_validation state' do
				expected_value = double
				expect(record.ssl).to receive(:active?).and_return(expected_value)
				expect(record.ssl.method).not_to be_nil
				expect(record.ssl.type).not_to be_nil
				record.value[:ssl][:status] = 'pending_validation'
				expect(record).to receive(:send_patch).with(ssl: { method: record.ssl.method, type: record.ssl.type })
				expect(record.ssl_active?(true)).to be expected_value
			end

		end

	end
end
