Geocoder.configure(
  lookup: :nominatim,
  use_https: true,
  timeout: 5,
  http_headers: {
    "User-Agent" => "package-delivery-backend"
  }
)

if Rails.env.test?
  Geocoder.configure(lookup: :test)
  Geocoder::Lookup::Test.set_default_stub(
    [ { "latitude" => -1.2921, "longitude" => 36.8219, "address" => "Nairobi, Kenya" } ]
  )
end
