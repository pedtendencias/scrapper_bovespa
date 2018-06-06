require 'net/http'
require 'json'
require_relative 'item.rb'

class Scrapper
	def initialize(login="", senha="")
		@login = login
		@senha = senha
		@webservice = "http://webfeeder.cedrofinances.com.br"
	end

	def connect_to_bovespa()
		post("SignIn?login=#{@login}&password=#{senha}")
	end

	def get(command)
		Net::HTTP.get(URI("#{@webservice}/#{command}"))
	end

	def post(command)
		uri = URI("#{@webservice}/#{command}")
		request = Net::HTTP::Post.new(uri)
		Net::HTTP.start(uri.hostname, uri.port)
	end

	def get_quotes(ticker)
		#has to handle invalid data, need to test that
		eval(get("services/quotes/quote/#{ticker}"))
	end

	def get_company_data()
	end
end

class ScrapeCompanys
	def initialize()
		@base_query_address = "http://bvmf.bmfbovespa.com.br/pt-br/mercados/acoes/empresas/ExecutaAcaoConsultaInfoEmp.asp?CodCVM="
		@code_source = "http://cvmweb.cvm.gov.br/SWB/Sistemas/SCW/CPublica/CiaAb/FormBuscaCiaAbOrdAlf.aspx?LetraInicial="
	end

	def extract_simple_text(source)
		simplified = source[0].reverse
		simplified = simplified[(simplified.index(">dt/<") + 5)..(simplified.index(">dt<") - 1)]
		simplified.reverse
	end

	def extract_site(source)
		simplified = source[0].reverse
		simplified = simplified[(simplified.index(">a/<") + 4)..(simplified.index(">\"") - 1)]
		simplified.reverse
	end

	def extract_par_th(source)
		puts source
	end

	def get_company_data(cvm)
		output = {}
		source = Net::HTTP.get(URI("#{@base_query_address}#{cvm}"))
		output[:nome] = extract_simple_text(source.scan(/Nome de Preg.+\r\n.+\<\/td\>/))
		output[:cnpj] = extract_simple_text(source.scan(/CNPJ.+\r\n.+\<\/td\>/))
		output[:site] = extract_site(source.scan(/Site:\<\/td\>\r\n.+\<\/a\>/))

		cabecalho = extract_par_th(source.scan(/Balan.o Patrimonial.+\r\n.+\r\n.+\<\/th\>/))
=begin
		ativo_permanente = source.scan(/Ativo Permanente\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		ativo_total = source.scan(/Ativo Total\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		patrimonio_liquido = source.scan(/Patrimônio Líquido\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)

		#separa os dados em a e b
		output[:balanco_patrimonial] = {ativo_permanente: [ativo_p_a, ativo_p_b],
																		ativo_total: [ativo_t_a, ativo_t_b],
																		patrimonio_liquido: [patrimonio_a, patrimonio_b],
																		periodo: [data_a, data_b]}

		cabecalho_demonstracao_resultado = source.scan(/Demonstração do Resultado - Não-Consolidado\:\<\/th\>\<th\>.+\<\/th\>\<th\>.+\<\/th\>/)
		receitas = source.scan(/Receitas da Intermediação Financeira\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		resultado_bruto = source.scan(/Resultado Bruto da Intermediação Financeira\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		resultado_operacional = source.scan(/Resultado Operacional\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		lucro = source.scan(/Lucro (Prejuízo) Líquido\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)

		#separa os dados em a e b
		output[:demonstracao_do_resultado] = {receitas_da_intermediacao_financeira: [receitas_i_a, receitas_i_b],
																					resultado_bruto_da_intermediacao_financeira: [resultado_b_a, resultado_b_b],
																					resultado_operacional: [resultado_a, resultado_b],
																					lucro_liquido: [lucro_a, lucro_b],
																					periodo: [periodo_a, periodo_b]}

		
		cabecalho_fluxo_caixa = source.scan(/Demonstração do Fluxo de Caixa - Não-Consolidado\:\<\/th\>\<th\>.+\<\/th\>\<th\>.+\<\/th\>/)
		operacionais = source.scan(/Atividades Operacionais\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		investimento = source.scan(/Atividades de Investimento\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		financiamento = source.scan(/Atividades de Financiamento\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		variacao = source.scan(/Variação Cambial sobre Caixa e Equivalentes\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)
		aumento = source.scan(/Aumento (Redução) de Caixa e Equivalentes\:\<\/td\>\<td\>.+\<\/td\>\<td\>.+\<\/td\>/)

		#separa os dados em a e b
		output[:demonstracao_do_fluxo_de_caixa] = {atividades_operacionais: [operacionais_a, operacionais_b],
		atividades_de_investimento: [investimento_a, investimento_b],
		atividades_de_financiamento: [financiamento_a, financiamento_b],
		variacao_cambial_sobre_caixa_e_equivalentes: [variacao_a, variacao_b],
		aumento_de_caixa_e_equivalentes: [aumento_a, aumento_b],
		periodo: [periodo_a, periodo_b]}	
=end
		output
	end

	def get_cvms()
		cvms = []
		guidelines = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 
									'H', 'I', 'J', 'K', 'L', 'M', 'N', 
									'O', 'P', 'Q', 'R', 'S', 'T', 'U', 
									'V', 'W', 'Y', 'X', 'Z', '0', '1', 
									'2', '3', '4', '5', '6', '7', '8', '9']

		guidelines.each do |k|
			source = Net::HTTP.get(URI("#{@code_source}#{k}")).scan(/\>[0-9]+\<\/a\>/)

			source.each do |str|
				sub = str[1..(str.length - 5)]
				if sub.length > 1 then
					cvms << sub.to_i
				end
			end
	
			source = nil
		end

		puts cvms.size
		cvms
	end
end
