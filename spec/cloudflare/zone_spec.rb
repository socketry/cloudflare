
RSpec.describe "Cloudflare DNS Zones" do
  include_context Cloudflare::RSpec::Connection

  it "should list zones" do
    zones = connection.zones.all

    expect(zones).to be_any
  end

  describe Cloudflare::DNSRecords, order: :defined do
    let(:zone) {connection.zones.all.first}
    let(:name) {"test"}

    # it "should create dns record" do
    # response = zone.dns_records.post({
    # type: "A",
    # name: name,
    # content: "127.0.0.1",
    # ttl: 240,
    # proxied: false
    # }.to_json, content_type: 'application/json')

    # expect(response).to be_successful

    # result = response.result
    # expect(result).to include(:id, :type, :name, :content, :ttl)
    # end

    # it "should delete dns record" do
    # dns_records = zone.dns_records.all

    # expect(dns_records).to be_any

    # dns_records.each do |record|
    # response = record.delete
    # expect(response).to be_successful
    # end
    # end
  end

  describe Cloudflare::FirewallRules, order: :defined do
    let(:zone) {connection.zones.all.first}
    let(:name) {"test"}
    record = nil

    it "should create firewall rules" do

      ['block', 'challenge', 'whitelist'].each do |mode|
        response = zone.firewall_rules.set(mode,'123.123.123.123', "gemtest")
        expect(response).to be_successful

        result = response.result
        expect(result).to include(:id, :mode, :notes, :configuration)
        expect(result[:mode]).to eq mode
        record = result
      end
      puts record.inspect
    end
    it "should delete firewall rule" do
      response = zone.firewall_rules.unset(record)

      expect(response).to be_successful
    end
  end
end
