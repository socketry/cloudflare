
RSpec.describe "Cloudflare DNS Zones" do
  include_context Cloudflare::RSpec::Connection

  it "should list zones" do
    zones = connection.zones.all

    expect(zones).to be_any
  end

  describe Cloudflare::DNSRecords, order: :defined do
    let(:zone) {connection.zones.all.first}
    let(:name) {"test"}
    let(:ip) {"123.123.123.123"}
    record = nil

    it "should get all records" do
        result = zone.dns_records.all

        puts "===> #{result.size} records returned"
        expect(result.size).to be > 0
    end


    it "should create dns record" do
      response = zone.dns_records.post({
        type: "A",
        name: name,
        content: ip,
        ttl: 240,
        proxied: false
      }.to_json, content_type: 'application/json')

      expect(response).to be_successful

      result = response.result
      expect(result).to include(:id, :type, :name, :content, :ttl)
      record = result
    end

    it "should delete dns record" do
      dns_record = zone.dns_records.find_by_id(record[:id])
      response = dns_record.delete
      expect(response).to be_successful
    end
  end

  describe Cloudflare::FirewallRules, order: :defined do
    let(:zone) {connection.zones.all.first}
    let(:name) {"test"}
    let(:ip) {'123.123.123.123'}
    let(:ip2) {'123.123.123.124'}
    let(:notes) {"gemtest"}
    record = nil
    before do
      response = zone.firewall_rules.set('block', ip2, notes)
    end

    it "should get all rules" do
        result = zone.firewall_rules.all

        puts "===> #{result.size} records returned"
        expect(result.size).to be > 0
    end

    it "should create firewall rules for 'block', 'challenge', 'whitelist'" do

      [:block, :challenge, :whitelist].each do |mode|
        response = zone.firewall_rules.set(mode, ip, notes)
        expect(response).to be_successful

        result = response.result
        expect(result).to include(:id, :mode, :notes, :configuration)
        expect(result[:mode]).to eq mode.to_s
        record = result
      end
    end

    it "should delete firewall rule by record" do
      response = zone.firewall_rules.unset('id', record[:id])

      expect(response).to be_successful
    end

    it "should delete firewall rule by ip" do
      response = zone.firewall_rules.unset('ip', ip2)

      expect(response).to be_successful
    end
  end
end
