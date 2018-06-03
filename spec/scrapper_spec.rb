require 'spec_helper'

RSpec.describe Scrapper do 
	it 'can extract an array of integer codes' do
		scrap = ScrapeCompanys.new()
		cvms = scrap.get_cvms()

		expect(cvms.class.to_s.downcase).to eq('array')
		expect(cvms.size > 0).to eq(true)
	end

	it 'can extract a complete company given a valid cvm' do
		scrap = ScrapeCompanys.new()
		data = scrap.get_company_data(1821)

		expect('something').to eq('other thing')
	end
end
