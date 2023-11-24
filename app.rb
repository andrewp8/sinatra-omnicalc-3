require "sinatra"
require "sinatra/reloader"
require "http"

#GMAP & WEATHER APIS
gmap_api = ENV.fetch("GMAPS_KEY")
weather_api = ENV.fetch("PIRATE_WEATHER_KEY")

get("/") do
  erb(:homepage)
end

get("/umbrella"){

  erb(:umbrella_form)
}
post("/process_umbrella"){
  @location = params["user_location"]
  # ======GMAP DATA======
  gmap_url = "https://maps.googleapis.com/maps/api/geocode/json?address=Merchandise%20Mart%20"+@location.gsub(" ","%20")+"&key="+gmap_api
  gmap_raw_response =  HTTP.get(gmap_url).to_s
  gmap_parsed_response = JSON.parse(gmap_raw_response)
  gmap_location_result = gmap_parsed_response.dig("results",0, "geometry", "location")
  @lat = gmap_location_result["lat"]
  @lng = gmap_location_result["lng"]

  # ======WEATHER DATA======
  weather_url = "https://api.pirateweather.net/forecast/"+weather_api+"/"+ @lat.to_s + ","+ @lng.to_s
  weather_raw_response = HTTP.get(weather_url).to_s
  weather_parsed_response = JSON.parse(weather_raw_response)
  
  @current_temp =  weather_parsed_response.dig("currently", "temperature")
  @current_summary = weather_parsed_response.dig("currently", "summary")
  
  over_10_percent = false
  @umbrella_mgs = ""
  weather_data = weather_parsed_response.dig("hourly", "data")
  weather_data[1,12].each_with_index{|hourly, idx| precip_prob = hourly["precipProbability"]*100

  if precip_prob > 10
    # what if there is one hour's precip_prob < 10, line 44 won't we executed. 
    over_10_percent = true
  end
  }
  over_10_percent == true ? @umbrella_mgs = "You might want to carry an umbrella!" : @umbrella_mgs = "You probably won't need an umbrella."
  erb(:umbrella_process)
}

get("/message"){
  erb(:message_form)
}
post("/process_single_message"){
  erb(:message_process)
}
