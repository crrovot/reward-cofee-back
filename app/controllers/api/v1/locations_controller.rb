module Api
  module V1
    class LocationsController < BaseController
      # GET /api/v1/locations
      def index
        locations = Location.active
        
        # Si no hay locations en DB, usar datos por defecto
        if locations.empty?
          locations_data = default_locations
        else
          locations_data = locations.map(&:as_json_for_api)
        end
        
        render json: {
          success: true,
          locations: locations_data
        }, status: :ok
      end

      private

      def default_locations
        [
          { 
            id: 1, 
            name: "Sucursal Centro", 
            address: "Av. Principal 123, Santiago",
            phone: "+56223456789",
            hours: "Lun-Vie: 8:00-20:00, Sab-Dom: 9:00-18:00",
            latitude: -33.4489,
            longitude: -70.6693
          },
          { 
            id: 2, 
            name: "Sucursal Parque", 
            address: "Calle Parque 456, Santiago",
            phone: "+56223456790",
            hours: "Lun-Vie: 7:30-19:30, Sab: 9:00-14:00",
            latitude: -33.4372,
            longitude: -70.6506
          },
          { 
            id: 3, 
            name: "Sucursal Mall", 
            address: "Centro Comercial Local 15, Las Condes",
            phone: "+56223456791",
            hours: "Lun-Dom: 10:00-22:00",
            latitude: -33.4103,
            longitude: -70.5673
          },
          { 
            id: 4, 
            name: "Sucursal Norte", 
            address: "Av. Norte 789, Providencia",
            phone: "+56223456792",
            hours: "Lun-Vie: 8:00-19:00, Sab: 9:00-15:00",
            latitude: -33.4264,
            longitude: -70.6153
          }
        ]
      end
    end
  end
end
