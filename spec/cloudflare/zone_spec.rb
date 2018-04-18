# frozen_string_literal: true

RSpec.describe 'Cloudflare DNS Zones' do
  include_context Cloudflare::RSpec::Connection

  before(:each) {stub_get_zones}
  it 'should list zones' do
    zones = connection.zones.all
    expect(zones).to be_any
  end

  describe Cloudflare::DNSRecords, order: :defined do
    before(:each) {
      stub_get_zones
      stub_get_dns_records
      stub_create_dns_record
      stub_delete_dns_record '123123123'
      stub_find_dns_record_by_id '123123123'
    }
    let(:zone) {connection.zones.all.first}

    let(:name) {'test'}
    let(:ip) {'123.123.123.123'}

    it 'should get all records' do
      result = zone.dns_records.all
      expect(result.size).to be > 0
    end

    it 'should create dns record' do
      response = zone.dns_records.post({
                                           type: 'A',
                                           name: name,
                                           content: ip,
                                           ttl: 240,
                                           proxied: false
                                       }.to_json, content_type: 'application/json')

      expect(response).to be_successful

      result = response.result
      expect(result).to include(:id, :type, :name, :content, :ttl)
    end

    before do
      stub_get_dns_record '1231231234'
      stub_delete_dns_record '1231231234'
    end
    it 'should delete dns record' do
      dns_record = zone.dns_records.find_by_id('1231231234')
      response = dns_record.delete
      expect(response).to be_successful
    end
  end

  describe Cloudflare::FirewallRules, order: :defined do
    let(:zone) {connection.zones.all.first}
    let(:name) {'test'}
    let(:ip) {'123.123.123.123'}
    let(:ip2) {'123.123.123.124'}
    let(:notes) {'gemtest'}
    before do
      stub_get_zones
      stub_create_rule 'block', ip2, notes
      stub_list_access_rules 1, [cf_access_rule('whitelist', ip, notes)]
      stub_list_access_rules 2, [cf_access_rule('block', ip2, notes)]
    end

    it 'should get all rules' do
      result = zone.firewall_rules.all

      puts "===> #{result.size} records returned"
      expect(result.size).to be > 0
    end

    %i[block challenge whitelist].each do |mode|
      it "should create a #{mode} rule" do
        stub_create_rule mode, ip, notes
        response = zone.firewall_rules.set(mode, ip, notes)

        expect(response).to be_successful

        result = response.result
        expect(result).to include(:id, :mode, :notes, :configuration)
        expect(result[:mode]).to eq mode.to_s
      end
    end
    before do
      stub_get_access_rule('123123123')
      stub_delete_access_rule(id: '123123123')
    end
    it 'should delete firewall rule by record' do
      response = zone.firewall_rules.unset('id', '123123123')
      assert_requested stub_get_access_rule('123123123')
      assert_requested stub_delete_access_rule(id: '123123123')
      expect(response).to be_successful
    end

    before do
      stub_find_rule_by_value ip: ip2
      stub_get_access_rule '123123124'
      stub_delete_access_rule id: '123123124'
    end
    it 'should delete firewall rule by ip' do
      response = zone.firewall_rules.unset('ip', ip2)
      expect(response).to be_successful
    end
  end
end
