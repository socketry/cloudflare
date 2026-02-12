# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "cloudflare/request_error"

describe Cloudflare::RequestError do
	with ".error_string_for with hash containing :error key" do
		it "returns the error value" do
			value = {error: "Something went wrong"}
			result = Cloudflare::RequestError.error_string_for(value)
			
			expect(result).to be == "Something went wrong"
		end
	end
	
	with ".error_string_for with hash containing :errors key" do
		it "returns comma-separated error messages" do
			value = {
				errors: [
					{message: "First error"},
					{message: "Second error"},
					{message: "Third error"}
				]
			}
			result = Cloudflare::RequestError.error_string_for(value)
			
			expect(result).to be == "First error, Second error, Third error"
		end
		
		it "handles empty errors array" do
			value = {errors: []}
			result = Cloudflare::RequestError.error_string_for(value)
			
			expect(result).to be == ""
		end
	end
	
	with ".error_string_for with plain string" do
		it "returns inspected value" do
			value = "Plain error message"
			result = Cloudflare::RequestError.error_string_for(value)
			
			expect(result).to be == "\"Plain error message\""
		end
	end
	
	with ".error_string_for with other types" do
		it "returns inspected value for integer" do
			value = 42
			result = Cloudflare::RequestError.error_string_for(value)
			
			expect(result).to be == "42"
		end
		
		it "returns inspected value for nil" do
			value = nil
			result = Cloudflare::RequestError.error_string_for(value)
			
			expect(result).to be == "nil"
		end
	end
	
	with "#initialize" do
		it "creates error with hash containing :error key" do
			request = "GET /api/v1/test"
			value = {error: "Authentication failed"}
			error = Cloudflare::RequestError.new(request, value)
			
			expect(error.message).to be == "GET /api/v1/test: Authentication failed"
			expect(error.value).to be == value
		end
		
		it "creates error with hash containing :errors key" do
			request = "POST /api/v1/test"
			value = {
				errors: [
					{message: "Field 'name' is required"},
					{message: "Field 'email' is invalid"}
				]
			}
			error = Cloudflare::RequestError.new(request, value)
			
			expect(error.message).to be == "POST /api/v1/test: Field 'name' is required, Field 'email' is invalid"
			expect(error.value).to be == value
		end
		
		it "creates error with plain string" do
			request = "DELETE /api/v1/test"
			value = "Resource not found"
			error = Cloudflare::RequestError.new(request, value)
			
			expect(error.message).to be == "DELETE /api/v1/test: \"Resource not found\""
			expect(error.value).to be == value
		end
	end
end
