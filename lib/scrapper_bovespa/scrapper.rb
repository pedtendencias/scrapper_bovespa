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

	def get_company_data(cvm)
		source - Net::HTTP.get(URI("#{@base_query_address}#{cvm}"))
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
