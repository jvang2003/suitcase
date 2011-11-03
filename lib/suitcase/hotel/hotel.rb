require 'net/http'
require 'uri'
require 'json'
require File.dirname(__FILE__) + '/../country_codes'

module Suitcase
  class Hotel
    attr_accessor :id, :name, :address, :city, :postal_code, :country, :airport_code, :rating, :confidence_rating, :description, :high_rate, :low_rate, :tripadvisor_rating, :currency_code, :latitude, :longitude

    def self.find(hash)
      hotels = []
      json = JSON.parse Net::HTTP.get_response(URI.parse(URI.escape("http://api.ean.com/ean-services/rs/hotel/v3/list?apiKey=#{Suitcase::Hotel::API_KEY}&city=#{hash[:near]}&numberOfResults=#{hash[:results]}"))).body
      if json["HotelListResponse"]["HotelList"]
        json["HotelListResponse"]["HotelList"]["HotelSummary"].each do |hotel_data|
          h = Hotel.new
          h.id = hotel_data["hotelId"]
          h.name = hotel_data["name"]
          h.address = hotel_data["address1"]
          h.city = hotel_data["city"]
          h.postal_code = hotel_data["postalCode"]
          h.country = COUNTRY_CODES[hotel_data["countryCode"]]
          h.airport_code = hotel_data["airportCode"]
          h.rating = hotel_data["hotelRating"]
          h.confidence_rating = hotel_data["confidenceRating"]
          h.tripadvisor_rating = hotel_data["tripAdvisorRating"]
          h.currency_code = hotel_data["rateCurrencyCode"]
          h.latitude = hotel_data["latitude"]
          h.longitude = hotel_data["longitude"]
          h.high_rate = hotel_data["highRate"]
          h.low_rate = hotel_data["lowRate"]
          hotels.push(h)
        end
        hotels[0..hash[:results]-1]
      else
        if json["HotelListResponse"]["EanWsError"]
          raise "An error occured. Check data."
        end
      end
    end

    def geolocation
      latitude + ", " + longitude
    end

    def complete_address
      address + " " + city + ", " + country + " " + postal_code
    end
  end
end
