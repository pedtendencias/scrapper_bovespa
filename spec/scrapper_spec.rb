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

		expect(data[:nome]).to eq('ITAUBANK LS')
		expect(data[:cnpj]).to eq('43.443.464/0001-85')
		expect(data[:site]).to eq('www.itau.com.br')
		expect(data[:balanco_patrimonial].class.to_s).to eq('Hash')
		expect(data[:balanco_patrimonial][:ativo_permanente].class.to_s).to eq('Array')
		expect(data[:demonstracao_do_resultado].class.to_s).to eq('Hash')
		expect(data[:demonstracao_do_resultado][:resultado_operacional].class.to_s).to eq('Array')
		expect(data[:demonstracao_do_fluxo_de_caixa].class.to_s).to eq('Hash')
		expect(data[:demonstracao_do_fluxo_de_caixa][:aumento_de_caixa_e_equivalentes].class.to_s).to eq('Array')
		expect(data[:posicao_acionaria].class.to_s).to eq('Hash')
		expect(data[:posicao_acionaria][:total].class.to_s).to eq('Array')
		expect(data[:composicao_capital_social].class.to_s).to eq('Hash')
		expect(data[:composicao_capital_social][:total].class.to_s).to eq('String')
	end
end
