RSpec.describe Cloudflare::CustomHostname::SSLAttribute do

	accessors = [:cname, :cname_target, :http_body, :http_url, :method, :status, :type, :validation_errors]

	let(:original_hash) { {} }

	subject { described_class.new(original_hash) }

	accessors.each do |key|

		it "has an accessor for the #{key} value" do
			test_value = double
			expect(subject.send(key)).to be_nil
			original_hash[key] = test_value
			expect(subject.send(key)).to be test_value
		end

	end

	it '#active? returns true when the status is "active" and false otherwise' do
		expect(subject.active?).to be false
		original_hash[:status] = 'initializing'
		expect(subject.active?).to be false
		original_hash[:status] = 'pending_validation'
		expect(subject.active?).to be false
		original_hash[:status] = 'pending_deployment'
		expect(subject.active?).to be false
		original_hash[:status] = 'active'
		expect(subject.active?).to be true
	end

	it '#pending_validation? returns true when the status is "pending_validation" and false otherwise' do
		expect(subject.pending_validation?).to be false
		original_hash[:status] = 'initializing'
		expect(subject.pending_validation?).to be false
		original_hash[:status] = 'active'
		expect(subject.pending_validation?).to be false
		original_hash[:status] = 'pending_deployment'
		expect(subject.pending_validation?).to be false
		original_hash[:status] = 'pending_validation'
		expect(subject.pending_validation?).to be true
	end

	describe '#settings' do

		it 'should return a Settings object' do
			expect(subject.settings).to be_kind_of Cloudflare::CustomHostname::SSLAttribute::Settings
		end

		it 'initailizes the settings object with the value from the settings key' do
			settings = { min_tls_version: double }
			original_hash[:settings] = settings
			expect(subject.settings.min_tls_version).to be settings[:min_tls_version]
		end

		it 'initializes the settings object with a new hash if the settings key does not exist' do
			expected_value = double
			expect(original_hash[:settings]).to be_nil
			expect(subject.settings.min_tls_version).to be_nil
			expect(original_hash[:settings]).not_to be_nil
			original_hash[:settings][:min_tls_version] = expected_value
			expect(subject.settings.min_tls_version).to be expected_value
		end

		it 'updates the stored hash with values set on the settings object' do
			expected_value = double
			expect(subject.settings.min_tls_version).to be_nil
			subject.settings.min_tls_version = expected_value
			expect(original_hash[:settings][:min_tls_version]).to be expected_value
		end
	end

end
