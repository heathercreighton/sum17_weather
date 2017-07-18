class WelcomeController < ApplicationController
  def test



		  	response = HTTParty.get("http://api.wunderground.com/api/#{ENV['wunderground_api_key']}/geolookup/conditions/q/AZ/Phoenix.json")


		  	puts "**************************************"
		  	puts response
		  	puts "**************************************"
		  
		  @location = response['location']['city']
		  @temp_f = response['current_observation']['temp_f']
		  @temp_c = response['current_observation']['temp_c']
		  @weather_icon = response['current_observation']['icon_url']
		  @weather_words = response['current_observation']['weather'] 
		  @forecast_link = response['current_observation']['forecast_url']
		  @real_feel = response['current_observation']['feelslike_f']

  end

  def index

  	@searched = Location.all
  	# Creates an array of states that our user can choose from on our index page
    @states = %w(HI AK CA OR WA ID UT NV AZ NM CO WY MT ND SD NB KS OK TX LA AR MO IA MN WI IL IN MI OH KY TN MS AL GA FL SC NC VA WV DE MD PA NY NJ CT RI MA VT NH ME DC).sort!

    # removes spaces from the 2-word city names and replaces the space with an underscore 
    if params[:city] != nil
        params[:city].gsub!(" ", "_")
    end

    #checks that the state and city params are not empty before calling the API
      if params[:state] != "" && params[:city] != "" && params[:state] != nil && params[:city] != nil


		 
	 results = HTTParty.get("http://api.wunderground.com/api/#{Figaro.env.wunderground_api_key}/geolookup/conditions/q/#{params[:state]}/#{params[:city]}.json")
		  

        # if no error is returned from the call, we fill our instants variables with the result of the call	 
        if results['response']['error'] == nil || results['error'] ==""  	
			    @location = results['location']['city']
			    @temp_f = results['current_observation']['temp_f']
			    @temp_c = results['current_observation']['temp_c']
		      @weather_icon = results['current_observation']['icon_url']
			    @weather_words = results['current_observation']['weather']
		      @forecast_link = results['current_observation']['forecast_url']
			    @real_feel_f = results['current_observation']['feelslike_f']
			    @real_feel_c = results['current_observation']['feelslike_c']


			    if @weather_words == "Sunny" || @weather_words == "Clear"
								@body_class = "sunny"
							elsif @weather_words == "Snow"
								@body_class = "snow"
							elsif @weather_words.include?('Rain') || @weather_words == "Shower"	
								@body_class = "rain"

							elsif @weather_words == "Overcast" || @weather_words == "Mostly Cloudy"
								@body_class = "cloudy"
							elsif @weather_words.include?('Fog') 	
								@body_class = "foggy"	
							elsif @weather_words == "Partly Cloudy" || @weather_words == "Partly Sunny"
								@body_class = "partly_sunny"	
						else
								@body_class = "default"		
						
								
					end		 	
	 			else
            # if there is an error, we report it to our user via the @error variable 	
	    	@error = results['response']['error']['description']
    	 end
		   
		  @visited = Location.where(city: params[:city], state: params[:state])

		  if @visited.blank?
		  	@visited = Location.create(city: params[:city], state: params[:state])
		  end	
		  

   end 	 
  end
end
