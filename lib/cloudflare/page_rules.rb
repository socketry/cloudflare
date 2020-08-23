module Cloudflare
	module Page		
        class Rule < Representation
			def initialize(url, record = nil, **options)
				super(url, **options)

				@record = record || get.result
			end

     
            def update(targets, actions, **options)
				response = put(
                    targets: targets,
                    actions: actions,
					**options
				)

				@value = response.result
			end

			def actions
				value[:actions]
			end

			def targets
				value[:targets]
			end

			def priority
				value[:priority]
			end

			def status
				value[:status]
			end

			def to_s
				"#{@record[:priority]} #{@record[:status]} #{@record[:id]}"
			end
        end
        
        class Rules < Representation
			include Paginate

			def representation
				Rule
			end

			TTL_AUTO = 1
			
			def create(targets, actions, **options)
				represent_message(self.post(targets: targets, actions: actions, **options))
			end

		end
	end
end