RSpec.describe Cloudflare::CustomHostname::SSLAttribute::Settings do

	subject { described_class.new({}) }

	it 'has an accessor for ciphers' do
		ciphers = double
		expect(subject.ciphers).to be_nil
		subject.ciphers = ciphers
		expect(subject.ciphers).to be ciphers
	end

	it 'has a boolean accessor for http2' do
		expect(subject.http2).to be_nil
		expect(subject.http2?).to be false
		subject.http2 = true
		expect(subject.http2).to eq 'on'
		expect(subject.http2?).to be true
		subject.http2 = false
		expect(subject.http2).to eq 'off'
		expect(subject.http2?).to be false
		subject.http2 = 'on'
		expect(subject.http2).to eq 'on'
		expect(subject.http2?).to be true
		subject.http2 = 'off'
		expect(subject.http2).to eq 'off'
		expect(subject.http2?).to be false
	end

	it 'has an accessor for min_tls_version' do
		tls_version = double
		expect(subject.min_tls_version).to be_nil
		subject.min_tls_version = tls_version
		expect(subject.min_tls_version).to be tls_version
	end

	it 'has a boolean accessor for tls_1_3' do
		expect(subject.tls_1_3).to be_nil
		expect(subject.tls_1_3?).to be false
		subject.tls_1_3 = true
		expect(subject.tls_1_3).to eq 'on'
		expect(subject.tls_1_3?).to be true
		subject.tls_1_3 = false
		expect(subject.tls_1_3).to eq 'off'
		expect(subject.tls_1_3?).to be false
		subject.tls_1_3 = 'on'
		expect(subject.tls_1_3).to eq 'on'
		expect(subject.tls_1_3?).to be true
		subject.tls_1_3 = 'off'
		expect(subject.tls_1_3).to eq 'off'
		expect(subject.tls_1_3?).to be false
	end


end
