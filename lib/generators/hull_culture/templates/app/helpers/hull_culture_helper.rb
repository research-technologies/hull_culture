# frozen_string_literal: true
module HullCultureHelper
  
  # @param dm_pair [String] eg 50 41'55" N, 3 5'27" W
  # @return lat long decimals
  def latlong(dms_pair)
    match = dms_pair.match(/(\d+) (\d+)'(\d+)" ([NS]), (\d+) (\d+)'(\d+)" ([EW])/)

#    lat = dms_to_degrees(*match[1..4].map {|x| x.to_f})
#    long = dms_to_degrees(*match[5..8].map {|x| x.to_f})
    lat = dms_to_degrees(*match[1..4])
    long = dms_to_degrees(*match[5..8])

    [lat,long]
#    {:latitude=>latitude, :longitude=>longitude}
  end

  def dms_to_degrees(d, m, s, bearing)
    r = d.to_f + (m.to_f / 60 + s.to_f / 3600) 
    if ['S','W'].include? bearing 
      0 - r
    else
      r
    end
  end

end
